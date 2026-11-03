#!/usr/bin/env bash
# Check: an annotated tag marks the commit that raised the production replicas.
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

target="$(gitea_api 'repos/starfleet/scout-deploy/commits?sha=main&limit=50' | jq -r '[.[] | select(.commit.message | startswith("Raise production replicas to 5"))][0].sha')"
tag="$(gitea_api 'repos/starfleet/scout-deploy/tags/replicas-incident')"
check "tag replicas-incident exists" test "$(echo "$tag" | jq -r .name)" = replicas-incident
check "the tag points at the commit that raised the replicas" test "$(echo "$tag" | jq -r .commit.sha)" = "$target"
check "the tag is annotated (its object id differs from the commit id)" test "$(echo "$tag" | jq -r .id)" != "$target"
exit "$fail"
