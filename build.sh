#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

source build-common.sh

# main ---------------------------------------------------------------------------

mkdir -p logs/
LOG_FILE="logs/build-$$.log"
echo "Logging to ${LOG_FILE}"
exec > "${LOG_FILE}" 2>&1

do_prerequisites
do_build
do_test
# Do this before do_build_cge, as Dockerfile.cge uses images from Dockerhub.
do_upload none
do_upload_github none

do_build_cge stable v6.4-fixes
do_test_cge stable
do_upload stable
do_upload_github stable

do_build_cge unstable master
do_test_cge unstable
do_upload unstable
do_upload_github unstable
