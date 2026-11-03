#!/usr/bin/env bash
# Check: the bad commit is still in the history of main and the newest commit is a revert (no force push, no history rewrite).
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

commits="$(gitea_api 'repos/starfleet/scout-deploy/commits?sha=main&limit=20&files=false&stat=false&verification=false')"
check "main has at least 4 commits" test "$(echo "$commits" | jq 'length')" -ge 4
check "the bad commit Release 6.99.9 is still in the history" test "$(echo "$commits" | jq '[.[] | select(.commit.message | startswith("Release 6.99.9"))] | length')" -ge 1
check "the newest commit is a revert" test "$(echo "$commits" | jq -r '.[0].commit.message' | head -n1 | cut -c1-6)" = Revert
exit "$fail"
