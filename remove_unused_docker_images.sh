#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

echo 'Disk space before:'
df -h /
echo 'Removing dangling Docker images, to free disk space:'
docker images --filter "dangling=true"

# Continue even if the removal below failed with error,
# which is possible since some job may started while the removal was in-progress
set +e
docker images -q --filter "dangling=true" | xargs --no-run-if-empty docker rmi
set -e

echo 'Disk space after:'
df -h /
