# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-010/module-03/labs/lab-01
```

## Step 1: Read the layout

Clone the repository and compare the two overlays:

```sh
git clone http://platform:starfleet-gitops@127.0.0.1:3000/starfleet/scout-deploy.git
cd scout-deploy
diff overlays/staging/kustomization.yaml overlays/production/kustomization.yaml
cat overlays/staging/message.yaml
```

The staging overlay has a `patches` entry that points at `message.yaml`. The production overlay has the namespace, the label, the image tag and 2 replicas, but no message patch. The base ConfigMap sets the message `staging` for every environment.

## Step 2: Add the production message as an overlay patch

A variable set in `env` wins over the same variable from the ConfigMap that the container reads with `envFrom`. Create the patch file in the production folder:

```sh
cat > overlays/production/message.yaml <<'Y'
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
              value: production
Y
cat >> overlays/production/kustomization.yaml <<'Y'
patches:
  - path: message.yaml
Y
kubectl kustomize overlays/production | grep -A1 PODINFO_UI_MESSAGE
```

The render shows the value `production`. Commit and push:

```sh
git add -A
git commit -m "Set the production message in the overlay"
git push origin main
```

## Step 3: Create the Application for production

```sh
kubectl apply -f - <<'A'
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
    automated: {}
    syncOptions:
      - CreateNamespace=true
A
```

## Step 4: Check the result

```sh
kubectl -n argocd get applications
kubectl -n starfleet exec deploy/shuttle -- curl -s http://scout.starfleet-production/
kubectl -n starfleet exec deploy/shuttle -- curl -s http://scout.starfleet-staging/
```

Both `Application` objects are `Synced` and `Healthy`. The production service answers with the message `production` and the staging service with `staging`. Run `astrona submit`: all three checks pass.
