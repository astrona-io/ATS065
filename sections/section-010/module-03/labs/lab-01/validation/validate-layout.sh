#!/usr/bin/env bash
# Check: The base is unchanged and the production overlay sets its own message through a patch.
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

raw() { gitea_api "repos/starfleet/scout-deploy/raw/$1?ref=main"; }
check "base ConfigMap still sets staging" test "$(raw base/configmap.yaml | grep -c 'PODINFO_UI_MESSAGE: staging')" -ge 1
check "production overlay has a patches entry" test "$(raw overlays/production/kustomization.yaml | grep -c '^patches:')" -ge 1
check "staging overlay still has its patch" test "$(raw overlays/staging/kustomization.yaml | grep -c 'message.yaml')" -ge 1
check "production overlay does not copy the base" test "$(raw overlays/production/kustomization.yaml | grep -c 'kind: Deployment')" -eq 0
exit "$fail"
