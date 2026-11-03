---
draft: true
exam_objectives:
  - Versioned and Immutable
---
# Rewriting History

The audit record assumes that commits stay where they are. Git can break that assumption. This part explains which commands rewrite history, what a force push does to the branch the agent follows, and how Argo CD keeps its own record of what it deployed.

## Commands that rewrite

A commit cannot be edited, because its id depends on its content. A rewrite creates new commits and moves a branch to them. `git commit --amend` replaces the last commit. `git rebase` replays commits on a new base, and `git rebase -i` also lets you drop, reorder and squash them. `git reset --hard COMMIT` moves the branch to an older commit.

These commands change only your local branch. The remote branch changes when you push. If the new branch does not contain the old tip, a normal `git push` is refused. The refusal is the protection. `git push --force` overrides it, and `git push --force-with-lease` overrides it only when the remote branch is still at the commit you last fetched.

## What happens to the old commits

The old commits are not deleted at once. They no longer belong to any branch, so they are **unreachable**. A local `git reflog` lists where the branch pointed earlier, and the old commits remain until Git removes them in garbage collection. On a remote server, there is no reflog for users. The server may keep the objects for some time, but a user cannot count on that.

A force push therefore removes the old commits from the visible history. Everything that referred to them by id, such as a ticket, an audit report or the `Application` status, now points at a commit that is not on the branch.

## What the agent does

When Argo CD follows a branch, it resolves the branch name to the commit at its tip on each refresh. After a force push, the tip is a new commit that is not a descendant of the old tip. Argo CD does not check that. It renders the new tip and syncs it, with no error. The cluster follows the rewritten branch.

This means a rewrite can move the cluster in a way that a normal push would have to show as a new commit on top of the old history. If the rewrite drops a commit, the change that commit made is removed from the desired state, and the agent removes it from the cluster.

## The record the agent keeps

Argo CD stores the revisions it deployed in `status.history` of the `Application`. Each entry has the revision, the time and the sequence id. The number of entries is limited by `spec.revisionHistoryLimit`, which defaults to 10. This list survives a rewrite, so the commit ids that were deployed are still known even when the branch no longer contains them.

```sh
kubectl -n argocd get application scout-staging -o jsonpath='{range .status.history[*]}{.id} {.revision} {.deployedAt}{"\n"}{end}'
```

The deployment history in the `Application` is not a replacement for Git. It holds ids and times, not the author and message, and only a limited number of entries.

## Roll back without rewriting

The safe way to undo a change is a new commit that reverses it: `git revert COMMIT`. The history keeps both the original change and its reversal, and each has an author and a reason. A reset and force push gives the same cluster state and hides the story.

## Prevention

Protect the branch against force pushes, as described in the previous part. Keep the settings of the Git host under review. If a rewrite is unavoidable, for example to remove a secret that was committed by mistake, treat it as an incident: tell the team, rotate the secret because the old commit may exist in clones, and record what was done.

## Try it: force push and watch the revision

<!-- astrona:playground:renew -->

Create an `Application` that follows `main` and wait for `Synced`. Save this as `application-scout-staging.yaml`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: scout-staging
  namespace: argocd
spec:
  project: default
  source:
    repoURL: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
    targetRevision: main
    path: overlays/staging
  destination:
    server: https://kubernetes.default.svc
    namespace: starfleet-staging
  syncPolicy:
    automated: {}
    syncOptions:
      - CreateNamespace=true
```

Apply it:

```sh
kubectl apply -f application-scout-staging.yaml
app_status
```

Record the revision. Now rewrite the newest commit and force push:

```sh
git_clone
cd scout-deploy
git commit --amend -m "Reworded message for the newest commit"
git push --force origin main
app_refresh scout-staging
app_status
```

The revision shown by `app_status` is a different commit id, even though the files are the same. Argo CD followed the branch to the new tip. Read the deployment history:

```sh
kubectl -n argocd get application scout-staging -o jsonpath='{range .status.history[*]}{.id} {.revision}{"\n"}{end}'
```

The old commit id may still appear in the history list, although it is no longer on `main`. Check with `git branch --contains OLDID`; the command finds no branch. Use `git reflog` in your clone to find the old tip.

## What you know now

Rewriting creates new commits and moves the branch, and a force push makes the old commits unreachable. Argo CD follows the new tip without warning and keeps only a limited list of deployed revisions. A revert commit undoes a change and keeps the story, and branch protection prevents the rewrite. That closes the module: the history is useful for audit only when it is complete, signed where needed, reviewed and protected.

## Common pitfalls

> [!WARNING]
> A force push to the tracked branch changes production without a new change on top of the old history. Disable force pushes on the branch, and use `git revert` to undo a change.
