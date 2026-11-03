# Overview: Pull, Credentials And Webhooks (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with Argo CD and a Git repository, and then waits. There is no task, no `astrona submit` and no pass or fail. Try something, look at what changed, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` is already pointed at it, as the cluster administrator. You need `git` and `jq` on your machine.
- Argo CD 3.5.4 in the namespace `argocd`. The web page is on `https://127.0.0.1:8080` and the initial admin password is in the Secret `argocd-initial-admin-secret`.
- A Git server in the namespace `gitea`, reachable from your machine on `http://127.0.0.1:3000` and from the cluster as `http://gitea-http.gitea.svc:3000`. The user `platform` (password `starfleet-gitops`) owns the organisation `starfleet`.
- The pod `shuttle` in `starfleet`, a client you can use to call the services: `kubectl -n starfleet exec deploy/shuttle -- curl -s http://scout.starfleet-staging/`.
- A private repository `scout-deploy`. Two users exist: `platform` (password `starfleet-gitops`) writes, `argocd-reader` (password `reader-pass-1`) reads only.
- No repository credential and no `Application` yet. The Argo CD repository server cannot clone the repository until you add a credential.

## Helpers

Paste these once in each new terminal. `git_clone` clones the repository. `app_status` lists every `Application` with its sync status, health and revision. `app_refresh` asks Argo CD to compare again now.

```sh
git_clone() {
  git clone http://platform:starfleet-gitops@127.0.0.1:3000/starfleet/scout-deploy.git "${1:-scout-deploy}"
}
app_status() {
  kubectl -n argocd get applications -o custom-columns=NAME:.metadata.name,SYNC:.status.sync.status,HEALTH:.status.health.status,REVISION:.status.sync.revision
}
app_refresh() {
  kubectl -n argocd annotate application "$1" argocd.argoproj.io/refresh=hard --overwrite
}
```

## Practice tasks

- Create an `Application` before you add a credential and read the error condition. Then add a repository Secret for `argocd-reader` and watch the error disappear.
- Try the same Secret with a wrong password. Read the condition and decide which layer failed: Git server, credential or `Application`.
- Push a commit and time how long Argo CD needs to find it. Then run `kubectl -n argocd annotate application <name> argocd.argoproj.io/refresh=hard --overwrite` and compare.
- Stop the Git server (`kubectl -n gitea scale deploy/gitea --replicas=0`). Check that the workload keeps running and that the `Application` reports a comparison error. Scale it back and watch the recovery.
- Add a Gitea push webhook to `https://argocd-server.argocd.svc/api/webhook` and measure again.
