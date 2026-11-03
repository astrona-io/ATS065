#!/usr/bin/env bash
# Plumbing: create the organisation `starfleet` and push a folder as a
# repository. Usage: seed-repo.sh <repository name> <folder> [public|private]
# If the folder holds directories named step-1, step-2, ..., each step becomes
# one commit (files of the previous step are replaced). A step may contain a
# COMMIT_MESSAGE file and a TAG file; both are read and not committed.
# With READER=1 a read-only user `argocd-reader` (password reader-pass-1) is
# created and added to the repository as a read collaborator.
set -euo pipefail
REPO="$1"; SRC="$2"; VISIBILITY="${3:-public}"
AUTH="platform:starfleet-gitops"
PRIVATE=false; [ "$VISIBILITY" = "private" ] && PRIVATE=true
LOCAL_PORT=$(( 30000 + RANDOM % 20000 ))
kubectl -n gitea port-forward svc/gitea-http "$LOCAL_PORT:3000" >/dev/null 2>&1 &
PF=$!
trap 'kill $PF 2>/dev/null || true; rm -rf "${WORK:-}"' EXIT
API="http://127.0.0.1:$LOCAL_PORT/api/v1"
for i in $(seq 1 30); do curl -fs "$API/version" >/dev/null 2>&1 && break; sleep 1; done
curl -fs -u "$AUTH" -X POST -H 'Content-Type: application/json' "$API/orgs" \
  -d '{"username":"starfleet","visibility":"public"}' >/dev/null || true
curl -fs -u "$AUTH" -X POST -H 'Content-Type: application/json' "$API/orgs/starfleet/repos" \
  -d "{\"name\":\"$REPO\",\"private\":$PRIVATE,\"default_branch\":\"main\"}" >/dev/null || true
if [ "${READER:-0}" = "1" ]; then
  curl -fs -u "$AUTH" -X POST -H 'Content-Type: application/json' "$API/admin/users" \
    -d '{"username":"argocd-reader","password":"reader-pass-1","email":"argocd-reader@starfleet.local","must_change_password":false}' >/dev/null || true
  curl -fs -u "$AUTH" -X PUT -H 'Content-Type: application/json' "$API/repos/starfleet/$REPO/collaborators/argocd-reader" \
    -d '{"permission":"read"}' >/dev/null || true
fi
WORK="$(mktemp -d)"
cd "$WORK"
git init -q -b main
GIT_ID=(-c user.name=platform -c user.email=platform@starfleet.local)
if ls "$SRC"/step-* >/dev/null 2>&1; then
  for step in $(ls -d "$SRC"/step-* | sort -V); do
    git ls-files -z | xargs -0 -r rm -f --
    cp -R "$step/." "$WORK/"
    message="$(cat "$WORK/COMMIT_MESSAGE" 2>/dev/null || echo "Update $REPO")"
    tag="$(cat "$WORK/TAG" 2>/dev/null || true)"
    rm -f "$WORK/COMMIT_MESSAGE" "$WORK/TAG"
    git "${GIT_ID[@]}" add -A
    git "${GIT_ID[@]}" commit -q -m "$message"
    [ -n "$tag" ] && git "${GIT_ID[@]}" tag "$tag"
  done
else
  cp -R "$SRC/." "$WORK/"
  git "${GIT_ID[@]}" add -A
  git "${GIT_ID[@]}" commit -q -m "Initial content of $REPO"
fi
git push -q "http://$AUTH@127.0.0.1:$LOCAL_PORT/starfleet/$REPO.git" main --force
git push -q "http://$AUTH@127.0.0.1:$LOCAL_PORT/starfleet/$REPO.git" --tags --force
echo "[playground] Seeded starfleet/$REPO ($VISIBILITY)"
