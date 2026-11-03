#!/usr/bin/env bash
# Check: the Application is Synced and Healthy and the live workload shows the declared values.
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

check "Application is Synced" app_is scout-helm '{.status.sync.status}' Synced
check "Application is Healthy" app_is scout-helm '{.status.health.status}' Healthy
check "Deployment has 2 ready replicas" test "$(kubectl -n starfleet-staging get deployment scout -o jsonpath='{.status.readyReplicas}' 2>/dev/null)" = 2
check "Deployment image is 6.15.0" test "$(kubectl -n starfleet-staging get deployment scout -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)" = ghcr.io/stefanprodan/podinfo:6.15.0
check "service answers with the message helm-staging" test "$(served starfleet-staging | jq -r .message 2>/dev/null)" = helm-staging
exit "$fail"
