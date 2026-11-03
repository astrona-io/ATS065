#!/usr/bin/env bash
# Check: exactly one ignore rule exists and it covers only /spec/replicas of the Deployment scout.
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

rules="$(kubectl -n argocd get application scout-staging -o json | jq -c '.spec.ignoreDifferences // []')"
check "exactly one ignoreDifferences entry" test "$(echo "$rules" | jq 'length')" = 1
check "it targets the Deployment scout in group apps" test "$(echo "$rules" | jq -r '.[0] | .group + "/" + .kind + "/" + .name')" = apps/Deployment/scout
check "it ignores only /spec/replicas" test "$(echo "$rules" | jq -c '.[0].jsonPointers')" = '["/spec/replicas"]'
exit "$fail"
