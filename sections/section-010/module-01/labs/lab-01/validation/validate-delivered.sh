#!/usr/bin/env bash
# Check: Argo CD reports Synced and Healthy and both replicas are ready.
set -uo pipefail
fail=0
check() { # check <description> <command...>
  local description="$1"; shift
  if "$@" >/dev/null 2>&1; then echo "PASS: $description"; else echo "FAIL: $description"; fail=1; fi
}
app_field() { kubectl -n argocd get application "$1" -o jsonpath="$2" 2>/dev/null; }
check "Application is Healthy" test "$(app_field scout-staging '{.status.health.status}')" = Healthy
check "Application is Synced" test "$(app_field scout-staging '{.status.sync.status}')" = Synced
check "2 replicas are ready" test "$(kubectl -n starfleet-staging get deployment scout -o jsonpath='{.status.readyReplicas}' 2>/dev/null)" = 2
exit "$fail"
