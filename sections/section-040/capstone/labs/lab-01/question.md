# Question

Solve this question on: `terminal`

This is the Section 040 capstone. The repository `http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git` (from your machine: `http://127.0.0.1:3000/starfleet/scout-deploy.git`, user `platform`, password `starfleet-gitops`, readable without credentials) holds the `scout` overlays and an `apps` folder with three child `Application` manifests: `scout-staging`, `scout-production` and `scout-legacy`. Argo CD runs in the namespace `argocd`. Nothing is deployed yet.

Bring the cluster up from one parent `Application` (the app-of-apps pattern), fix what is broken in Git and retire what is obsolete.

When you finish, these must be true:

1. The `Application` `starfleet-root` in `argocd` syncs the folder `apps` of the branch `main` into the namespace `argocd` on the same cluster, with automated sync, `prune` and `selfHeal` on.
2. The children `scout-staging` and `scout-production` exist, were created by `starfleet-root` (not applied by hand), and are `Synced` and `Healthy`. `scout-production` reads the path `overlays/production`. One child manifest in Git has a wrong path: fix it in Git.
3. `scout-legacy` is obsolete. Remove its manifest from Git so that the parent prunes the child `Application` and its workload. The `Application` `scout-legacy` and the Deployment `scout` in `starfleet-legacy` must not exist.

Do not create or edit the child `Application` objects with `kubectl`. Check your work with `astrona submit`.
