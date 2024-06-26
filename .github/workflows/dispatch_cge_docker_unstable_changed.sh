#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# --------------------------------------------------------------------------
# Use "gh api" to trigger rebuild in another GitHub repository
# (using GitHub Actions workflow repository_dispatch event).
# Useful to send after CGE Docker unstable image changes, to rebuild
# CGE demo/example projects using this Docker image.
#
# Params:
# $1 - SHA of this repo causing it. This may be useful for debug purposes later,
#      to track what commit caused the rebuild.
#      Pass ${{ github.sha }} from .github/workflows/after-build.yml
# $2 - GitHub repository name (e.g. "castle-engine/castle-model-viewer").
# --------------------------------------------------------------------------

CGE_DOCKER_COMMIT_SHA="$1"
REPO_NAME="$2"
shift 2

gh api --method POST \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  /repos/"${REPO_NAME}"/dispatches \
  -f "event_type=cge-docker-unstable-changed"  \
  -F "client_payload[cge_docker_commit_sha]=${CGE_DOCKER_COMMIT_SHA}"
