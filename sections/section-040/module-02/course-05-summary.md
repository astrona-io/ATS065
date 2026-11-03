---
draft: true
exam_objectives:
  - Continuously Reconciled
---
# Summary

The sync status compares the desired state rendered from Git with the live state and is `Synced`, `OutOfSync` or `Unknown`. The health status says whether the live objects work and is `Healthy`, `Progressing`, `Degraded`, `Suspended`, `Missing` or `Unknown`. The two vary independently. An `Application` takes the worst health among its resources, and a custom resource needs a custom health check to report more than its existence.

A sync runs in phases: `PreSync`, `Sync`, `PostSync`, and `SyncFail` when it fails. A hook is an object with the hook annotation, usually a Job, and a failed `PreSync` hook stops the sync before anything changes. Within a phase, sync waves order the resources by an integer and wait for health between waves. Flux orders whole `Kustomization` objects with `dependsOn` and waits with `wait` and `healthChecks`.

A sync is an operation with a phase and a message. Automated sync makes one attempt for each revision and parameter set, so a failed attempt stays failed until something changes. The retry policy adds attempts with exponential backoff, limited by a count and a maximum wait. Rollback in a GitOps flow is a revert commit in Git. Flux retries at its interval and reports failures in the `Ready` condition.

The state is observable at several levels. The `Application` shows statuses, conditions, the last operation and the history. Events and logs show detail, metrics show patterns across applications, and notifications send results to people or back into the Git host. A fixed order of reading speeds up diagnosis: conditions, repository server log, controller log, then events.

Key facts:

- Synced does not mean working.
- A wave waits for health and a hook can stop a sync early.
- A retry limit prevents endless attempts at a permanent error.

<!-- astrona:playground:destroy -->
