# Question

Solve this question on: `terminal`

The platform team keeps the Kubernetes files for the `scout` application in a Git repository: `http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git` (from your machine: `http://127.0.0.1:3000/starfleet/scout-deploy.git`). The user is `platform` and the password is `starfleet-gitops`. The repository is readable without credentials. It has a Kustomize base and the overlays `overlays/staging` and `overlays/production` on the branch `main`. Argo CD is installed in the namespace `argocd`. No `Application` exists yet.

Staging must run two replicas of `scout`, and each container must have a memory limit of `64Mi`. These values must live in Git. Do not apply the overlay with `kubectl apply -k`, and do not edit the live Deployment.

When you finish, these must be true:

- **Application** `scout-staging` in the namespace `argocd`:
  - It uses the project `default` and syncs the path `overlays/staging` of the branch `main` to the namespace `starfleet-staging` on the same cluster.
  - Automated sync is on, with `prune` set to `true`.
  - Argo CD creates the namespace `starfleet-staging` for you.
- **Git**: the overlay `overlays/staging` on `main` declares 2 replicas and a memory limit of `64Mi` for the container `scout`.
- **Result**:
  - The `Application` is `Synced` and `Healthy`.
  - The Deployment `scout` in `starfleet-staging` has 2 ready replicas and a memory limit of `64Mi`.

Check your work with `astrona submit`.
