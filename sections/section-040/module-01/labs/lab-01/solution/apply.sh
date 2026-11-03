#!/usr/bin/env bash
# Reference solution, applied only by `astrona test`. Keep in step with solution.md.
set -euo pipefail
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
cat > "$WORK/application-scout-staging.yaml" <<'Y'
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
Y
kubectl apply -f "$WORK/application-scout-staging.yaml"
kubectl -n argocd annotate application scout-staging argocd.argoproj.io/refresh=hard --overwrite
for i in $(seq 1 60); do
  image="$(kubectl -n starfleet-staging get deployment scout -o jsonpath='{.spec.template.spec.containers[0].image}')"
  [ "$image" = ghcr.io/stefanprodan/podinfo:6.15.0 ] && break
  sleep 3
done
kubectl -n argocd wait --for=jsonpath='{.status.sync.status}'=Synced application/scout-staging --timeout=240s
