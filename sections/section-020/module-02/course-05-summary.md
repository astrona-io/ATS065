---
draft: true
exam_objectives:
  - Versioned and Immutable
---
# Summary

A commit stores a snapshot of the files, its parent commits, an author, a committer and a message, and its id depends on all of them. A change to an old commit changes every later id, so the chain is tamper-evident. The log, show, blame and diff commands answer what changed, who changed it and when. The `Application` field `status.sync.revision` links a running object to its commit. The author field is a claim that anyone can type, not proof of identity.

A signature proves that a commit or tag was not changed and that the holder of a key signed it. Git signs with GnuPG or SSH keys. Annotated tags carry a tagger and a message, and signed tags add a signature. Argo CD checks GnuPG signatures against the keys in the field `signatureKeys` of an `AppProject` when it syncs, and Flux checks them in the `verify` section of a `GitRepository`.

The branch that the agent follows is the deployment switch. Pull requests, required approvals, status checks, CODEOWNERS and a ban on direct and force pushes decide who can change it and leave a record of the decision. Emergency changes also go through Git.

Rewriting history creates new commits and leaves the old ones unreachable. A force push on the tracked branch moves the cluster to the new tip with no error. Argo CD keeps a limited list of deployed revisions, but it does not replace the Git history. A revert commit undoes a change and keeps the story.

Key facts:

- Access to the tracked branch is access to production.
- A signature shows who signed, and review shows that someone checked.
- Use `git revert` to undo a change, not a reset and force push.

<!-- astrona:playground:destroy -->
