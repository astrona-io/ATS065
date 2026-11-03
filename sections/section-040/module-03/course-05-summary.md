---
draft: true
exam_objectives:
  - Continuously Reconciled
---
# Summary

An `ApplicationSet` renders a template once per set of parameters from a generator and owns the resulting `Application` objects. The list generator gives a fixed set, the cluster generator one per registered cluster, and the git generator one per folder or file, so the repository layout can describe the environments. Deleting a set or removing an element deletes applications, so deletion policy and `PruneLast` are worth setting deliberately.

The app-of-apps pattern uses one hand-made root `Application` whose path holds the child `Application` manifests. Waves order the children, and the root can deliver the agent itself. `flux bootstrap` does the same for Flux. Use app-of-apps for children that differ and an `ApplicationSet` for children of the same shape.

Reconciliation load comes from refreshes: a timer, webhooks and watched changes. The repository server renders and caches manifests, and the manifest-generate-paths annotation avoids re-rendering after unrelated commits. The application controller can be sharded across replicas by cluster with `ARGOCD_CONTROLLER_REPLICAS`, and processor limits control parallel work.

Order between environments can come from promotion commits, from progressive sync in an `ApplicationSet` (alpha, off by default), from waves in a root, from windows or manual gates, or from Flux `dependsOn`. Traffic shifting tools work inside one environment.

Key facts:

- A generator makes the list of environments data instead of manifests.
- Shard count and the replica count of the stateful set must match.
- Progressive sync is alpha and must be enabled.
- Applications without a mechanism sync independently.

<!-- astrona:playground:destroy -->
