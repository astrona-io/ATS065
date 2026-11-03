# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-010/capstone/labs/lab-01
```

## Step 1: Render the overlays before you commit

Clone the repository. The password for the user `platform` is `starfleet-gitops`:

```sh
git clone http://platform@127.0.0.1:3000/starfleet/scout-deploy.git
cd scout-deploy
kubectl kustomize overlays/staging
kubectl kustomize overlays/production
```

Rendering the staging overlay prints the Deployment, the Service and the ConfigMap `legacy-banner`. Rendering the production overlay fails, because its `kustomization.yaml` lists `message.yaml` as a patch and the file in the folder is called `message-prod.yaml`. This is the same error that Argo CD would show in the `Application` condition.

## Step 2: Fix the repository

Rename the patch file and set 3 replicas. Save this as `overlays/production/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: starfleet-production
resources:
  - ../../base
labels:
  - pairs:
      environment: production
images:
  - name: ghcr.io/stefanprodan/podinfo
    newTag: 6.15.0
replicas:
  - name: scout
    count: 3
patches:
  - path: message.yaml
```

Rename the patch file, remove the retired ConfigMap and remove it from the base list:

```sh
git mv overlays/production/message-prod.yaml overlays/production/message.yaml
git rm base/legacy-banner.yaml
```

Save this as `base/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
  - service.yaml
labels:
  - pairs:
      app.kubernetes.io/part-of: starfleet
```

Render again to check, then commit and push:

```sh
kubectl kustomize overlays/production
git add -A
git commit -m "Fix the production overlay and retire legacy-banner"
git push origin main
```

## Step 3: Create the two Applications

Save this as `application-scout-staging.yaml`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: scout-staging
  namespace: argocd
spec:
  project: default
  source:
    repoURL: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
    targetRevision: main
    path: overlays/staging
  destination:
    server: https://kubernetes.default.svc
    namespace: starfleet-staging
  syncPolicy:
    automated:
      prune: true
    syncOptions:
      - CreateNamespace=true
```

Save this as `application-scout-production.yaml`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: scout-production
  namespace: argocd
spec:
  project: default
  source:
    repoURL: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
    targetRevision: main
    path: overlays/production
  destination:
    server: https://kubernetes.default.svc
    namespace: starfleet-production
  syncPolicy:
    automated:
      prune: true
    syncOptions:
      - CreateNamespace=true
```

Apply both and check:

```sh
kubectl apply -f application-scout-staging.yaml -f application-scout-production.yaml
kubectl -n argocd get applications
```

Both reach `Synced` and `Healthy`. The ConfigMap `legacy-banner` is never created, because no commit that Argo CD reads still contains it. If you create the Applications first and fix Git afterwards, Argo CD creates it in staging first and prunes it after the fix, because `prune` is on. Run `astrona submit`: all checks pass.
