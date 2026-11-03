# Overview: Commits, Tags And Rollback (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with Argo CD and a Git repository, and then waits. There is no task, no `astrona submit` and no pass or fail. Try something, look at what changed, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` is already pointed at it, as the cluster administrator. You need `git` and `jq` on your machine.
- Argo CD 3.5.4 in the namespace `argocd`. The web page is on `https://127.0.0.1:8080` and the initial admin password is in the Secret `argocd-initial-admin-secret`.
- A Git server in the namespace `gitea`, reachable from your machine on `http://127.0.0.1:3000` and from the cluster as `http://gitea-http.gitea.svc:3000`. The user `platform` (password `starfleet-gitops`) owns the organisation `starfleet`.
- The pod `shuttle` in `starfleet`, a client you can use to call the services: `kubectl -n starfleet exec deploy/shuttle -- curl -s http://scout.starfleet-staging/`.
- The repository `scout-deploy` with three commits and two tags: `v1.0.0` (message `Release 1.0 with podinfo 6.14.0`) and `v1.1.0` (changes the message). The newest commit on `main` has no tag and uses podinfo 6.15.0.
- No `Application` yet.

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

- Create an `Application` that sets `targetRevision: v1.0.0`. Read `status.sync.revision` and compare it with the commit of the tag (`git rev-parse v1.0.0`).
- Change `targetRevision` to `main` and watch the new commit arrive. Run `git log --oneline` in a clone and match each commit to a state.
- Roll back with `git revert` of the newest commit and push. Check that the history keeps both commits.
- Move the tag `v1.0.0` to another commit (`git tag -f`, `git push -f origin v1.0.0`) and find out how long Argo CD needs to notice. Decide why a moving tag is a weak pin.
- Compare `kubectl -n starfleet-staging get deployment scout -o yaml` with the Git file and find the field that shows the image.
