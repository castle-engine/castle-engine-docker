#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

source build-common.sh

# main ---------------------------------------------------------------------------

do_build_cge unstable master
# TODO: For now do not upload, as both Jenkins and GHA would try
# do_upload unstable
