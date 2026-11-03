#!/usr/bin/env bash
# Check: The AppProject team-scout allows one repository, one destination and no cluster kinds.
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

proj() { kubectl -n argocd get appproject team-scout -o json 2>/dev/null; }
repo=http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
check "project exists" test -n "$(proj)"
check "only source is the scout repository" test "$(proj | jq -c '.spec.sourceRepos')" = "[\"$repo\"]"
check "one destination" test "$(proj | jq '.spec.destinations | length')" = 1
check "destination namespace is starfleet-staging" test "$(proj | jq -r '.spec.destinations[0].namespace')" = starfleet-staging
check "destination server is in-cluster" test "$(proj | jq -r '.spec.destinations[0].server')" = https://kubernetes.default.svc
check "no cluster-scoped kinds allowed" test "$(proj | jq '(.spec.clusterResourceWhitelist // []) | length')" = 0
check "cluster whitelist field is present" test "$(proj | jq '.spec | has("clusterResourceWhitelist")')" = true
exit "$fail"
