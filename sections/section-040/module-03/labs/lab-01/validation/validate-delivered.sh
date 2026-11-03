#!/usr/bin/env bash
# Check: Each environment answers with its own message and the Applications are owned by the set.
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

check "staging answers staging" test "$(served starfleet-staging | jq -r .message 2>/dev/null)" = staging
check "production answers production" test "$(served starfleet-production | jq -r .message 2>/dev/null)" = production
check "scout-staging is owned by the ApplicationSet" test "$(kubectl -n argocd get application scout-staging -o jsonpath='{.metadata.ownerReferences[0].kind}' 2>/dev/null)" = ApplicationSet
check "scout-production is owned by the ApplicationSet" test "$(kubectl -n argocd get application scout-production -o jsonpath='{.metadata.ownerReferences[0].kind}' 2>/dev/null)" = ApplicationSet
exit "$fail"
