#!/usr/bin/env bash
# Check: The annotated tag known-good points at the head commit.
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

head="$(gitea_api 'repos/starfleet/scout-deploy/commits?sha=main&limit=1' | jq -r '.[0].sha')"
tag="$(gitea_api 'repos/starfleet/scout-deploy/tags/known-good')"
check "tag known-good exists" test "$(echo "$tag" | jq -r .name)" = known-good
check "the tag points at the head of main" test "$(echo "$tag" | jq -r .commit.sha)" = "$head"
check "the tag is annotated (its object id differs from the commit id)" test "$(echo "$tag" | jq -r .id)" != "$head"
exit "$fail"
