---
draft: true
exam_objectives:
  - Continuously Reconciled
---
# Progressive Rollouts Across Environments

Reconciliation brings every environment to the declared state as soon as it can. For a risky change, a team may want staging first, then production after staging proves healthy. This part covers the ways to order a rollout and the limits of each.

## Order by promotion in Git

The simplest and most portable method is to let Git carry the order. Each environment follows its own path or branch, and a promotion is a commit that changes the production declaration after staging is verified. Nothing in the tool is special: the reconciliation of production does not start until the commit exists. The second module of the release section described promotion in detail.

## Progressive sync in ApplicationSet

An `ApplicationSet` can roll changes across the `Application` objects it generates in steps. The feature is called progressive sync (`RollingSync`). It is an alpha feature, and it is off by default. It must be enabled in the `ApplicationSet` controller, and the documentation of the version in use gives the setting. Because it is alpha, its fields may change between versions.

```yaml
spec:
  strategy:
    type: RollingSync
    rollingSync:
      steps:
        - matchExpressions:
            - key: env
              operator: In
              values: [staging]
        - matchExpressions:
            - key: env
              operator: In
              values: [production]
          maxUpdate: 1
```

The generated `Application` objects need a label such as `env`, set in the template metadata. The controller then updates the applications of step one first, waits until they are healthy, and goes on to step two. How applications that match no step are handled, and how the strategy interacts with the automated sync policy of the template, differ between versions. Read the `ApplicationSet` documentation of the version in use before relying on either.

## Waves across Applications

Sync waves order resources inside one `Application`, and in an app-of-apps root they order the child `Application` objects. This gives an order for bootstrap. It is not a promotion mechanism, because a wave order only holds when a root syncs the children together.

## Sync windows and manual gates

A sync window on the `AppProject` can allow production syncs only in set hours. Disabling automated sync for production and syncing by hand is a manual gate. Both are simple controls, and neither verifies that staging was healthy.

## Flux and external tools

Flux orders by dependency: a `Kustomization` can name others in `dependsOn` and waits for them to be ready. Progressive delivery tools, such as Argo Rollouts and Flagger, work inside one environment. They shift traffic to a new version in steps and check metrics, and they roll back if checks fail. They address the question of how a single deployment goes live, while the options above address the order between environments.

## Comparison

| Method | Order enforced by | Verifies health first | Status |
| --- | --- | --- | --- |
| Promotion commit | Git | By the person or pipeline that commits | Stable |
| Progressive sync | ApplicationSet controller | Yes, by health of the step | Alpha |
| Sync waves | Sync of one root | Yes, inside that sync | Stable |
| Sync window | Clock | No | Stable |
| Flux dependsOn | Kustomization readiness | Yes | Stable |

## Try it: label the generated applications

<!-- astrona:playground:renew -->

Add a label to the template of the `ApplicationSet` from the first part of this module and see it on the result:

```sh
kubectl -n argocd patch applicationset scout --type merge -p '{"spec":{"template":{"metadata":{"labels":{"env":"{{ .env }}"}}}}}'
kubectl -n argocd get applications -L env
```

The `env` column shows `staging` and `production`. These labels are what a progressive sync step would match. Do not enable the alpha feature in a shared installation without reading the documentation of the version.

## What you know now

Order between environments can come from promotion commits in Git, from progressive sync in an `ApplicationSet`, from waves in a root, from windows or manual gates, or from Flux `dependsOn`. Progressive sync is alpha and must be enabled. Tools that shift traffic address a single deployment and are a separate layer.

## Common pitfalls

> [!WARNING]
> Do not assume that two automated `Application` objects sync in the order they are listed. Without a mechanism, they sync independently and at the same time.
