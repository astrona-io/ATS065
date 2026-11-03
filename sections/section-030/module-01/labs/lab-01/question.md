# Question

Solve this question on: `terminal`

The platform team keeps the Kubernetes files for `scout` in a private Git repository: `http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git` (from your machine: `http://127.0.0.1:3000/starfleet/scout-deploy.git`). Two users exist. The user `platform` (password `starfleet-gitops`) can write to the repository. The user `argocd-reader` (password `reader-pass-1`) can only read it. Argo CD is installed in the namespace `argocd` and has no credentials for the repository and no `Application` yet.

Argo CD must pull the staging overlay from Git using the read-only user. Then a change to the staging message must reach the cluster by Argo CD pulling it, not by anyone applying it.

When you finish, these must be true:

- **Repository access**: Argo CD has a repository Secret in the namespace `argocd` for the repository URL above. It uses the user `argocd-reader`. No repository Secret uses the user `platform`.
- **Application** `scout-staging` in the namespace `argocd`:
  - It uses the project `default` and syncs the path `overlays/staging` of the branch `main` to the namespace `starfleet-staging` on the same cluster (`https://kubernetes.default.svc`).
  - Automated sync is on. Argo CD creates the namespace `starfleet-staging` for you.
- **Git**: a commit on `main` changes the message in `overlays/staging/message.yaml` from `staging` to `pulled`.
- **Result**:
  - A request from the `shuttle` pod (namespace `starfleet`) to `http://scout.starfleet-staging/` returns the message `pulled`.
  - The `Application` is `Synced` and `Healthy`, and `status.sync.revision` is the newest commit of `main`.
  - Argo CD has no cluster credential Secret (label `argocd.argoproj.io/secret-type=cluster`).

Check your work with `astrona submit`.
