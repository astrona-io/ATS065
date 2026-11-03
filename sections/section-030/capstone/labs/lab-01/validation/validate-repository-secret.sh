#!/usr/bin/env bash
# Check: Argo CD reads the private repository with the read-only user argocd-reader.
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

secret="$(kubectl -n argocd get secrets -l argocd.argoproj.io/secret-type=repository -o json 2>/dev/null)"
check "a repository Secret for the scout-deploy URL exists" test "$(echo "$secret" | jq --arg u http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git '[.items[] | select((.data.url // "") | @base64d == $u)] | length')" -ge 1
check "it uses the user argocd-reader" test "$(echo "$secret" | jq '[.items[] | select((.data.username // "") | @base64d == "argocd-reader")] | length')" -ge 1
check "no repository Secret uses the write user platform" test "$(echo "$secret" | jq '[.items[] | select((.data.username // "") | @base64d == "platform")] | length')" = 0
exit "$fail"
