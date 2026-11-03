# Question

Solve this question on: `terminal`

This is the Section 020 capstone. The repository `http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git` (from your machine: `http://127.0.0.1:3000/starfleet/scout-deploy.git`, user `platform`, password `starfleet-gitops`, readable without credentials) holds the release history of `scout`. The tags `v1.0.0` and `v1.1.0` mark released commits. The newest commit on `main`, `Release 1.2 with podinfo 6.15.0`, is tested but has no tag. Argo CD runs in the namespace `argocd`. No `Application` exists yet.

Release 1.2 passed its tests and must be promoted to production. Staging follows the branch, production follows a release tag only.

When you finish, these must be true:

1. The tag `v1.2.0` exists in the repository and points at the commit `Release 1.2 with podinfo 6.15.0`. Do not move any existing tag.
2. The `Application` `scout-staging` in `argocd` syncs `overlays/staging` from the branch `main` into the namespace `starfleet-staging`, with automated sync and `prune` on.
3. The `Application` `scout-production` in `argocd` syncs `overlays/production` from the tag `v1.2.0` (not from a branch or a commit ID) into the namespace `starfleet-production`, with automated sync and `prune` on.
4. Both namespaces are created by Argo CD. Both `Application` objects are `Synced` and `Healthy`.
5. A request from the `shuttle` pod (namespace `starfleet`) to `http://scout.starfleet-staging/` and to `http://scout.starfleet-production/` returns version `6.15.0` and the message `release 1.2`.
6. The `Application` `scout-production` applied exactly the commit that the tag `v1.2.0` points at.

Check your work with `astrona submit`.
