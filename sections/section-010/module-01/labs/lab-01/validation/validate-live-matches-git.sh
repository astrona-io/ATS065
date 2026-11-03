#!/usr/bin/env bash
# Check: the live Deployment matches the intent that is committed to Git (2 replicas, 64Mi memory limit) and Argo CD manages it.
set -uo pipefail
fail=0
check() { # check <description> <command...>
  local description="$1"; shift
  if "$@" >/dev/null 2>&1; then echo "PASS: $description"; else echo "FAIL: $description"; fail=1; fi
}
app_field() { kubectl -n argocd get application "$1" -o jsonpath="$2" 2>/dev/null; }
dep() { kubectl -n starfleet-staging get deployment scout -o jsonpath="$1" 2>/dev/null; }
check "live Deployment has 2 replicas" test "$(dep '{.spec.replicas}')" = 2
check "container memory limit is 64Mi" test "$(dep '{.spec.template.spec.containers[0].resources.limits.memory}')" = 64Mi
check "Deployment carries the Argo CD tracking annotation" test -n "$(dep '{.metadata.annotations.argocd\.argoproj\.io/tracking-id}')"
check "Application is Synced, so the live values come from Git" test "$(app_field scout-staging '{.status.sync.status}')" = Synced
exit "$fail"
