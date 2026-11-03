#!/usr/bin/env bash
# Check: agent-report matches the real components and the real permission of the application controller.
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

cm() { kubectl -n starfleet get configmap agent-report -o jsonpath="{.data.$1}" 2>/dev/null; }
real_can="$(kubectl auth can-i delete namespaces --as=system:serviceaccount:argocd:argocd-application-controller 2>/dev/null)"
check "ConfigMap agent-report exists in starfleet" kubectl -n starfleet get configmap agent-report
check "render-component is argocd-repo-server" test "$(cm render-component)" = argocd-repo-server
check "controller-component is argocd-application-controller" test "$(cm controller-component)" = argocd-application-controller
check "controller-kind matches the live workload kind" kubectl -n argocd get "$(cm controller-kind | tr '[:upper:]' '[:lower:]')/$(cm controller-component)"
check "can-delete-namespaces matches kubectl auth can-i" test "$(cm can-delete-namespaces)" = "$real_can"
exit "$fail"
