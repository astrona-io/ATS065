#!/usr/bin/env bash
# Check: scout runs the last good image and Argo CD reports Synced and Healthy.
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

image() { kubectl -n starfleet-staging get deployment scout -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null; }
check "scout runs ghcr.io/stefanprodan/podinfo:6.15.0" test "$(image)" = ghcr.io/stefanprodan/podinfo:6.15.0
check "Application is Synced" app_is scout-staging '{.status.sync.status}' Synced
check "Application is Healthy" app_is scout-staging '{.status.health.status}' Healthy
exit "$fail"
