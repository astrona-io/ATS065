#!/usr/bin/env bash
# Check: the commit that changed the message was pulled: Argo CD applied the latest commit of main and scout serves the new message.
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

head_sha="$(gitea_api 'repos/starfleet/scout-deploy/commits?sha=main&limit=1&files=false&stat=false&verification=false' | jq -r '.[0].sha // empty')"
check "Argo CD applied the newest commit of main" app_is scout-staging '{.status.sync.revision}' "$head_sha"
check "scout serves the message pulled" test "$(served starfleet-staging | jq -r .message)" = pulled
check "Application is Synced and Healthy" test "$(app_field scout-staging '{.status.sync.status}')/$(app_field scout-staging '{.status.health.status}')" = Synced/Healthy
check "no cluster credential Secret was added to Argo CD" test "$(kubectl -n argocd get secrets -l argocd.argoproj.io/secret-type=cluster -o name 2>/dev/null | wc -l | tr -d ' ')" = 0
exit "$fail"
