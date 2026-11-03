#!/usr/bin/env bash
# Check: the parent Application reads the apps folder with automated sync, prune and self-heal.
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

check "Application starfleet-root exists" kubectl -n argocd get application starfleet-root
check "path is apps" app_is starfleet-root '{.spec.source.path}' apps
check "destination namespace is argocd" app_is starfleet-root '{.spec.destination.namespace}' argocd
check "prune is true" app_is starfleet-root '{.spec.syncPolicy.automated.prune}' true
check "selfHeal is true" app_is starfleet-root '{.spec.syncPolicy.automated.selfHeal}' true
check "starfleet-root is Synced" app_is starfleet-root '{.status.sync.status}' Synced
exit "$fail"
