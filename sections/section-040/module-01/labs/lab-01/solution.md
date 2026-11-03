# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-040/module-01/labs/lab-01
```

## Step 1: Read the drift

Look at the status and at the live Deployment:

```sh
kubectl -n argocd get application scout-staging
kubectl -n starfleet-staging get deployment scout -o jsonpath='{.spec.replicas} {.spec.template.spec.containers[0].image}{"\n"}'
```

The `Application` is `OutOfSync`. The Deployment shows 3 replicas and the image `6.14.0`. Automated sync without `selfHeal` only starts when the source changes, so the manual change stays.

## Step 2: Add the ignore rule and the sync policy

An ignore rule makes Argo CD skip a field when it compares desired and live state. The rule alone only affects the comparison. When a sync runs, Argo CD still applies the full desired manifest, which would set the replicas back to 1. The sync option `RespectIgnoreDifferences=true` makes the sync skip the ignored field as well. Save this as `application-scout-staging.yaml`:

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
  ignoreDifferences:
    - group: apps
      kind: Deployment
      name: scout
      jsonPointers:
        - /spec/replicas
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
      - RespectIgnoreDifferences=true
```

Apply it:

```sh
kubectl apply -f application-scout-staging.yaml
```

## Step 3: Check the result

Ask for a refresh so that Argo CD compares again, and read the Deployment:

```sh
kubectl -n argocd annotate application scout-staging argocd.argoproj.io/refresh=hard --overwrite
kubectl -n starfleet-staging get deployment scout -o jsonpath='{.spec.replicas} {.spec.template.spec.containers[0].image}{"\n"}'
```

After a short time the image is `ghcr.io/stefanprodan/podinfo:6.15.0` again and the replica count is still 3. The `Application` is `Synced`. Run `astrona submit`: all three checks pass.
