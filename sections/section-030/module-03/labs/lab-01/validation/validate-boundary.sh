#!/usr/bin/env bash
# Check: The project does not allow starfleet-production and the staging service still answers.
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

check "production is not a destination" test "$(kubectl -n argocd get appproject team-scout -o json 2>/dev/null | jq '[.spec.destinations[]? | select(.namespace=="starfleet-production" or .namespace=="*")] | length')" = 0
check "wildcard source is not allowed" test "$(kubectl -n argocd get appproject team-scout -o json 2>/dev/null | jq '[.spec.sourceRepos[]? | select(.=="*")] | length')" = 0
check "staging answers staging" test "$(served starfleet-staging | jq -r .message 2>/dev/null)" = staging
exit "$fail"
