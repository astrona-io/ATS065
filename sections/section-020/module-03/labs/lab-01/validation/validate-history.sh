#!/usr/bin/env bash
# Check: The earlier commits are still on main and the head is a new commit.
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

log="$(gitea_api 'repos/starfleet/scout-deploy/commits?sha=main&limit=50')"
check "the bad release is still in the history" test "$(echo "$log" | jq '[.[] | select(.commit.message | startswith("Upgrade scout to 6.99.0"))] | length')" -ge 1
check "the first release is still in the history" test "$(echo "$log" | jq '[.[] | select(.commit.message | startswith("Deploy scout 6.14.0"))] | length')" -ge 1
check "there are at least 4 commits" test "$(echo "$log" | jq length)" -ge 4
check "the head is not the bad release" test "$(echo "$log" | jq -r '.[0].commit.message' | grep -c '^Upgrade scout to 6.99.0')" -eq 0
exit "$fail"
