#!/usr/bin/env bash
# Check: automated sync has prune and selfHeal, and ignored fields are also skipped during sync.
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

check "prune is true" app_is scout-staging '{.spec.syncPolicy.automated.prune}' true
check "selfHeal is true" app_is scout-staging '{.spec.syncPolicy.automated.selfHeal}' true
check "syncOptions has RespectIgnoreDifferences=true" test "$(kubectl -n argocd get application scout-staging -o json | jq '[.spec.syncPolicy.syncOptions[]? | select(. == "RespectIgnoreDifferences=true")] | length')" = 1
exit "$fail"
