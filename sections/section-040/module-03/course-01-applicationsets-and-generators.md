---
draft: true
exam_objectives:
  - Continuously Reconciled
---
# ApplicationSets And Generators

An `ApplicationSet` is a custom resource that creates and maintains `Application` objects from a template and a list of parameters. The parameters come from a generator. The result is that the list of environments, clusters or teams is data, and adding an entry adds an `Application`.

## Structure

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: scout
  namespace: argocd
spec:
  goTemplate: true
  generators:
    - list:
        elements:
          - env: staging
          - env: production
  template:
    metadata:
      name: 'scout-{{ .env }}'
    spec:
      project: default
      source:
        repoURL: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
        targetRevision: main
        path: 'overlays/{{ .env }}'
      destination:
        server: https://kubernetes.default.svc
        namespace: 'starfleet-{{ .env }}'
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
```

The controller renders the template once per element and creates `scout-staging` and `scout-production`. The `ApplicationSet` owns them: if one is deleted, it is created again, and if the element is removed, the `Application` is deleted.

## Generators

| Generator | Source of parameters |
| --- | --- |
| `list` | A fixed list in the manifest |
| `clusters` | Clusters registered in Argo CD, optionally filtered by label |
| `git` with directories | Folders in a repository, one element per folder |
| `git` with files | JSON or YAML files in a repository, one element per file |
| `matrix` | The product of two generators, for example clusters times folders |
| `merge` | Several generators combined by a key, with later ones overriding values |
| `pullRequest` | Open pull requests of a repository, for preview environments |

The `git` generator with directories fits GitOps well. A new folder under `overlays` creates a new `Application` with no change to the `ApplicationSet`. The set of environments is then described by the repository layout.

## Deletion and safety

Deleting an `ApplicationSet` deletes the `Application` objects it created, and by the finalizer of each `Application` it can delete their resources too. The field `spec.syncPolicy.preserveResourcesOnDeletion: true` keeps the deployed resources when an `Application` is removed. The field `applicationsSync` controls whether the set may create, update and delete applications, and the policy `create-only` makes the controller only create them. A mistaken generator can remove many applications at once, so these settings are worth knowing before production use.

## Prune last

The sync option `PruneLast=true` makes deletion of objects that left Git happen after the other objects are synced and healthy. It suits a change that replaces one object with another, because the old object is removed only once the new one works.

## Try it: generate two Applications

<!-- astrona:playground:renew -->

```sh
kubectl apply -f - <<'Y'
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: scout
  namespace: argocd
spec:
  goTemplate: true
  generators:
    - list:
        elements:
          - env: staging
          - env: production
  template:
    metadata:
      name: 'scout-{{ .env }}'
    spec:
      project: default
      source:
        repoURL: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
        targetRevision: main
        path: 'overlays/{{ .env }}'
      destination:
        server: https://kubernetes.default.svc
        namespace: 'starfleet-{{ .env }}'
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
          - CreateNamespace=true
Y
kubectl -n argocd get applicationset,application
```

Two `Application` objects appear. The playground repository must have both overlays for them to sync. Delete one of the generated `Application` objects with `kubectl -n argocd delete application scout-production` and watch the controller create it again.

## What you know now

An `ApplicationSet` renders a template once per set of parameters from a generator and owns the resulting `Application` objects. The `git` directory generator turns the repository layout into the list of applications. The set can delete many applications, so deletion policy matters. `PruneLast` orders deletion after the other changes.

## Common pitfalls

> [!WARNING]
> Changing the template of an `ApplicationSet` changes every generated `Application` at once. Test a template change on a small set first.
