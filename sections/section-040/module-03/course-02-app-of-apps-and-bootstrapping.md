---
draft: true
exam_objectives:
  - Continuously Reconciled
---
# App Of Apps And Bootstrapping

A new cluster needs the agent first and then everything the agent should deliver. The app-of-apps pattern solves the second half: one root `Application` points at a folder of `Application` manifests, and each of those delivers one part of the platform. Only the root is created by hand.

## The pattern

The root `Application` has a source path that contains manifests of kind `Application` (or `ApplicationSet`). Argo CD applies them in the `argocd` namespace, and the controller then reconciles each child as usual.

```text
bootstrap/
  root.yaml            # the one Application created by hand
apps/
  ingress.yaml         # Application for the ingress controller
  monitoring.yaml      # Application for monitoring
  scout.yaml           # ApplicationSet for the scout environments
```

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: root
  namespace: argocd
spec:
  project: default
  source:
    repoURL: http://gitea-http.gitea.svc:3000/starfleet/platform.git
    targetRevision: main
    path: apps
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

The destination namespace is `argocd` because the children are `Application` objects, which live there.

## Ordering the children

Sync waves apply to the children too. An annotation `argocd.argoproj.io/sync-wave` on a child `Application` makes the root wait for the earlier wave to be healthy. Argo CD treats the health of an `Application` as a resource health check, so a platform can bring up CRDs and operators in an early wave and workloads in a later one. For the health check of the child `Application` type to apply in a root, it must be available in the installed version. Check this against the documentation of the version in use.

## Bootstrapping the agent itself

The root `Application` can also deliver Argo CD, so the agent manages its own configuration. This is a bootstrap loop: the first install is manual or by a script, and after the root is created, later changes to Argo CD come from Git. Keep a way to recover if a bad change breaks the agent: an earlier commit and a manual path to reapply it.

For Flux, `flux bootstrap` does the equivalent. It installs the controllers, commits the manifests of the controllers to the repository, and creates a `GitRepository` and a `Kustomization` that reconcile that path, so Flux manages itself from then on.

## App of apps or ApplicationSet

Both generate children from Git. The app-of-apps pattern is explicit: every child is a file with its own settings. An `ApplicationSet` is uniform: every child comes from one template. Use app-of-apps when children differ, such as different charts and projects. Use an `ApplicationSet` when children are the same shape, such as one per environment. A common layout has a root that contains both.

## Try it: build a root

<!-- astrona:playground:renew -->

Clone the repository and add a folder with one child `Application`:

```sh
git_clone
cd scout-deploy
mkdir -p apps
cat > apps/scout-staging.yaml <<'Y'
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: scout-staging
  namespace: argocd
spec:
  project: default
  source:
    repoURL: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
    targetRevision: main
    path: overlays/staging
  destination:
    server: https://kubernetes.default.svc
    namespace: starfleet-staging
  syncPolicy:
    automated: {}
    syncOptions:
      - CreateNamespace=true
Y
git add -A && git commit -qm "Add a child Application" && git push -q origin main
```

Create the root `Application` with the path `apps` and the destination namespace `argocd`. After a refresh, `scout-staging` appears as a child with no manual `kubectl apply`.

## What you know now

The app-of-apps pattern uses one hand-made root `Application` whose path holds the manifests of the child `Application` objects. Sync waves order the children. The same pattern can deliver the agent itself, and `flux bootstrap` does this for Flux. Choose app-of-apps for children that differ and an `ApplicationSet` for children of the same shape.

## Common pitfalls

> [!WARNING]
> A root with automated prune deletes a child when its file is removed, and a child with the finalizer deletes its resources too. Review changes to the folder of a root with the same care as a production deployment.
