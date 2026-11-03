#!/usr/bin/env bash
# Check: the repaired production overlay declares 3 replicas and the message production.
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

check "production has 3 replicas" test "$(kubectl -n starfleet-production get deployment scout -o jsonpath='{.spec.replicas}' 2>/dev/null)" = 3
check "production serves the message production" test "$(served starfleet-production | jq -r .message)" = production
check "staging still serves the message staging" test "$(served starfleet-staging | jq -r .message)" = staging
exit "$fail"
