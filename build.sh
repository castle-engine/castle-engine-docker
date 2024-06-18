#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

source build-common.sh

# main ---------------------------------------------------------------------------

mkdir -p logs/
if [ -n "${OVERRIDE_LOG_FILE:-}" ]; then
  LOG_FILE="${OVERRIDE_LOG_FILE}"
else
  LOG_FILE="logs/build-$$.log"
fi
echo "Logging to ${LOG_FILE}"
exec > "${LOG_FILE}" 2>&1

do_everything_for_image_none
do_everything_for_image_stable
do_everything_for_image_unstable
