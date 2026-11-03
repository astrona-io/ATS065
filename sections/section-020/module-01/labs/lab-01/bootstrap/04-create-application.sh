#!/usr/bin/env bash
# Starting state: an Application that follows main with automated sync. The
# newest commit on main is a bad release, so the Deployment cannot start.
set -euo pipefail
cat <<'Y' | kubectl apply -f -
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
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
Y
kubectl -n starfleet-staging wait --for=create deploy/scout --timeout=240s
echo "[lab] The bad release is deployed."
