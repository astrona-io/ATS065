# Question

Solve this question on: `terminal`

The `Application` `scout-staging` in the namespace `argocd` delivers `overlays/staging` of `http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git` (branch `main`) to `starfleet-staging`. It is `Synced`, but it is not `Healthy`: the Deployment `scout` never becomes ready. The Git user is `platform` with the password `starfleet-gitops`.

Find out why the Deployment is not ready and fix the cause in Git. The team also wants the ConfigMap `scout-settings` to be applied before the Deployment, and failed syncs to be retried. Do not edit the live Deployment.

When you finish, these must be true:

- **Fix**: the `Application` is `Synced` at the head commit of `main` and `Healthy`. The Deployment runs `ghcr.io/stefanprodan/podinfo:6.15.0` and the service in `starfleet-staging` answers with the message `staging`.
- **Order**: the ConfigMap `scout-settings` has the sync wave `-1`. The change comes from Git.
- **Retry**: the `Application` retries a failed sync up to 5 times, with a backoff that starts at `10s`, has the factor `2` and stops growing at `3m`. Automated sync stays on.

Check your work with `astrona submit`.
