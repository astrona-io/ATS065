# Question

Solve this question on: `terminal`

The repository `http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git` (branch `main`, Git user `platform`, password `starfleet-gitops`) holds a Kustomize base and the overlays `overlays/staging` and `overlays/production`. The `Application` `scout-staging` delivers the staging overlay to `starfleet-staging`. Nothing delivers production yet.

Add the production environment. Use the shared base and change only what differs for production. Do not change the base and do not copy the base manifests.

When you finish, these must be true:

- **Layout**: the base still sets the message `staging`. The production overlay sets its own message through a patch in the overlay folder. The staging overlay is unchanged.
- **Application**: an `Application` named `scout-production` in the namespace `argocd` delivers `overlays/production` of the repository, branch `main`, to the namespace `starfleet-production`. Automated sync is on, and the `Application` is `Synced` at the head commit of `main` and `Healthy`.
- **Result**: the Deployment `scout` in `starfleet-production` has 2 ready replicas and the service answers with the message `production`. The service in `starfleet-staging` still answers with `staging`.

Check your work with `astrona submit`.
