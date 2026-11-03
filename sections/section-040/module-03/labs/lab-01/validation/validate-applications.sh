#!/usr/bin/env bash
# Check: The generated Applications use automated sync with prune, self-heal, CreateNamespace and PruneLast.
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

for env in staging production; do
  a=scout-$env
  check "$a path is overlays/$env" app_is $a '{.spec.source.path}' overlays/$env
  check "$a destination is starfleet-$env" app_is $a '{.spec.destination.namespace}' starfleet-$env
  check "$a prune is on" app_is $a '{.spec.syncPolicy.automated.prune}' true
  check "$a self-heal is on" app_is $a '{.spec.syncPolicy.automated.selfHeal}' true
  check "$a has PruneLast=true" test "$(kubectl -n argocd get application $a -o json | jq '[.spec.syncPolicy.syncOptions[]? | select(.=="PruneLast=true")] | length')" = 1
  check "$a has CreateNamespace=true" test "$(kubectl -n argocd get application $a -o json | jq '[.spec.syncPolicy.syncOptions[]? | select(.=="CreateNamespace=true")] | length')" = 1
  check "$a is Synced" app_is $a '{.status.sync.status}' Synced
  check "$a is Healthy" app_is $a '{.status.health.status}' Healthy
done
exit "$fail"
