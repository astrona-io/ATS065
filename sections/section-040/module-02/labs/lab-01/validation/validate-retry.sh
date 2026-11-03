#!/usr/bin/env bash
# Check: the Application has the retry policy.
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

r() { kubectl -n argocd get application scout-staging -o json | jq -r "$1"; }
check "retry limit is 5" test "$(r '.spec.syncPolicy.retry.limit')" = 5
check "backoff duration is 10s" test "$(r '.spec.syncPolicy.retry.backoff.duration')" = 10s
check "backoff factor is 2" test "$(r '.spec.syncPolicy.retry.backoff.factor')" = 2
check "backoff maxDuration is 3m" test "$(r '.spec.syncPolicy.retry.backoff.maxDuration')" = 3m
check "automated sync is still on" test "$(r '.spec.syncPolicy.automated != null')" = true
exit "$fail"
