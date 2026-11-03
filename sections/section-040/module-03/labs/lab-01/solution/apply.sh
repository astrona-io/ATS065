#!/usr/bin/env bash
# Reference solution, applied only by `astrona test`. Keep in step with solution.md.
set -euo pipefail
cat <<'Y' | kubectl apply -f -
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
for a in scout-staging scout-production; do
  for i in $(seq 1 60); do kubectl -n argocd get application $a >/dev/null 2>&1 && break; sleep 2; done
  kubectl -n argocd wait --for=jsonpath='{.status.health.status}'=Healthy application/$a --timeout=300s
done
