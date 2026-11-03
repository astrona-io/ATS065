# Question

Solve this question on: `terminal`

The repository `http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git` (branch `main`) has the Kustomize overlays `overlays/staging` and `overlays/production`. Argo CD runs in the namespace `argocd`. No `Application` exists yet.

Generate the environment applications from one `ApplicationSet` instead of writing each `Application` by hand.

When you finish, these must be true:

- **ApplicationSet**: an `ApplicationSet` named `scout` exists in the namespace `argocd`. It uses a list generator with the two environments `staging` and `production`, and its template names the applications `scout-<env>`.
- **Applications**: the generated `scout-staging` and `scout-production` deliver `overlays/<env>` to the namespace `starfleet-<env>`. Both use automated sync with prune and self-heal, and the sync options `CreateNamespace=true` and `PruneLast=true`. Both are `Synced` and `Healthy`.
- **Result**: the service in `starfleet-staging` answers with the message `staging` and the service in `starfleet-production` answers with the message `production`.

Check your work with `astrona submit`.
