#!/usr/bin/env bash
# Starting state: the staging environment is delivered by an Application. The
# production overlay exists in Git but nothing delivers it and it does not set
# its own message yet.
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
kubectl -n argocd wait --for=jsonpath='{.status.health.status}'=Healthy application/scout-staging --timeout=300s
echo "[lab] Staging is delivered. Production is not."
