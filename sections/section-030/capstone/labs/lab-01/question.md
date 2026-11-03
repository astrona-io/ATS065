# Question

Solve this question on: `terminal`

This is the Section 030 capstone. The private repository `http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git` (from your machine: `http://127.0.0.1:3000/starfleet/scout-deploy.git`) holds the manifests for `scout`. The user `platform` (password `starfleet-gitops`) can write to it. The user `argocd-reader` (password `reader-pass-1`) can only read it. Argo CD runs in the namespace `argocd` with no repository credentials and no `Application`.

Set up pull-based delivery of the production overlay, make the Git server tell Argo CD about new commits, and change the production replica count through Git.

When you finish, these must be true:

1. **Repository access**: Argo CD has a repository Secret for the repository URL above that uses the user `argocd-reader`. No repository Secret uses `platform`.
2. **Application** `scout-production` in `argocd`: project `default`, path `overlays/production` of the branch `main`, destination `https://kubernetes.default.svc` and namespace `starfleet-production` (created by Argo CD), automated sync with `prune` on.
3. **Webhook**: the repository has an active webhook of type Gitea for the `push` event that posts JSON to `https://argocd-server.argocd.svc/api/webhook`.
4. **Change through Git**: a commit on `main` sets the production replica count to `3` in `overlays/production/kustomization.yaml`. Nobody scales the live Deployment.
5. **Result**: the `Application` is `Synced` and `Healthy`, its `status.sync.revision` is the newest commit of `main`, and the Deployment `scout` in `starfleet-production` has 3 replicas.
6. **No push credentials**: Argo CD has no Secret with the label `argocd.argoproj.io/secret-type=cluster`.

Check your work with `astrona submit`.
