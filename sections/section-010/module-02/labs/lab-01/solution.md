# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-010/module-02/labs/lab-01
```

## Step 1: Read the chart defaults

A Helm chart takes its settings from `values.yaml`. Argo CD renders the chart with `helm template`, so any value you pass overrides the default. Read the chart in the repository to see which keys exist:

```sh
git clone http://platform:starfleet-gitops@127.0.0.1:3000/starfleet/scout-deploy.git
cat scout-deploy/charts/scout/values.yaml
```

The keys are `replicaCount`, `image.repository`, `image.tag` and `message`.

## Step 2: Declare the values on the Application

The field `spec.source.helm.valuesObject` holds values as YAML. Argo CD merges them over the chart defaults. Save this as `application-scout-helm.yaml`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: scout-helm
  namespace: argocd
spec:
  project: default
  source:
    repoURL: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
    targetRevision: main
    path: charts/scout
    helm:
      valuesObject:
        replicaCount: 2
        image:
          tag: "6.15.0"
        message: helm-staging
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
kubectl apply -f application-scout-helm.yaml
```

## Step 3: Check the result

Wait for the sync and read the status and the service:

```sh
kubectl -n argocd get application scout-helm
kubectl -n starfleet exec deploy/shuttle -- curl -s http://scout.starfleet-staging/
```

The `Application` becomes `Synced` and `Healthy`. The Deployment has two replicas and the image `6.15.0`, and the service answers with a JSON document that holds the message `helm-staging`. Run `astrona submit`: all three checks pass.
