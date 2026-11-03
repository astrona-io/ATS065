# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-030/module-02/labs/lab-01
```

## Step 1: Create the Application

The agent pulls from Git, so you do not push anything to the cluster yourself. You only declare the source and the destination. Save this as `application-scout-staging.yaml`:

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
    automated: {}
    syncOptions:
      - CreateNamespace=true
```

```sh
kubectl apply -f application-scout-staging.yaml
```

## Step 2: Read the components

List the Argo CD workloads:

```sh
kubectl -n argocd get deploy,statefulset
```

The repository server is the Deployment `argocd-repo-server`. It clones the repository and renders Kustomize, Helm or plain YAML. The application controller is the StatefulSet `argocd-application-controller`. It compares the rendered manifests with the live objects and applies the difference.

## Step 3: Read the permission

Ask the API server what the controller service account may do:

```sh
kubectl auth can-i delete namespaces --as=system:serviceaccount:argocd:argocd-application-controller
```

The default cluster-wide installation gives the controller a ClusterRole that allows every verb on every resource, so the answer is `yes`. A namespaced installation or a restricted role would give `no`.

## Step 4: Write the report

```sh
can=$(kubectl auth can-i delete namespaces --as=system:serviceaccount:argocd:argocd-application-controller)
kubectl -n starfleet create configmap agent-report \
  --from-literal=render-component=argocd-repo-server \
  --from-literal=controller-component=argocd-application-controller \
  --from-literal=controller-kind=StatefulSet \
  --from-literal=can-delete-namespaces="$can"
```

Wait for the `Application` to become `Synced` and `Healthy`, then run `astrona submit`: all three checks pass.
