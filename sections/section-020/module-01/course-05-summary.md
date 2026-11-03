---
draft: true
exam_objectives:
  - Versioned and Immutable
---
# Summary

A Git commit identifies a snapshot, its message and its parent by a hash. A different content means a different ID, so a version with an ID is immutable. Branches and tags are names that point at commits. A branch moves with every commit, and a tag is meant to stay but can be moved unless the server forbids it. Argo CD resolves the name in `targetRevision` to a commit ID and records it in `status.sync.revision`.

Pinning means referencing something that does not move: a commit ID, a protected tag, an image digest. A pinned repository that names a movable image tag still lets the running code change. A rollback is safest as a new commit created with `git revert`, because the failed release stays in the history. A forced reset removes it. The Argo CD rollback uses `status.history` and does not work while automated sync is on.

Promotion moves one tested pair of desired state and artifacts to the next environment by changing a pointer: a tag followed by production, or a commit that copies the tested values. The image is built once and referenced by identity. A passing staging run does not prove production capacity or data. Secrets must not be committed in plain form, because history keeps every version, and a leaked value is rotated, not only deleted.

Key facts:

- The Git log, the review record and `status.sync.revision` together show what changed, who approved it and what was evaluated.
- A tag is a name and can be moved unless the server forbids it.
- A digest cannot point at another image, and a registry tag can.
- Removing a file does not remove its content from history.

<!-- astrona:playground:destroy -->
