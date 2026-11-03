#!/usr/bin/env bash
# Reference solution, applied only by `astrona test`. Keep in step with solution.md.
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
can="$(kubectl auth can-i delete namespaces --as=system:serviceaccount:argocd:argocd-application-controller || true)"
kubectl -n starfleet create configmap agent-report \
  --from-literal=render-component=argocd-repo-server \
  --from-literal=controller-component=argocd-application-controller \
  --from-literal=controller-kind=StatefulSet \
  --from-literal=can-delete-namespaces="$can"
kubectl -n argocd wait --for=jsonpath='{.status.sync.status}'=Synced application/scout-staging --timeout=240s
kubectl -n argocd wait --for=jsonpath='{.status.health.status}'=Healthy application/scout-staging --timeout=240s
