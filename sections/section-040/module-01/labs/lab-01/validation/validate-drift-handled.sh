#!/usr/bin/env bash
# Check: the manual image change was reverted and the autoscaler-owned replica count was left alone.
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

dep() { kubectl -n starfleet-staging get deployment scout -o jsonpath="$1" 2>/dev/null; }
check "image is back to 6.15.0 (self-heal reverted the manual change)" test "$(dep '{.spec.template.spec.containers[0].image}')" = ghcr.io/stefanprodan/podinfo:6.15.0
check "replicas are still 3 (the ignored field was not reset)" test "$(dep '{.spec.replicas}')" = 3
check "Application is Synced" app_is scout-staging '{.status.sync.status}' Synced
exit "$fail"
