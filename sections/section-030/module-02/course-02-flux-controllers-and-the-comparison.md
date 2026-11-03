---
draft: true
exam_objectives:
  - Pulled Automatically
---
# Flux Controllers And The Comparison

Flux is the other widely used pull-based agent. The exam asks about GitOps as a method, not about one product, so it helps to see the same jobs in a second tool. This part names the Flux controllers and maps each to its Argo CD counterpart.

## The GitOps Toolkit

Flux is built as a toolkit of controllers, each with its own custom resources. They run in the namespace `flux-system`, which the command `flux bootstrap` creates and fills. `flux check` verifies that the controllers are healthy.

The **source controller** fetches artifacts and makes them available to the other controllers. It handles `GitRepository`, `OCIRepository`, `HelmRepository`, `HelmChart` and `Bucket` objects. It is the counterpart of the Argo CD repository server for the clone and fetch part.

The **kustomize controller** applies a path of a source as Kustomize or plain YAML. Its resource is the `Kustomization`. It builds the manifests, applies them, prunes and checks health. It combines the rendering and the apply jobs of Argo CD.

The **helm controller** manages Helm releases from `HelmRelease` objects. Unlike Argo CD, it runs real Helm install and upgrade operations, so a Helm release exists in the cluster.

The **notification controller** sends alerts from events and receives webhooks through `Receiver` objects. The optional **image reflector** and **image automation** controllers scan registries and write new image tags back to Git.

## A minimal pair of objects

A `GitRepository` says where the source is and how often to check it. A `Kustomization` says which path to apply:

```yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: scout-deploy
  namespace: flux-system
spec:
  interval: 1m
  url: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
  ref:
    branch: main
---
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: scout-staging
  namespace: flux-system
spec:
  interval: 5m
  sourceRef:
    kind: GitRepository
    name: scout-deploy
  path: ./overlays/staging
  prune: true
  targetNamespace: starfleet-staging
```

The `interval` of the `GitRepository` is how often the source controller checks for a new revision. The `interval` of the `Kustomization` is how often the kustomize controller re-applies the path, which also corrects drift.

## The comparison

| Job | Argo CD | Flux |
| --- | --- | --- |
| Fetch from Git | repo-server | source-controller |
| Render and apply Kustomize or YAML | application-controller with repo-server | kustomize-controller |
| Helm | Rendered by `helm template`, applied by Argo CD | helm-controller runs Helm releases |
| Declares one deployment | `Application` | `GitRepository` plus `Kustomization` |
| Web interface | Built in | Not part of Flux |
| Command line | `argocd` | `flux` |

Both tools pull, both hold the desired state in Git and both reconcile continuously. They differ in packaging and in how they model an application. The GitOps principles do not depend on the choice.

## Useful Flux commands

`flux get sources git` lists the sources with their last revision. `flux get kustomizations` lists the Kustomizations with their ready state. `flux reconcile source git NAME` asks for an immediate fetch, and `flux reconcile kustomization NAME` asks for an immediate apply. They are the Flux counterparts of the `refresh` annotation in Argo CD.

## Reading the comparison

The difference that matters most for an operator is where a failure shows up. In Argo CD, one `Application` shows sync and health in one place. In Flux, a fetch failure shows on the `GitRepository` and an apply failure shows on the `Kustomization`, so you read two objects.

## Try it: read the Flux objects

The playground does not install Flux. Render the objects locally and read what each field means:

<!-- astrona:playground:renew -->

```sh
git_clone
cd scout-deploy
kubectl kustomize overlays/staging | head -20
```

The rendered Deployment and Service are what `path: ./overlays/staging` would give the kustomize controller. In Argo CD, the same path is `spec.source.path`. The Argo CD field `spec.destination.namespace` has the Flux counterpart `spec.targetNamespace`. Now compare the two answers to "how often does the agent look":

```sh
kubectl -n argocd get configmap argocd-cm -o jsonpath='{.data.timeout\.reconciliation}'
```

The value is empty when the default of 180 seconds applies. In Flux the value is set per object in `spec.interval`.

## What you know now

Flux splits the agent into a source controller, a kustomize controller, a helm controller and a notification controller. Argo CD combines apply and compare in one controller and keeps Git access in a repository server. The two tools do the same job, and the principles apply to both. The next part looks at the direction of the network connections that all of these agents open.

## Common pitfalls

> [!WARNING]
> A Flux `Kustomization` is not the same as a Kustomize `kustomization.yaml`. The first is a custom resource in the cluster that tells Flux what to apply. The second is a file in the repository that tells Kustomize how to build.
