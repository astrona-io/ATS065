# Question

Solve this question on: `terminal`

The `Application` `scout-staging` in the namespace `argocd` delivers `overlays/staging` of `http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git` (branch `main`) to `starfleet-staging`. It has automated sync without `selfHeal`. Someone changed the live Deployment by hand: the image is `ghcr.io/stefanprodan/podinfo:6.14.0` instead of `6.15.0` and the replica count is 3 instead of 1. The `Application` is `OutOfSync`.

The replica count of 3 is set on purpose by the autoscaling team and Argo CD must leave it alone. The image change is a mistake and Argo CD must revert it. Fix this by editing the `Application`. Do not change Git, and do not edit the live Deployment.

When you finish, these must be true:

- **Sync policy**: automated sync has `prune` and `selfHeal` both `true`, and the sync option `RespectIgnoreDifferences=true` is set.
- **Ignore rule**: the `Application` has exactly one `ignoreDifferences` entry. It covers only the field `/spec/replicas` of the Deployment `scout` (group `apps`).
- **Result**:
  - The image of `scout` is `ghcr.io/stefanprodan/podinfo:6.15.0` again.
  - The replica count stays at 3.
  - The `Application` is `Synced`.

Check your work with `astrona submit`.
