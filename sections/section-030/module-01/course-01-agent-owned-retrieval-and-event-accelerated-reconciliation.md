---
draft: true
exam_objectives:
- Pulled Automatically
---
# Agent-Owned Retrieval And Event-Accelerated Reconciliation

Automatic pulling means the management agent obtains authoritative desired state through its own configured access path. It does not depend solely on a deployment pipeline handing it a one-time payload. The agent can return to the state store after an outage or missed notification and evaluate an identified version. This independent retrieval supports ongoing reconciliation.

Pulling describes the control relationship, not simply the direction of one network packet. A notification service can call an agent's receiver when a source changes. The agent can then retrieve the authoritative version itself. That arrangement still differs from a pipeline that directly applies an arbitrary payload to the target and leaves no ongoing authority for later evaluation.

Consider a build pipeline that produces an image and proposes a configuration update. Review accepts the update in the desired-state store. The management agent obtains the selected revision and applies it under its target policy. The pipeline does not need the same target credential merely to publish an artifact or propose intent. Separating these roles can narrow credential distribution.

A webhook can reduce observation delay. It signals that evaluation may be useful, while the state store supplies the versioned content. Notifications can be duplicated, delayed or lost. A dependable agent can recover by retrieving current authoritative state through its ordinary path. The event should not be the only surviving description of what the target is supposed to become.

Source access still requires security. The agent needs a credential or other authorized access appropriate to its store. That authority should normally be limited to its intended reading or supported update role. An attacker who can alter authoritative source content can influence what the agent attempts, so review and policy remain essential. Pulling does not make arbitrary source content trustworthy.

Target authority is a separate role. The agent must be able to perform its assigned actions, but it should not automatically receive unrestricted control of every resource. A central agent managing multiple targets needs deliberate per-target boundaries. An in-cluster agent can still be overprivileged. Placement and retrieval direction are not substitutes for least privilege.

Failure handling should identify whether the source was unavailable or the target rejected action. An expired source credential can leave the agent evaluating an older obtained version. An expired target credential can allow successful source retrieval while blocking application. Reporting the resolved revision and relevant error makes these conditions distinguishable.

Mutable source selection also needs attention. An agent following a branch should identify the concrete version it retrieved. If the branch moves during evaluation, the implementation's contract determines when the newer version is considered. Students should not assume that a branch name means the latest version has already reached every target.

Automatic retrieval does not eliminate deployment policy. The agent may render input, check health, restrict deletion or require a permitted synchronization decision. Different engines implement these controls differently. The principle identifies who can obtain intent, while the actual implementation determines how that intent is realized safely.

Useful review follows the entire chain: artifact production, desired-state approval, agent retrieval, target action and feedback. That makes the credential and authority boundaries visible. It also allows students to explain why an event-driven acceleration can support GitOps while a one-time direct apply remains a different management design.

## Common pitfalls

> [!WARNING]
> A notification is not authoritative state history. Pulling does not automatically establish trustworthy input or safe target permissions. Separate source retrieval, target action and CI roles, and preserve recovery when events are missed.
