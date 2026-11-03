#!/usr/bin/env bash
# Check: the ConfigMap carries sync wave -1 in the live cluster and in Git.
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

check "live ConfigMap has sync wave -1" test "$(kubectl -n starfleet-staging get configmap scout-settings -o json 2>/dev/null | jq -r '.metadata.annotations["argocd.argoproj.io/sync-wave"]')" = "-1"
check "Git has the annotation in base/configmap.yaml" test "$(gitea_api 'repos/starfleet/scout-deploy/raw/base/configmap.yaml?ref=main' | grep -c 'argocd.argoproj.io/sync-wave')" -ge 1
exit "$fail"
