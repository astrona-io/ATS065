#!/usr/bin/env bash
# Check: the Application pulls overlays/staging from main with automated sync.
set -uo pipefail
fail=0
check() { # check <description> <command...>
  local description="$1"; shift
  if "$@" >/dev/null 2>&1; then echo "PASS: $description"; else echo "FAIL: $description"; fail=1; fi
}
app_field() { kubectl -n argocd get application "$1" -o jsonpath="$2" 2>/dev/null; }

app_is() { [ "$(app_field "$1" "$2")" = "$3" ]; }
served() { kubectl -n starfleet exec deploy/shuttle -- curl -s --max-time 5 "http://scout.$1/" 2>/dev/null; }
gitea_api() { kubectl -n gitea exec deploy/gitea -- curl -s -u platform:starfleet-gitops "http://127.0.0.1:3000/api/v1/$1" 2>/dev/null; }

check "Application scout-staging exists" kubectl -n argocd get application scout-staging
check "path is overlays/staging" app_is scout-staging '{.spec.source.path}' overlays/staging
check "targetRevision is main" app_is scout-staging '{.spec.source.targetRevision}' main
check "destination is the same cluster" app_is scout-staging '{.spec.destination.server}' https://kubernetes.default.svc
check "automated sync is on" test -n "$(app_field scout-staging '{.spec.syncPolicy.automated}')"
exit "$fail"
