# Question

Solve this question on: `terminal`

The repository `http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git` (branch `main`) holds a Helm chart in the folder `charts/scout`. Its default values start one replica of the image `ghcr.io/stefanprodan/podinfo:6.14.0` with the message `default`. The chart must stay as it is in Git. The staging environment must run two replicas of the image tag `6.15.0` and answer with the message `helm-staging`.

Create an `Application` named `scout-helm` in the namespace `argocd` that renders the chart and declares these three values on the `Application` itself. Deliver the result to the namespace `starfleet-staging` with automated sync. Do not change Git, and do not edit the live Deployment.

When you finish, these must be true:

- **Application**: `scout-helm` uses the project `default`, the path `charts/scout`, the revision `main`, the destination namespace `starfleet-staging` and automated sync with `prune: true`.
- **Values**: the `Application` declares `replicaCount` 2, `image.tag` `6.15.0` and `message` `helm-staging` as Helm values. The chart default in Git is still `replicaCount: 1`.
- **Result**:
  - The `Application` is `Synced` and `Healthy`.
  - The Deployment `scout` has 2 ready replicas and the image `ghcr.io/stefanprodan/podinfo:6.15.0`.
  - The service `scout` in `starfleet-staging` answers with the message `helm-staging`.

Check your work with `astrona submit`.
