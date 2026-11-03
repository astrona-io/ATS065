#!/usr/bin/env bash
# Check: the Git server has an active push webhook that tells Argo CD to refresh.
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

hooks="$(gitea_api 'repos/starfleet/scout-deploy/hooks')"
check "a webhook posts to the Argo CD webhook endpoint" test "$(echo "$hooks" | jq '[.[] | select(.config.url == "https://argocd-server.argocd.svc/api/webhook")] | length')" -ge 1
check "the webhook is active" test "$(echo "$hooks" | jq '[.[] | select(.config.url == "https://argocd-server.argocd.svc/api/webhook" and .active == true)] | length')" -ge 1
check "the webhook fires on push events" test "$(echo "$hooks" | jq '[.[] | select(.config.url == "https://argocd-server.argocd.svc/api/webhook" and (.events | index("push")))] | length')" -ge 1
exit "$fail"
