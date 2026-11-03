---
draft: true
exam_objectives:
  - Versioned and Immutable
---
# Keeping The History Safe

The versioned state is only as dependable as the place that stores it. If the repository is lost or its history is rewritten, the record of what was deployed goes with it. This part explains why the repository needs copies, which operations change history, and how a team checks that the copy is complete.

## The repository is a single point

A Git repository on a hosting service is a copy that many people share. The service can be unavailable, a repository can be deleted by mistake, and an account can be compromised. A hosted repository is not a backup of itself.

Git helps here because every clone holds the full history. A clone made with `git clone --mirror` copies all refs: branches, tags and notes. A mirror is a complete copy of the repository that can be pushed to another server.

```sh
git clone --mirror http://platform:starfleet-gitops@127.0.0.1:3000/starfleet/scout-deploy.git scout-deploy.mirror
git -C scout-deploy.mirror for-each-ref --format='%(refname)' | head
```

The second command lists the refs that the mirror holds. A single file backup is also possible with a bundle:

```sh
git -C scout-deploy.mirror bundle create ../scout-deploy.bundle --all
git bundle verify scout-deploy.bundle
```

`git bundle verify` checks that the bundle is complete and can be applied.

## What changes history

Normal commits only add to the history. Four kinds of operation change or remove it: a force push over a branch, deleting a branch or tag, rewriting commits with `git rebase` or `git commit --amend` after they were pushed, and removing content with a tool such as `git filter-repo`. After any of these, a commit that was deployed may no longer be reachable from a branch.

The server can refuse these operations. Branch protection blocks force pushes and deletion on the branch that production follows. Protected tags stop a release tag from being moved. These are settings of the Git host, so they are configured outside the repository, and a team should record them.

## The record in the cluster

The cluster keeps a small record of its own. The `status.history` of an `Application` lists the revisions that were deployed, with times. After a rewrite, this list can still name a commit that the repository no longer holds. This is useful for an audit, but it is not a copy of the content.

```sh
kubectl -n argocd get application scout-staging -o jsonpath='{range .status.history[*]}{.id} {.revision} {.deployedAt}{"\n"}{end}'
```

Each line shows the history ID, the commit and the time of the deployment.

## Retention rules

A team should decide how long to keep three things. The repository history, which is normally kept for the life of the system. Tags that mark releases, which are normally kept without limit. Build artifacts such as images, which are kept as long as any tag or deployment may still refer to them. A rollback to a version whose image was deleted fails, so artifact retention and the deployed history must match.

## Try it: copy the repository and verify it

<!-- astrona:playground:renew -->

```sh
git clone --mirror http://platform:starfleet-gitops@127.0.0.1:3000/starfleet/scout-deploy.git /tmp/scout.mirror
git -C /tmp/scout.mirror for-each-ref --format='%(refname) %(objectname:short)'
git -C /tmp/scout.mirror bundle create /tmp/scout.bundle --all
git bundle verify /tmp/scout.bundle
```

The ref list shows each branch and tag with its commit. The verify command reports that the bundle is okay. Now note the commit of `main`, push a new commit, and read the ref list of the mirror again with `git -C /tmp/scout.mirror remote update`. The mirror gains the new commit and keeps the old one.

## What you know now

A hosted repository needs a copy. A mirror or a bundle holds the full history, and a verify command checks it. Force pushes, deletions, rebases after publishing and content removal change history, and the host can block them. The cluster keeps a short list of deployed revisions, and artifact retention must match the history that a rollback may need.

## Common pitfalls

> [!WARNING]
> A mirror that nobody updates is a stale copy. Schedule the update and verify the copy, or the first time it is used will be during a failure.
