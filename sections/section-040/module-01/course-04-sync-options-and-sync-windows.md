---
draft: true
exam_objectives:
  - Continuously Reconciled
---
# Sync Options And Sync Windows

Continuous reconciliation does not mean that every change must apply at once. Teams limit when and how a sync may happen. This part covers the sync options that change how Argo CD applies objects, and the sync windows that decide when a sync is allowed.

## Sync options

Sync options are strings in `spec.syncPolicy.syncOptions` of an `Application`. They change the behavior of the sync for that application. The common ones are listed here.

| Option | Effect |
| --- | --- |
| `CreateNamespace=true` | Creates the destination namespace if it is missing |
| `PruneLast=true` | Deletes pruned objects after the other objects are healthy |
| `ApplyOutOfSyncOnly=true` | Applies only the objects that differ |
| `ServerSideApply=true` | Uses server-side apply for the sync |
| `Replace=true` | Replaces objects instead of patching them |
| `RespectIgnoreDifferences=true` | Keeps ignored fields out of the applied object |
| `Prune=false` | On one object, never prune it |

Options can also be set on a single object with the annotation `argocd.argoproj.io/sync-options`, for example `Prune=false` on a volume claim. Several options on one object are separated by commas.

`Replace=true` deserves care. It uses `kubectl replace`, which overwrites the whole object, so fields written by other controllers are lost.

## Sync windows

A **sync window** is a time range that allows or denies syncs. Windows are part of an `AppProject`, under `spec.syncWindows`. Each window has a kind, a schedule, a duration and a selector.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: scout
  namespace: argocd
spec:
  sourceRepos:
    - "*"
  destinations:
    - namespace: "*"
      server: https://kubernetes.default.svc
  syncWindows:
    - kind: deny
      schedule: "0 8 * * 1-5"
      duration: 10h
      applications:
        - "scout-*"
      manualSync: false
```

The window above denies syncs from 08:00 for ten hours on weekdays for applications whose names start with `scout-`. The schedule is a cron expression and is read in UTC unless the window sets `timeZone`. A `deny` window blocks syncs. An `allow` window permits syncs only in its range. When both kinds apply, a deny window wins.

The field `manualSync` decides whether a person may still start a sync inside the window. With `manualSync: true` on an allow window, manual syncs are always possible.

## What a window does not do

A window blocks the sync. It does not stop the comparison. During a deny window the `Application` still becomes `OutOfSync` when Git changes, and the reconciliation resumes when the window ends. This keeps the information current while holding back the change.

Self-heal during a deny window is also blocked. A live change stays in place until the window opens.

## Try it: block a sync with a window

<!-- astrona:playground:renew -->

Create an `Application` with automated sync in the project `default` and wait for `Synced`. Add a deny window to the default project that covers every time of day for this application:

```sh
kubectl -n argocd patch appproject default --type merge -p '{"spec":{"syncWindows":[{"kind":"deny","schedule":"* * * * *","duration":"1h","applications":["scout-staging"],"manualSync":false}]}}'
```

Push a commit that changes the message in the staging overlay and refresh:

```sh
app_refresh scout-staging
app_status
```

The `Application` becomes `OutOfSync` and the sync does not start. Remove the window to let it run:

```sh
kubectl -n argocd patch appproject default --type json -p '[{"op":"remove","path":"/spec/syncWindows"}]'
```

The next reconciliation applies the commit.

## What you know now

Sync options adjust how the sync applies objects, at the level of the application or of one object. Sync windows in an `AppProject` allow or deny syncs by schedule while the comparison continues. A deny window wins, and it holds back self-heal as well.

## Common pitfalls

> [!WARNING]
> A deny window also blocks an emergency fix unless `manualSync` is true on a window that covers it. Decide the emergency path before the window is needed.
