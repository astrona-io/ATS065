---
draft: true
exam_objectives:
  - Pulled Automatically
---
# Verifying What Was Pulled

A pull-based agent fetches desired state on its own schedule. A team still needs to know which revision the cluster follows and whether it has applied it. This part shows where Argo CD and Flux record the answer, and how to tell a stale fetch from a failed apply.

## Three revisions

At any time there are three revisions to compare. The **head** is the newest commit on the branch in the Git server. The **fetched** revision is the commit that the agent last resolved for the branch. The **applied** revision is the commit whose manifests were last applied successfully. In a healthy loop they are equal. A difference between head and fetched means the fetch is late or failing. A difference between fetched and applied means the apply failed or is running.

## Argo CD

The fields of the `Application` show the revisions:

```sh
kubectl -n argocd get application scout-staging -o jsonpath='compared: {.status.sync.revision}{"\n"}applied: {.status.operationState.syncResult.revision}{"\n"}status: {.status.sync.status}{"\n"}'
```

`status.sync.revision` is the revision the last comparison used. `status.operationState.syncResult.revision` is the revision of the last sync. `status.reconciledAt` shows when the last comparison happened.

To read the head from the Git server without leaving the cluster, ask the remote directly:

```sh
git ls-remote http://127.0.0.1:3000/starfleet/scout-deploy.git refs/heads/main
```

If the compared revision equals this value and the status is `Synced`, the agent has pulled and applied the head.

## Flux

Flux keeps the fetched and the applied revision in two different objects. The `GitRepository` shows the artifact it fetched, and the `Kustomization` shows the revision it applied:

```sh
kubectl -n flux-system get gitrepository scout-deploy -o jsonpath='{.status.artifact.revision}{"\n"}'
kubectl -n flux-system get kustomization scout-staging -o jsonpath='{.status.lastAppliedRevision}{"\n"}'
```

With the `flux` command, `flux get sources git` and `flux get kustomizations` print the same fields with the ready state. Flux writes the revision as the branch name and the commit, for example `main@sha1:...`.

## Telling the cases apart

| Observation | Meaning | Next look |
| --- | --- | --- |
| Compared revision older than head | The fetch is late or failing | Conditions on the repository, credentials, network |
| Compared equals head, status `OutOfSync` | The apply is pending or failed | The last operation message |
| Compared equals head, status `Synced` | The cluster matches the head | Health status |

The loop gives the same answer in both tools: the revision is the evidence that desired state was pulled. A green status without a matching revision is not proof.

## Why this matters for the principle

The principle says the agent pulls the state. The check above is how a team confirms it. After an incident, the revision and the time in the record answer the question of what the cluster had been following at the time.

## Try it: compare head, compared and applied

<!-- astrona:playground:renew -->

Create the `Application` for the staging overlay with automated sync and wait for `Synced`. Read the three values:

```sh
git ls-remote http://127.0.0.1:3000/starfleet/scout-deploy.git refs/heads/main
kubectl -n argocd get application scout-staging -o jsonpath='{.status.sync.revision}{"\n"}{.status.operationState.syncResult.revision}{"\n"}'
```

They show the same commit. Push a new commit and read them again immediately. The head moves first. After the next refresh the compared and applied revisions follow. Ask for the refresh with `app_refresh scout-staging` to shorten the wait.

## What you know now

Head, fetched and applied revisions describe the state of a pull loop. Argo CD records them on the `Application`. Flux records them on the `GitRepository` and the `Kustomization`. A late fetch, a failed apply and a matching state each have a different record.

## Common pitfalls

> [!WARNING]
> Do not read `Synced` alone. It compares the revision the agent already fetched with the cluster. If the fetch is failing, the status can stay `Synced` at an old revision.
