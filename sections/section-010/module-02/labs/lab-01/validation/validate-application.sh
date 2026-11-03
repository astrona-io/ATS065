#!/usr/bin/env bash
# Check: the Application renders the Helm chart from main with automated sync and prune.
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

check "Application scout-helm exists" test -n "$(app_field scout-helm '{.metadata.name}')"
check "path is charts/scout" app_is scout-helm '{.spec.source.path}' charts/scout
check "targetRevision is main" app_is scout-helm '{.spec.source.targetRevision}' main
check "destination namespace is starfleet-staging" app_is scout-helm '{.spec.destination.namespace}' starfleet-staging
check "automated sync with prune" app_is scout-helm '{.spec.syncPolicy.automated.prune}' true
exit "$fail"
