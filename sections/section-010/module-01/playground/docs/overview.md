# Overview: Declared State And Rendering (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with Argo CD and a Git repository, and then waits. There is no task, no `astrona submit` and no pass or fail. Try something, look at what changed, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` is already pointed at it, as the cluster administrator. You need `git` and `jq` on your machine.
- Argo CD 3.5.4 in the namespace `argocd`. The web page is on `https://127.0.0.1:8080` and the initial admin password is in the Secret `argocd-initial-admin-secret`.
- A Git server in the namespace `gitea`, reachable from your machine on `http://127.0.0.1:3000` and from the cluster as `http://gitea-http.gitea.svc:3000`. The user `platform` (password `starfleet-gitops`) owns the organisation `starfleet`.
- The pod `shuttle` in `starfleet`, a client you can use to call the services: `kubectl -n starfleet exec deploy/shuttle -- curl -s http://scout.starfleet-staging/`.
- The repository `scout-deploy` with a Kustomize base and the overlays `overlays/staging` and `overlays/production`.
- The file `scripts/deploy.sh` in the repository: an imperative list of `kubectl` commands that does the same job as the declaration. It is there to compare, not to run on a schedule.
- No `Application` yet. Nothing is deployed in `starfleet-staging` or `starfleet-production`.

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

- Run `kubectl kustomize overlays/staging` in a clone and read what Argo CD would apply. Change the overlay, render again and compare.
- Create an `Application` for `overlays/staging` with automated sync and `prune: true`. Delete the Service file from the base in Git, push, and watch the Service disappear.
- Run the commands of `scripts/deploy.sh` once, then a second time. Write down which commands fail and what the script says about the state it expects afterwards.
- Add a ConfigMap to the base, push, and find out which tracking annotation Argo CD put on it: `kubectl -n starfleet-staging get configmap -o yaml`.
- Break the overlay on purpose (a patch file name that does not exist), push, and read the condition on the `Application`.
