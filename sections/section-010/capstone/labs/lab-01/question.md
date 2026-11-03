# Question

Solve this question on: `terminal`

This is the Section 010 capstone. The repository `http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git` (from your machine: `http://127.0.0.1:3000/starfleet/scout-deploy.git`, user `platform`, password `starfleet-gitops`, readable without credentials) declares `scout` for two environments with a Kustomize base and the overlays `overlays/staging` and `overlays/production` on the branch `main`. Argo CD runs in the namespace `argocd`. No `Application` exists.

Deliver both environments from Git. The production overlay is broken and the base still contains a resource that was retired.

When you finish, these must be true:

1. The `Application` objects `scout-staging` and `scout-production` in `argocd` sync `overlays/staging` and `overlays/production` of the branch `main` into `starfleet-staging` and `starfleet-production` on the same cluster. Automated sync and `prune` are on, and Argo CD creates the namespaces.
2. The production overlay builds again. Production declares 3 replicas and the message `production`. Staging keeps the message `staging`.
3. The ConfigMap `legacy-banner` is retired. Remove it from Git (the base no longer lists it) so that it does not exist in either namespace.
4. Both `Application` objects are `Synced` and `Healthy`. A request from the `shuttle` pod (namespace `starfleet`) to `http://scout.starfleet-production/` returns the message `production`.

Do not use `kubectl apply -k` and do not delete the ConfigMap by hand. Check your work with `astrona submit`.
