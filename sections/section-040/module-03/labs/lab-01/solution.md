# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-040/module-03/labs/lab-01
```

## Step 1: Read the starting state

```sh
kubectl -n argocd get applications,applicationsets
kubectl get crd applicationsets.argoproj.io
```

There is no `Application` and no `ApplicationSet`. The custom resource definition for `ApplicationSet` exists, because it is part of the Argo CD installation.

## Step 2: Create the ApplicationSet

```sh
kubectl apply -f - <<'Y'
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: scout
  namespace: argocd
spec:
  goTemplate: true
  generators:
    - list:
        elements:
          - env: staging
          - env: production
  template:
    metadata:
      name: 'scout-{{ .env }}'
    spec:
      project: default
      source:
        repoURL: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
        targetRevision: main
        path: 'overlays/{{ .env }}'
      destination:
        server: https://kubernetes.default.svc
        namespace: 'starfleet-{{ .env }}'
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
          - CreateNamespace=true
          - PruneLast=true
Y
```

The list generator has one element per environment. The template uses `{{ .env }}` in the name, the path and the namespace. The sync options keep namespace creation and put deletion of removed objects last.

## Step 3: Watch the applications appear

```sh
kubectl -n argocd get applicationset scout
kubectl -n argocd get applications
```

The controller creates `scout-staging` and `scout-production`. Wait until both are `Synced` and `Healthy`.

## Step 4: Check the result

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s http://scout.starfleet-staging/
kubectl -n starfleet exec deploy/shuttle -- curl -s http://scout.starfleet-production/
```

Each service answers with the message of its environment. Run `astrona submit`: all three checks pass.
