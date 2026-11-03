---
draft: true
exam_objectives:
  - Declarative
---
# Helm And Kustomize As Renderers

Most repositories do not hold every manifest in its final form. They hold templates or bases and let a tool produce the final manifests. This part compares the two common tools, Helm and Kustomize, and shows how Argo CD runs each one.

## Two ways to build manifests

Kustomize works without templates. A base is a set of valid manifests. An overlay lists the base and adds patches, labels, a namespace, an image tag or a replica count. Every input is a plain YAML file, and the tool is built into `kubectl`.

Helm uses templates. A **chart** is a folder with `Chart.yaml` (name and version), `values.yaml` (default settings) and a `templates` folder. The templates hold placeholders such as `{{ .Values.replicaCount }}`. The user supplies values, and Helm fills the placeholders.

| | Kustomize | Helm |
| --- | --- | --- |
| Input | Base plus overlays | Chart plus values |
| Way to change a field | Patch | Template placeholder |
| Packaging and versioning | Folder in Git | Chart with a version, can be published |
| Tool | `kubectl kustomize` | `helm template` |

## Helm values

Helm merges values from several places. The chart's `values.yaml` is the lowest layer. Files passed with `-f` or `--values` override it, and `--set key=value` overrides those. In the chart of the playground, `values.yaml` sets `replicaCount: 1`, an image tag and a message.

`helm template NAME CHART` prints the final manifests and changes nothing in the cluster. `helm lint CHART` checks the chart for errors. These are the commands to use in a review or a pipeline, because they are read-only.

For example, this renders the chart with three replicas:

```sh
helm template scout scout-deploy/charts/scout --set replicaCount=3
```

## Helm in Argo CD

Argo CD does not run `helm install`. Its repository server runs `helm template` and applies the output itself. That has two effects. There is no Helm release object in the cluster, so `helm list` does not show the application. And Helm hooks are not run by Helm, so Argo CD maps them to its own hooks.

On the `Application`, the section `spec.source.helm` holds the inputs. `valuesObject` holds values as YAML. `valueFiles` lists value files inside the repository. `parameters` sets single values like `--set`. `releaseName` sets the name that templates see as `.Release.Name`, which defaults to the `Application` name.

```yaml
spec:
  source:
    repoURL: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
    targetRevision: main
    path: charts/scout
    helm:
      valuesObject:
        replicaCount: 2
        message: staging-helm
```

The values now live on the `Application` object and not in Git next to the chart. That is a choice with a cost: the `Application` itself must be in Git too, otherwise those values are an undeclared part of the cluster.

## Pin what the render depends on

The rendered result depends on the chart version, the dependency versions and the values. A chart in the same repository is pinned by the commit. A chart from a Helm repository or an OCI registry is pinned by its version number in `targetRevision`. A version range such as `1.*` can resolve to a different chart tomorrow. Use an exact version.

Kustomize has the same issue with remote bases. Reference a base by a tag or a commit, not by a branch.

## Try it: render the chart two ways

<!-- astrona:playground:renew -->

```sh
git_clone
cd scout-deploy
kubectl kustomize overlays/staging
```

This prints the staging manifests from the overlay. If Helm is installed on your machine, render the chart:

```sh
helm template scout charts/scout
helm template scout charts/scout --set replicaCount=2,message=helm-staging
```

The second command prints a Deployment with two replicas and the new message. The chart files did not change. Now let Argo CD render it. Save this as `application-scout-helm.yaml`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: scout-helm
  namespace: argocd
spec:
  project: default
  source:
    repoURL: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
    targetRevision: main
    path: charts/scout
    helm:
      valuesObject:
        replicaCount: 2
  destination:
    server: https://kubernetes.default.svc
    namespace: starfleet-staging
  syncPolicy:
    automated: {}
    syncOptions:
      - CreateNamespace=true
```

```sh
kubectl apply -f application-scout-helm.yaml
app_status
```

When it is `Synced`, the Deployment has two replicas. Check that no Helm release exists, because Argo CD applied the rendered manifests itself:

```sh
kubectl -n starfleet-staging get secrets
```

The list holds no Secret of the type `helm.sh/release.v1`.

## What you know now

Kustomize and Helm both turn inputs into manifests. Kustomize patches plain files and Helm fills templates. Argo CD runs the renderer in its repository server, applies the output and keeps no Helm release. The rule is the same for both: pin every input, so the same commit always renders the same manifests.

## Common pitfalls

> [!WARNING]
> Values set only on the `Application` are not in the chart repository. If the `Application` is not in Git, a rebuilt cluster loses them. Keep the `Application` in Git, or put the values in a values file in the repository.
