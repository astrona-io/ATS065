# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-030/module-03/labs/lab-01
```

## Step 1: Read the current state

```sh
kubectl -n argocd get application scout-staging -o jsonpath='{.spec.project}{"\n"}'
kubectl -n argocd get appproject default -o yaml
```

The project is `default`. The default project lists `*` as a source repository, `*` as a destination server and namespace, and allows all cluster-scoped kinds.

## Step 2: Create the project

```sh
kubectl apply -f - <<'P'
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: team-scout
  namespace: argocd
spec:
  description: The scout team
  sourceRepos:
    - http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
  destinations:
    - server: https://kubernetes.default.svc
      namespace: starfleet-staging
  clusterResourceWhitelist: []
P
```

The empty `clusterResourceWhitelist` allows no cluster-scoped kind. The namespace `starfleet-staging` already exists, so the `CreateNamespace` option of the `Application` does not need to create it again.

## Step 3: Move the Application into the project

```sh
kubectl -n argocd patch application scout-staging --type merge -p '{"spec":{"project":"team-scout"}}'
kubectl -n argocd get application scout-staging
```

The `Application` stays `Synced` and `Healthy`, because everything it asks for is allowed by the project.

## Step 4: Check the boundary

Ask for a namespace outside the project and read the condition:

```sh
kubectl -n argocd patch application scout-staging --type merge -p '{"spec":{"destination":{"namespace":"starfleet-production"}}}'
kubectl -n argocd get application scout-staging -o jsonpath='{range .status.conditions[*]}{.type}: {.message}{"\n"}{end}'
kubectl -n argocd patch application scout-staging --type merge -p '{"spec":{"destination":{"namespace":"starfleet-staging"}}}'
```

The condition reports that the destination is not permitted in the project. The last command restores the destination. Wait until the `Application` is `Synced` and `Healthy`, then run `astrona submit`: all three checks pass.
