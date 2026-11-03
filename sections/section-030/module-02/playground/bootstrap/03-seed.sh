#!/usr/bin/env bash
# Plumbing: push the repositories of this environment into Gitea.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
READER=0 bash "$SCRIPT_DIR/seed-repo.sh" scout-deploy "$SCRIPT_DIR/../repos/scout-deploy" public
