#!/usr/bin/env bash
# Check: both Applications read their overlay from main with automated sync and prune.
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

for env in staging production; do
  check "Application scout-$env exists" kubectl -n argocd get application scout-$env
  check "scout-$env path is overlays/$env" app_is scout-$env '{.spec.source.path}' overlays/$env
  check "scout-$env has automated sync with prune" app_is scout-$env '{.spec.syncPolicy.automated.prune}' true
  check "scout-$env is Synced" app_is scout-$env '{.status.sync.status}' Synced
  check "scout-$env is Healthy" app_is scout-$env '{.status.health.status}' Healthy
done
exit "$fail"
