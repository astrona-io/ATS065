---
draft: true
exam_objectives:
  - Continuously Reconciled
---
# Summary

Drift is a difference between the repository and the live cluster that nobody declared. Argo CD compares rendered manifests with live objects through a structural diff and stores the result in `status.sync.status`, which is `Synced`, `OutOfSync` or `Unknown`, next to an independent health status. A refresh reads and updates evidence only. A sync writes to the cluster. Observing and correcting are separate decisions.

The automated policy has three switches. `automated` reacts to a new commit, `selfHeal` reacts to a live change and restores declared values, and `prune` deletes tracked objects that left the repository. A failed sync is not retried for the same revision unless `retry` is set, an empty render is not pruned unless `allowEmpty` is set, and `Prune=false` protects one object. Self-heal means Git owns the object.

When another controller owns a field, a narrow `ignoreDifferences` rule on that field, together with `RespectIgnoreDifferences=true`, stops the loop without hiding other drift. App-of-apps and ApplicationSet create `Application` objects from Git and add a reconciliation layer. One object needs one owner. To diagnose a failure, check the layers in order: the `Application` exists, it renders, it syncs and it is healthy.

Key facts:

- A hard refresh drops caches and still applies nothing.
- A broad ignore rule hides the differences that drift detection exists to find.
- The parent recreates a child that is deleted by hand.
- A refresh cannot fix a bad path or a denied permission.

<!-- astrona:playground:destroy -->
