# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-040/capstone/labs/lab-01
```

## Step 1: Create the parent Application

The parent `Application` points at a folder that contains `Application` manifests. Argo CD applies them like any other resource, so the children are created from Git. Save this as `application-starfleet-root.yaml`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: starfleet-root
  namespace: argocd
spec:
  project: default
  source:
    repoURL: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
    targetRevision: main
    path: apps
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

Apply it and list the `Application` objects:

```sh
kubectl apply -f application-starfleet-root.yaml
kubectl -n argocd get applications
```

The parent creates the three children. `scout-staging` and `scout-legacy` become `Synced`. `scout-production` shows a comparison error, because its path does not exist in the repository.

## Step 2: Read the condition and fix the path

Read the condition of the failing child:

```sh
kubectl -n argocd get application scout-production -o jsonpath='{.status.conditions[*].message}{"\n"}'
```

The message says that the path `overlays/prod` does not exist. The layer that failed is the child, not the parent, and the cause is in Git. Clone the repository and fix the manifest. The password for `platform` is `starfleet-gitops`:

```sh
git clone http://platform@127.0.0.1:3000/starfleet/scout-deploy.git
cd scout-deploy
```

In `apps/scout-production.yaml`, change `path: overlays/prod` to `path: overlays/production`.

## Step 3: Retire the legacy child

Delete the manifest in the same commit and push:

```sh
git rm apps/scout-legacy.yaml
git add -A
git commit -m "Fix the production path and remove scout-legacy"
git push origin main
```

The parent has `prune` on, so it deletes the child `Application` `scout-legacy` that no longer exists in Git. The child has the finalizer `resources-finalizer.argocd.argoproj.io`, so Argo CD removes its workload before the child disappears. To skip the wait, refresh the parent:

```sh
kubectl -n argocd annotate application starfleet-root argocd.argoproj.io/refresh=hard --overwrite
kubectl -n argocd get applications
```

Two children remain, both `Synced` and `Healthy`. Run `astrona submit`: all checks pass.
