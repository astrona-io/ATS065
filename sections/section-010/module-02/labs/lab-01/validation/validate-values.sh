#!/usr/bin/env bash
# Check: the Helm values are declared on the Application and the chart in Git is unchanged.
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

values() { kubectl -n argocd get application scout-helm -o json | jq -r "$1"; }
check "replicaCount is 2" test "$(values '.spec.source.helm.valuesObject.replicaCount')" = 2
check "image.tag is 6.15.0" test "$(values '.spec.source.helm.valuesObject.image.tag')" = 6.15.0
check "message is helm-staging" test "$(values '.spec.source.helm.valuesObject.message')" = helm-staging
check "chart default replicaCount in Git is still 1" test "$(gitea_api 'repos/starfleet/scout-deploy/raw/charts/scout/values.yaml?ref=main' | grep -c '^replicaCount: 1$')" = 1
exit "$fail"
