#!/usr/bin/env bash
# Check: the retired ConfigMap was removed from Git and pruned from both namespaces.
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

for ns in starfleet-staging starfleet-production; do
  check "ConfigMap legacy-banner is gone from $ns" test -z "$(kubectl -n $ns get configmap legacy-banner -o name 2>/dev/null)"
done
check "base no longer lists legacy-banner.yaml in Git" test "$(gitea_api 'repos/starfleet/scout-deploy/raw/base/kustomization.yaml?ref=main' | grep -c legacy-banner)" = 0
exit "$fail"
