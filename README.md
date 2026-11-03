# GitOps Principles (ATS065)

Certified GitOps Associate (CGOA): GitOps Principles, worth 30% of the official curriculum. This course belongs to ATP013.

Each section has two modules, each with developed reading, a playground and a graded lab, and a capstone lab closes the section. Every section ends with a quiz, and a final domain quiz covers the whole course. Argo CD is the reconciler and an in-cluster Gitea server is plumbing only. The labs and playgrounds are UNTESTED: they were built without being run on a cluster.

## Course Outline

| Section / module | Module | Parts |
| --- | --- | --- |
| 010 / 01 | Declared State, Rendering And Controllers | Desired State Versus Imperative Steps; Sufficient Intent And Rendering; Controllers, Ownership And Pruning |
| 010 / 02 | Declarative Formats, Idempotence And Apply Semantics | Spec, Status And The Declarative API; Create, Apply, Replace And Idempotence; Server-Side Apply And Field Managers; Helm And Kustomize As Renderers |
| 020 / 01 | Versions, References And Promotion | Commits, Branches And Tags; Pinning, Rollback And Audit; Promotion, Immutable Artifacts And Secrets |
| 020 / 02 | Git History, Audit And Change Control | What The History Records; Signed Commits And Tag Verification; Review, CODEOWNERS And Branch Protection; Rewriting History |
| 030 / 01 | Pull, Credentials And Webhooks | Push Versus Pull; Repository Credentials; Polling, Webhooks And Outages |
| 030 / 02 | The In-Cluster Agent And Pull Mechanics | Argo CD Components; Flux Controllers And The Comparison; Network Direction And Cluster Credentials; The Permissions Of The Agent |
| 040 / 01 | Drift, Refresh And Reconciliation | Drift And Refresh; Automated Sync, Self-Heal And Prune; Ignore Rules And Reconciliation Patterns |
| 040 / 02 | Health, Sync Status And Feedback Loops | Sync Status And Health Status; Sync Phases, Waves And Hooks; Retries And Failed Syncs; Observing Reconciliation |

## Author Review

See [curriculum coverage](CURRICULUM.md), [primary sources](SOURCES.md) and [contribution instructions](CONTRIBUTING.md).
