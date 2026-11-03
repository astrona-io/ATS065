#!/usr/bin/env bash
# Check: the tag v1.2.0 exists, points at Release 1.2 and is the revision Argo CD applied to production.
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

tag_sha="$(gitea_api 'repos/starfleet/scout-deploy/tags/v1.2.0' | jq -r '.commit.sha // empty')"
check "the tag v1.2.0 exists in the repository" test -n "$tag_sha"
message="$(gitea_api "repos/starfleet/scout-deploy/git/commits/$tag_sha" | jq -r '.commit.message // empty')"
check "the tag points at the commit Release 1.2" test "$(echo "$message" | head -n1)" = "Release 1.2 with podinfo 6.15.0"
check "production applied exactly the tagged commit" app_is scout-production '{.status.sync.revision}' "$tag_sha"
exit "$fail"
