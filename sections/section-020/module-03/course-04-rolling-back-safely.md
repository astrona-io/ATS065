---
draft: true
exam_objectives:
  - Versioned and Immutable
---
# Rolling Back Safely

Some releases fail. The speed and safety of the recovery depend on what the team prepared. This part explains the ways to go back, why a revert commit is the default in GitOps, and when going forward is the safer choice.

## Revert: go back by adding history

`git revert <commit>` creates a new commit that undoes the changes of an earlier one. The failed release stays in the history, followed by the revert. The agent applies the new commit like any other. The record shows what happened, and the rollback goes through the same review and checks as a release.

```sh
git revert --no-edit HEAD
git push origin main
```

To revert a merge commit, name the parent that should stay as the main line, for example `git revert -m 1 <merge>`. Without `-m` Git refuses, because it cannot know which side to keep.

## Reset: go back by removing history

`git reset --hard <good>` followed by a force push moves the branch back and removes the bad commit from it. This hides the failed release, breaks clones that already have it and is blocked on protected branches. It is a last resort and not a rollback procedure.

## Rollback in the tool

Argo CD can deploy an earlier revision from `status.history` with `argocd app rollback`. It works only when automated sync is off, because automated sync would immediately apply Git again. The rolled back state exists only in the cluster, and Git still names the bad version. After the incident, Git must be fixed to match, or the next sync restores the failure.

Flux has no rollback command. The way back is a commit. Helm releases managed by the Flux Helm controller can roll back automatically on failed upgrades through the remediation settings of the `HelmRelease`.

## Roll forward

If the fix is small and known, a new commit that fixes the problem is faster than undoing the release. This is also needed when a rollback is unsafe. A release that migrated a database schema may not run on the old schema. A release that changed a message format may break consumers that already moved. In these cases the rollback plan is written before the release, and the release is designed so that the previous version still works with the new data. This is called a backward compatible change.

## Prepare for recovery

A team can prepare in four ways.

Keep the previous good image in the registry, so a revert has something to deploy.

Use health checks, so a failed release is visible. A Deployment that does not become ready stays `Progressing` or `Degraded` and keeps the old pods running until new ones are ready.

Keep the last known good revision marked, for example with an annotated tag such as `known-good`, so the target is clear under pressure.

Practise the rollback in a non-production environment.

## Try it: revert a bad release

<!-- astrona:playground:renew -->

Create an `Application` for the staging overlay with automated sync. Push a bad release and then revert it:

```sh
git_clone
cd scout-deploy
sed -i.bak 's/newTag: 6.15.0/newTag: 6.99.0/' overlays/staging/kustomization.yaml
rm overlays/staging/kustomization.yaml.bak
git commit -am "Release 6.99.0 to staging"
git push origin main
app_refresh scout-staging
app_status
```

The Deployment does not become ready, because the image tag does not exist. Revert:

```sh
git revert --no-edit HEAD
git push origin main
app_refresh scout-staging
git log --oneline -3
```

The log shows three commits: the original, the bad release and the revert. The `Application` becomes healthy again, and nothing was removed from the history.

## What you know now

A revert commit is the default rollback, because it keeps history and uses the normal path. A reset hides the failure and is a last resort. The tool rollback of Argo CD works only without automated sync and leaves Git unchanged. When a rollback is unsafe, roll forward, and plan the release so the old version can still run.

## Common pitfalls

> [!WARNING]
> A rollback that exists only in the cluster is lost at the next sync. Always make Git say the same thing as the cluster.
