#!/usr/bin/env bash
# Check: staging follows main and production is pinned to a release tag, both with automated sync.
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

for name in scout-staging scout-production; do check "Application $name exists" kubectl -n argocd get application $name; done
check "staging follows main" app_is scout-staging '{.spec.source.targetRevision}' main
check "staging path is overlays/staging" app_is scout-staging '{.spec.source.path}' overlays/staging
check "production path is overlays/production" app_is scout-production '{.spec.source.path}' overlays/production
check "production is pinned to the tag v1.2.0" app_is scout-production '{.spec.source.targetRevision}' v1.2.0
check "staging has automated sync" test -n "$(app_field scout-staging '{.spec.syncPolicy.automated}')"
check "production has automated sync" test -n "$(app_field scout-production '{.spec.syncPolicy.automated}')"
exit "$fail"
