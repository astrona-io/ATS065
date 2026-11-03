#!/usr/bin/env bash
# Reference solution, applied only by `astrona test`. Keep in step with solution.md.
set -euo pipefail
WORK="$(mktemp -d)"
LOCAL_PORT=$(( 30000 + RANDOM % 20000 ))
kubectl -n gitea port-forward svc/gitea-http "$LOCAL_PORT:3000" >/dev/null 2>&1 &
PF=$!
trap 'kill $PF 2>/dev/null || true; rm -rf "$WORK"' EXIT
for i in $(seq 1 30); do curl -fs "http://127.0.0.1:$LOCAL_PORT/api/v1/version" >/dev/null 2>&1 && break; sleep 1; done
git clone -q "http://platform:starfleet-gitops@127.0.0.1:$LOCAL_PORT/starfleet/scout-deploy.git" "$WORK/repo"
cd "$WORK/repo"
git config user.name platform
git config user.email platform@starfleet.local
cat > overlays/production/kustomization.yaml <<'Y'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: starfleet-production
resources:
  - ../../base
labels:
  - pairs:
      environment: production
images:
  - name: ghcr.io/stefanprodan/podinfo
    newTag: 6.15.0
replicas:
  - name: scout
    count: 3
patches:
  - path: message.yaml
Y
cd /
WORK2="$(mktemp -d)"
cat > "$WORK2/secret-repo-scout-deploy.yaml" <<'Y'
apiVersion: v1
kind: Secret
metadata:
  name: repo-scout-deploy
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
  username: argocd-reader
  password: reader-pass-1
Y
cat > "$WORK2/application-scout-production.yaml" <<'Y'
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: scout-production
  namespace: argocd
spec:
  project: default
  source:
    repoURL: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
    targetRevision: main
    path: overlays/production
  destination:
    server: https://kubernetes.default.svc
    namespace: starfleet-production
  syncPolicy:
    automated:
      prune: true
    syncOptions:
      - CreateNamespace=true
Y
kubectl apply -f "$WORK2/secret-repo-scout-deploy.yaml" -f "$WORK2/application-scout-production.yaml"
kubectl -n argocd wait --for=jsonpath='{.status.sync.status}'=Synced application/scout-production --timeout=240s
cd "$WORK/repo"
git add -A
git commit -q -m "Production: 3 replicas"
git push -q origin main
curl -fs -u platform:starfleet-gitops -X POST -H 'Content-Type: application/json' "http://127.0.0.1:$LOCAL_PORT/api/v1/repos/starfleet/scout-deploy/hooks" -d '{"type":"gitea","active":true,"events":["push"],"config":{"url":"https://argocd-server.argocd.svc/api/webhook","content_type":"json"}}'
kubectl -n argocd annotate application scout-production argocd.argoproj.io/refresh=hard --overwrite
kubectl -n starfleet-production wait --for=jsonpath='{.spec.replicas}'=3 deploy/scout --timeout=240s
kubectl -n argocd wait --for=jsonpath='{.status.health.status}'=Healthy application/scout-production --timeout=240s
rm -rf "$WORK2"
