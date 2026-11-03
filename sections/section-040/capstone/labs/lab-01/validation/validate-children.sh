#!/usr/bin/env bash
# Check: both child Applications were created by the parent and are Synced and Healthy.
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
  check "$name exists" kubectl -n argocd get application $name
  check "$name is tracked by starfleet-root" test "$(kubectl -n argocd get application $name -o jsonpath='{.metadata.annotations.argocd\.argoproj\.io/tracking-id}' 2>/dev/null | cut -d: -f1)" = starfleet-root
  check "$name is Synced" app_is $name '{.status.sync.status}' Synced
  check "$name is Healthy" app_is $name '{.status.health.status}' Healthy
done
check "production uses the path overlays/production" app_is scout-production '{.spec.source.path}' overlays/production
exit "$fail"
