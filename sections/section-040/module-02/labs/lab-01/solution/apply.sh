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
sed -i.orig 's/newTag: 6.99.0/newTag: 6.15.0/' overlays/staging/kustomization.yaml
cat > base/configmap.yaml <<'C'
apiVersion: v1
kind: ConfigMap
metadata:
  name: scout-settings
  annotations:
    argocd.argoproj.io/sync-wave: "-1"
data:
  PODINFO_UI_MESSAGE: staging
C
rm -f overlays/staging/kustomization.yaml.orig
git -c user.name=platform -c user.email=platform@starfleet.local commit -q -am "Fix image tag and order the ConfigMap first"
git push -q origin main
kubectl -n argocd patch application scout-staging --type merge -p '{"spec":{"syncPolicy":{"retry":{"limit":5,"backoff":{"duration":"10s","factor":2,"maxDuration":"3m"}}}}}'
kubectl -n argocd annotate application scout-staging argocd.argoproj.io/refresh=hard --overwrite
kubectl -n argocd wait --for=jsonpath='{.status.health.status}'=Healthy application/scout-staging --timeout=300s
