# Question

Solve this question on: `terminal`

The `Application` `scout-staging` in the namespace `argocd` follows the branch `main` of `http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git` (path `overlays/staging`, destination `starfleet-staging`) with automated sync. The Git user is `platform` with the password `starfleet-gitops`.

The latest release on `main` is bad: the Deployment `scout` does not become ready. The team keeps its history, so nobody may rewrite it.

Roll the release back through Git.

When you finish, these must be true:

- **History kept**: all earlier commits are still on `main`, including the bad release, and the head of `main` is a new commit on top of them.
- **Restored**: the `Application` is `Synced` at the head commit of `main` and `Healthy`. The Deployment runs `ghcr.io/stefanprodan/podinfo:6.15.0`.
- **Marked**: the annotated tag `known-good` points at the head commit of `main`.

Check your work with `astrona submit`.
