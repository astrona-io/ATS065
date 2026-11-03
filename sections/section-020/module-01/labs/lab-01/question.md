# Question

Solve this question on: `terminal`

The Argo CD `Application` `scout-staging` follows the branch `main` of the repository `http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git` (from your machine: `http://127.0.0.1:3000/starfleet/scout-deploy.git`, user `platform`, password `starfleet-gitops`) and has automated sync with self-heal. The newest commit on `main`, `Release 6.99.9`, set an image tag that does not exist. The `scout` Deployment in `starfleet-staging` cannot start and the `Application` is not healthy.

Roll back to the last good release by changing Git, not the cluster. Keep the audit trail: the bad commit must stay in the history, and nobody may rewrite the history of `main`.

When you finish, these must be true:

- **Application**: `scout-staging` is unchanged: it still follows `main` with automated sync.
- **History**: the commit `Release 6.99.9` is still in the history of `main`, and the newest commit on `main` is a revert of it. Do not use a force push.
- **Result**:
  - The Deployment `scout` in `starfleet-staging` runs `ghcr.io/stefanprodan/podinfo:6.15.0`.
  - The `Application` is `Synced` and `Healthy`.

Check your work with `astrona submit`.
