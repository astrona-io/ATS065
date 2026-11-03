#!/usr/bin/env bash
# Starting state: an Application with automated sync but no self-heal. After it
# is Synced, the live Deployment is changed by hand: 3 replicas (a value an
# autoscaler would own) and the older image 6.14.0 (an unwanted manual change).
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
    automated: {}
    syncOptions:
      - CreateNamespace=true
Y
kubectl -n argocd wait --for=jsonpath='{.status.sync.status}'=Synced application/scout-staging --timeout=240s
kubectl -n starfleet-staging rollout status deploy/scout --timeout=240s
kubectl -n starfleet-staging scale deploy/scout --replicas=3
kubectl -n starfleet-staging set image deploy/scout scout=ghcr.io/stefanprodan/podinfo:6.14.0
echo "[lab] Drift created: replicas 3 and image 6.14.0."
