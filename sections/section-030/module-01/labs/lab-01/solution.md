# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-030/module-01/labs/lab-01
```

## Step 1: Give Argo CD read access

The repository is private, so the Argo CD repository server needs a credential to clone it. Argo CD reads credentials from Secrets in its own namespace that carry the label `argocd.argoproj.io/secret-type: repository`. Use the read-only user: an agent that only pulls never needs write access. Save this as `secret-repo-scout-deploy.yaml`:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: repo-scout-deploy
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
  username: argocd-reader
  password: reader-pass-1
```

Apply it:

```sh
kubectl apply -f secret-repo-scout-deploy.yaml
```

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

Apply it and wait until it is synced:

```sh
kubectl apply -f application-scout-staging.yaml
kubectl -n argocd get application scout-staging
```

The `Application` reaches `Synced` and `Healthy`. The destination `https://kubernetes.default.svc` is the cluster that Argo CD itself runs in, so no cluster credential is created.

## Step 3: Change Git and let Argo CD pull it

Clone the repository with the write user. The password for the user `platform` is `starfleet-gitops`:

```sh
git clone http://platform@127.0.0.1:3000/starfleet/scout-deploy.git
cd scout-deploy
```

Save this as `overlays/staging/message.yaml`:

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
          env:
            - name: PODINFO_UI_MESSAGE
              value: pulled
```

Commit and push:

```sh
git add -A
git commit -m "Staging message: pulled"
git push origin main
```

Nothing pushes to the cluster. Argo CD finds the commit on its next check, about every three minutes. To skip the wait, ask the repository server to check now:

```sh
kubectl -n argocd annotate application scout-staging argocd.argoproj.io/refresh=hard --overwrite
```

Then check what `scout` serves:

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s http://scout.starfleet-staging/
```

The JSON answer contains `"message": "pulled"`. Run `astrona submit`: all three checks pass.
