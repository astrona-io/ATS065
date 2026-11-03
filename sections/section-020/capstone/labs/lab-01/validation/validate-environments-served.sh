#!/usr/bin/env bash
# Check: both environments are Synced and Healthy and serve release 1.2.
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

for name in scout-staging scout-production; do
  check "$name is Synced" app_is $name '{.status.sync.status}' Synced
  check "$name is Healthy" app_is $name '{.status.health.status}' Healthy
done
for ns in starfleet-staging starfleet-production; do
  check "$ns serves version 6.15.0" test "$(served $ns | jq -r .version)" = 6.15.0
  check "$ns serves the message release 1.2" test "$(served $ns | jq -r .message)" = "release 1.2"
done
exit "$fail"
