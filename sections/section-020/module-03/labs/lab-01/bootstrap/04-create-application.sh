#!/usr/bin/env bash
# Starting state: an Application with automated sync follows main. The last
# commit on main raised the image tag to 6.99.0, which does not exist, so the
# Application is Synced and the Deployment is not ready.
set -euo pipefail
cat <<'A' | kubectl apply -f -
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
A
kubectl -n argocd wait --for=jsonpath='{.status.sync.status}'=Synced application/scout-staging --timeout=240s
echo "[lab] The latest release is deployed and does not become ready."
