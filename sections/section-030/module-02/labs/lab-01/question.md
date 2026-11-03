# Question

Solve this question on: `terminal`

Argo CD runs in the namespace `argocd`. The repository `http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git` (branch `main`) holds a Kustomize overlay for staging in the folder `overlays/staging`. Your team lead asks for two things: staging delivered by pull, and a short report on which Argo CD component does which job and how much the controller may do in the cluster.

Create an `Application` named `scout-staging` in the namespace `argocd` that pulls `overlays/staging` from `main` into the namespace `starfleet-staging` with automated sync. Then create a ConfigMap named `agent-report` in the namespace `starfleet`. Read the answers from the cluster, do not guess them.

When you finish, these must be true:

- **Application**: `scout-staging` uses the project `default`, the path `overlays/staging`, the revision `main`, the destination namespace `starfleet-staging` and automated sync.
- **Report**: the ConfigMap `agent-report` has these keys:
  - `render-component`: the name of the workload that clones the repository and renders the manifests.
  - `controller-component`: the name of the workload that compares desired and live state and applies changes.
  - `controller-kind`: the Kubernetes kind of that second workload (for example `Deployment`).
  - `can-delete-namespaces`: `yes` or `no`, whether the service account of the controller may delete namespaces.
- **Result**: the `Application` is `Synced` and `Healthy`, and the service in `starfleet-staging` answers with the message `staging`.

Check your work with `astrona submit`.
