#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

echo 'Disk space before:'
df -h /
echo 'Removing dangling Docker images, to free disk space:'
docker images --filter "dangling=true"
docker images -q --filter "dangling=true" | xargs --no-run-if-empty docker rmi
echo 'Disk space after:'
df -h /
