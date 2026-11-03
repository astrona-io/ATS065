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
kubectl apply -f "$WORK2/secret-repo-scout-deploy.yaml" -f "$WORK2/application-scout-staging.yaml"
kubectl -n argocd wait --for=jsonpath='{.status.sync.status}'=Synced application/scout-staging --timeout=240s
cd "$WORK/repo"
cat > overlays/staging/message.yaml <<'Y'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scout
spec:
  template:
    spec:
      containers:
        - name: scout
          env:
            - name: PODINFO_UI_MESSAGE
              value: pulled
Y
git add -A
git commit -q -m "Staging message: pulled"
git push -q origin main
kubectl -n argocd annotate application scout-staging argocd.argoproj.io/refresh=hard --overwrite
for i in $(seq 1 60); do
  message="$(kubectl -n starfleet exec deploy/shuttle -- curl -s --max-time 5 http://scout.starfleet-staging/ | jq -r .message || true)"
  [ "$message" = pulled ] && break
  sleep 3
done
kubectl -n argocd wait --for=jsonpath='{.status.health.status}'=Healthy application/scout-staging --timeout=240s
rm -rf "$WORK2"
