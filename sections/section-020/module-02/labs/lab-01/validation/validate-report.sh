#!/usr/bin/env bash
# Check: the audit-report ConfigMap names the right commit and author.
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

target="$(gitea_api 'repos/starfleet/scout-deploy/commits?sha=main&limit=50' | jq -r '[.[] | select(.commit.message | startswith("Raise production replicas to 5"))][0].sha')"
author="$(gitea_api 'repos/starfleet/scout-deploy/commits?sha=main&limit=50' | jq -r '[.[] | select(.commit.message | startswith("Raise production replicas to 5"))][0].commit.author.name')"
cm() { kubectl -n starfleet get configmap audit-report -o jsonpath="{.data.$1}" 2>/dev/null; }
check "ConfigMap audit-report exists in starfleet" kubectl -n starfleet get configmap audit-report
check "the target commit was found in the history" test -n "$target" -a "$target" != null
check "key commit holds the full commit id" test "$(cm commit)" = "$target"
check "key author holds the author name" test "$(cm author)" = "$author"
exit "$fail"
