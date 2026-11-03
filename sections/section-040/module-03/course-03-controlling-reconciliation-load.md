---
draft: true
exam_objectives:
  - Continuously Reconciled
---
# Controlling Reconciliation Load

Continuous reconciliation costs work. Every `Application` is compared against Git and against the cluster, again and again. With hundreds of applications, the settings of the controller decide whether the loop stays fast. This part names what drives the load and the settings that change it.

## What the controller does

Two components do most of the work. The repository server renders manifests from Git, which means it clones the repository and runs Helm or Kustomize. The application controller compares the rendered manifests with the live objects and applies differences. The controller keeps a cache of live objects through watches on the cluster, so a comparison does not need a full read each time.

## Refresh and comparison

A refresh is a new comparison. Three things trigger it:

- the timer: by default the controller refreshes each `Application` about every three minutes (`timeout.reconciliation` in `argocd-cm`);
- a webhook from the Git host, which refreshes the applications that use the pushed repository;
- a change of a live object that the controller watches.

A long timer lowers the load and delays the detection of a change in Git. A webhook makes up for a long timer, because the push triggers a refresh at once. The documentation of the version in use gives the current default and the exact setting names.

## Repository server cost

Rendering is the expensive part for monorepos. If many applications use one repository and one commit, the repository server caches the result per revision and path, so most refreshes cost a cache read. A change under one path in a monorepo can still invalidate many applications. The annotation `argocd.argoproj.io/manifest-generate-paths` on an `Application` lists the paths whose changes require re-rendering. A commit that touches other paths then reuses the cached manifests.

```yaml
metadata:
  annotations:
    argocd.argoproj.io/manifest-generate-paths: .
```

A path starting with `.` is relative to the application path, and an absolute path starts with `/` and is relative to the repository root. The annotation works together with webhooks.

## Sharding the controller

A single application controller replica handles every cluster. The controller can be run as a stateful set with several replicas, and each replica takes a share of the clusters. The number of replicas is given to the controller through the environment variable `ARGOCD_CONTROLLER_REPLICAS`, which must match the replica count of the stateful set. Sharding is by cluster, so one very large cluster still lands on one replica.

```sh
kubectl -n argocd get statefulset argocd-application-controller -o jsonpath='{.spec.replicas}{"\n"}'
```

## Limits on parallel work

Settings in `argocd-cmd-params-cm` limit parallel work: the number of status processors and operation processors in the controller, and the number of parallel manifest generations in the repository server. Raising them speeds up a backlog and raises CPU and memory use. Raise them after measuring a backlog, not before.

## Cluster side effects

Reconciling frequently also means frequent reads of the API server of the cluster. The watch cache avoids most of them. Resources that change constantly, such as `Event` objects or leases, can be excluded from tracking with resource exclusions in `argocd-cm`, so their churn does not trigger comparisons.

## Try it: read the settings

<!-- astrona:playground:renew -->

```sh
kubectl -n argocd get configmap argocd-cm -o jsonpath='{.data}{"\n"}'
kubectl -n argocd get configmap argocd-cmd-params-cm -o jsonpath='{.data}{"\n"}'
kubectl -n argocd get deploy,statefulset -o wide
```

Empty data means the defaults are in use. Note that the application controller is a stateful set. Check how many replicas it has and which components exist. Then trigger a refresh with `app_refresh scout-staging` and see how fast the status changes. This is the work that the settings above tune.

## What you know now

The repository server renders and caches manifests, and the application controller compares and applies. Refreshes come from a timer, from webhooks and from watched changes. The manifest-generate-paths annotation avoids re-rendering when a commit does not touch the application. Sharding spreads clusters across controller replicas through `ARGOCD_CONTROLLER_REPLICAS`, and processor limits control parallel work.

## Common pitfalls

> [!WARNING]
> A replica count of the stateful set that does not match `ARGOCD_CONTROLLER_REPLICAS` leaves some clusters unassigned or double assigned. Change both together.
