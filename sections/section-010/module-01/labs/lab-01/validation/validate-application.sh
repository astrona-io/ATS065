#!/usr/bin/env bash
# Check: the Application exists, reads the staging overlay on main and has automated sync with prune.
set -uo pipefail
fail=0
check() { # check <description> <command...>
  local description="$1"; shift
  if "$@" >/dev/null 2>&1; then echo "PASS: $description"; else echo "FAIL: $description"; fail=1; fi
}
app_field() { kubectl -n argocd get application "$1" -o jsonpath="$2" 2>/dev/null; }
expect() { [ "$(app_field scout-staging "$1")" = "$2" ]; }
check "Application scout-staging exists in argocd" kubectl -n argocd get application scout-staging
check "project is default" expect '{.spec.project}' default
check "path is overlays/staging" expect '{.spec.source.path}' overlays/staging
check "targetRevision is main" expect '{.spec.source.targetRevision}' main
check "repoURL is the scout-deploy repository" expect '{.spec.source.repoURL}' http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
check "destination namespace is starfleet-staging" expect '{.spec.destination.namespace}' starfleet-staging
check "automated sync with prune is on" expect '{.spec.syncPolicy.automated.prune}' true
exit "$fail"
