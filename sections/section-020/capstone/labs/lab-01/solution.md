# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-020/capstone/labs/lab-01
```

## Step 1: Tag the release

Clone the repository, read the history and find the commit that carries release 1.2. The password for the user `platform` is `starfleet-gitops`:

```sh
git clone http://platform@127.0.0.1:3000/starfleet/scout-deploy.git
cd scout-deploy
git log --oneline --decorate
```

The newest commit is `Release 1.2 with podinfo 6.15.0` and has no tag. Create the tag on it and push the tag:

```sh
git tag v1.2.0
git push origin v1.2.0
```

A tag is a name for one commit. Its commit ID never changes, so production will always receive exactly this content.

## Step 2: Create the staging Application

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

## Step 3: Create the production Application on the tag

Save this as `application-scout-production.yaml`. Only the name, the revision, the path and the namespace differ:

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
    targetRevision: v1.2.0
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

Apply it and check both:

```sh
kubectl apply -f application-scout-production.yaml
kubectl -n argocd get applications
```

Both reach `Synced` and `Healthy`. The status field `status.sync.revision` of `scout-production` holds the commit ID that the tag points at. Run `astrona submit`: all checks pass.
