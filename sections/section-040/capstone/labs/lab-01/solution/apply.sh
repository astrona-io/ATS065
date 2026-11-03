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
sed -e 's#overlays/prod$#overlays/production#' apps/scout-production.yaml > apps/scout-production.yaml.new
mv apps/scout-production.yaml.new apps/scout-production.yaml
git rm -q apps/scout-legacy.yaml
git add -A
git commit -q -m "Fix the production path and remove scout-legacy"
git push -q origin main
cd /
WORK2="$(mktemp -d)"
cat > "$WORK2/application-starfleet-root.yaml" <<'Y'
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: starfleet-root
  namespace: argocd
spec:
  project: default
  source:
    repoURL: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
    targetRevision: main
    path: apps
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
Y
kubectl apply -f "$WORK2/application-starfleet-root.yaml"
for name in starfleet-root scout-staging scout-production; do
  kubectl -n argocd wait --for=create application/$name --timeout=240s
  kubectl -n argocd wait --for=jsonpath='{.status.sync.status}'=Synced application/$name --timeout=240s
done
rm -rf "$WORK2"
