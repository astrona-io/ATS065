#!/usr/bin/env bash
# Check: main still has all five original commits in order.
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

msgs() { gitea_api 'repos/starfleet/scout-deploy/commits?sha=main&limit=50' | jq -r '[.[].commit.message | split("\n")[0]] | reverse | join("|")'; }
check "main has the five seeded commits in order" test "$(msgs)" = "Initial scout deployment|Update staging message|Raise production replicas to 5|Update staging message again|Fix typo in the repository readme"
exit "$fail"
