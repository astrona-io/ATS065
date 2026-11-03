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
git tag v1.2.0 main
git push -q origin v1.2.0
cd /
WORK2="$(mktemp -d)"
cat > "$WORK2/application-scout-staging.yaml" <<'Y'
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
    syncOptions:
      - CreateNamespace=true
Y
sed -e 's/scout-staging/scout-production/' -e 's/targetRevision: main/targetRevision: v1.2.0/' -e 's/overlays\/staging/overlays\/production/' -e 's/starfleet-staging/starfleet-production/' "$WORK2/application-scout-staging.yaml" > "$WORK2/application-scout-production.yaml"
kubectl apply -f "$WORK2/application-scout-staging.yaml" -f "$WORK2/application-scout-production.yaml"
for name in scout-staging scout-production; do
  kubectl -n argocd wait --for=jsonpath='{.status.sync.status}'=Synced application/$name --timeout=240s
  kubectl -n argocd wait --for=jsonpath='{.status.health.status}'=Healthy application/$name --timeout=240s
done
rm -rf "$WORK2"
