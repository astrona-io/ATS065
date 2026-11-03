#!/usr/bin/env bash
# Reference solution, applied only by `astrona test`. Keep in step with solution.md.
set -euo pipefail
cat <<'A' | kubectl apply -f -
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
A
kubectl -n argocd wait --for=jsonpath='{.status.sync.status}'=Synced application/scout-helm --timeout=240s
kubectl -n argocd wait --for=jsonpath='{.status.health.status}'=Healthy application/scout-helm --timeout=240s
