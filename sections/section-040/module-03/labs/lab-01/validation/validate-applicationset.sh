#!/usr/bin/env bash
# Check: The ApplicationSet scout uses a list generator with staging and production.
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

as() { kubectl -n argocd get applicationset scout -o json 2>/dev/null; }
check "ApplicationSet scout exists" test -n "$(as)"
check "uses a list generator" test "$(as | jq '[.spec.generators[] | select(.list != null)] | length')" -ge 1
check "list has staging and production" test "$(as | jq -r '[.spec.generators[].list.elements[]? | .env] | sort | join(",")')" = production,staging
check "template name uses the environment" test "$(as | jq -r '.spec.template.metadata.name')" != "" 
check "template path uses the environment" test "$(as | jq -r '.spec.template.spec.source.path' | grep -c 'overlays/')" -ge 1
exit "$fail"
