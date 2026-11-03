# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-010/module-01/labs/lab-01
```

## Step 1: Declare the intent in Git

The replica count and the memory limit are part of the desired state, so they go into the repository. Clone it. The password for the user `platform` is `starfleet-gitops`:

```sh
git clone http://platform@127.0.0.1:3000/starfleet/scout-deploy.git
cd scout-deploy
```

Kustomize merges a patch file into the Deployment. Save this as `overlays/staging/resources.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scout
spec:
  template:
    spec:
      containers:
        - name: scout
          resources:
            limits:
              memory: 64Mi
```

Replace `overlays/staging/kustomization.yaml` so that it sets `count: 2` and lists the new patch. Save this as `overlays/staging/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: starfleet-staging
resources:
  - ../../base
labels:
  - pairs:
      environment: staging
images:
  - name: ghcr.io/stefanprodan/podinfo
    newTag: 6.15.0
replicas:
  - name: scout
    count: 2
patches:
  - path: message.yaml
  - path: resources.yaml
```

Check that the overlay renders before you commit it, then commit and push:

```sh
kubectl kustomize overlays/staging
git add -A
git commit -m "Staging: 2 replicas and a 64Mi memory limit"
git push origin main
```

`kubectl kustomize` prints the rendered Deployment with `replicas: 2` and `memory: 64Mi`. Nothing changes in the cluster yet, because no `Application` reads the repository.

## Step 2: Create the Application

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

Apply it:

```sh
kubectl apply -f application-scout-staging.yaml
```

Then check the result:

```sh
kubectl -n argocd get application scout-staging
kubectl -n starfleet-staging get deployment scout
```

The Application reaches `Synced` and `Healthy`, and the Deployment shows `2/2` ready. Run `astrona submit`: all three checks pass.

## Why this works

Argo CD reads the overlay from Git, renders it with Kustomize and applies the result. Because the live Deployment is created from Git, the values come from the repository and the `Application` stays `Synced`. If you had edited the live Deployment instead, the `Application` would be `OutOfSync` and the check `live-matches-git` would fail.
