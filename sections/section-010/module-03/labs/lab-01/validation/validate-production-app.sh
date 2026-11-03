#!/usr/bin/env bash
# Check: The Application scout-production delivers overlays/production with automated sync.
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

head="$(gitea_api 'repos/starfleet/scout-deploy/commits?sha=main&limit=1' | jq -r '.[0].sha')"
check "path is overlays/production" app_is scout-production '{.spec.source.path}' overlays/production
check "destination is starfleet-production" app_is scout-production '{.spec.destination.namespace}' starfleet-production
check "branch is main" app_is scout-production '{.spec.source.targetRevision}' main
check "automated sync is on" test "$(kubectl -n argocd get application scout-production -o json | jq -r '.spec.syncPolicy.automated != null')" = true
check "revision is the head of main" app_is scout-production '{.status.sync.revision}' "$head"
check "Application is Synced" app_is scout-production '{.status.sync.status}' Synced
check "Application is Healthy" app_is scout-production '{.status.health.status}' Healthy
exit "$fail"
