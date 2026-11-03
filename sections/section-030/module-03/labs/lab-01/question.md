# Question

Solve this question on: `terminal`

The `Application` `scout-staging` in the namespace `argocd` delivers `overlays/staging` of `http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git` to the namespace `starfleet-staging`. It belongs to the project `default`, which allows every repository, destination and resource kind.

Limit the scout team to what it needs.

When you finish, these must be true:

- **Project**: an `AppProject` named `team-scout` exists in the namespace `argocd`. Its only source repository is `http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git`. Its only destination is the namespace `starfleet-staging` on the server `https://kubernetes.default.svc`. It allows no cluster-scoped resource kinds.
- **Application**: `scout-staging` belongs to the project `team-scout`, and it is `Synced` and `Healthy`.
- **Boundary**: the project does not list the namespace `starfleet-production` as a destination.

Check your work with `astrona submit`.
