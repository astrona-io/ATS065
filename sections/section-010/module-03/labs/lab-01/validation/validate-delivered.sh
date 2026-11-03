#!/usr/bin/env bash
# Check: Production runs 2 replicas with the message production and staging is unchanged.
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

check "production has 2 ready replicas" test "$(kubectl -n starfleet-production get deployment scout -o jsonpath='{.status.readyReplicas}' 2>/dev/null)" = 2
check "production answers production" test "$(served starfleet-production | jq -r .message 2>/dev/null)" = production
check "staging answers staging" test "$(served starfleet-staging | jq -r .message 2>/dev/null)" = staging
exit "$fail"
