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
commit="$(git log --format=%H --grep='^Raise production replicas to 5' -n 1)"
author="$(git log --format=%an -n 1 "$commit")"
git -c user.name=platform -c user.email=platform@starfleet.local tag -a replicas-incident "$commit" -m "Production replicas raised to 5"
git push -q origin replicas-incident
kubectl -n starfleet create configmap audit-report --from-literal=commit="$commit" --from-literal=author="$author"
