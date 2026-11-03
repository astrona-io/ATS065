# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-030/capstone/labs/lab-01
```

## Step 1: Repository access with the read-only user

Save this as `secret-repo-scout-deploy.yaml`:

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

## Step 2: The production Application

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

Apply it and check the status:

```sh
kubectl apply -f application-scout-production.yaml
kubectl -n argocd get application scout-production
```

The `Application` reaches `Synced` and `Healthy` with 2 replicas.

## Step 3: The webhook

A webhook is an HTTP request that the Git server sends when something happens in a repository. Argo CD uses the request only as a hint to refresh now. The Gitea web page is available at `http://127.0.0.1:3000`. Sign in as `platform`, open the repository `starfleet/scout-deploy`, then Settings, Webhooks, and add a Gitea webhook with these values: target URL `https://argocd-server.argocd.svc/api/webhook`, content type `application/json`, trigger on push events, active. The Git server runs inside the cluster, so it reaches `argocd-server` by its Service name. It accepts the Argo CD self-signed certificate because the lab sets `GITEA__webhook__SKIP_TLS_VERIFY` to `true`.

## Step 4: Change the replica count in Git

Clone the repository with the write user. The password for `platform` is `starfleet-gitops`:

```sh
git clone http://platform@127.0.0.1:3000/starfleet/scout-deploy.git
cd scout-deploy
```

In `overlays/production/kustomization.yaml`, change `count: 2` to `count: 3`, then commit and push:

```sh
git add -A
git commit -m "Production: 3 replicas"
git push origin main
```

The webhook sends a request to Argo CD, which refreshes the `Application`. If the webhook does not arrive, Argo CD still finds the commit on its next scheduled check. Then check the result:

```sh
kubectl -n starfleet-production get deployment scout
```

The Deployment shows `3/3` ready. Run `astrona submit`: all checks pass.
