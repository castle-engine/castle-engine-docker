#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

source build-common.sh

# main ---------------------------------------------------------------------------

do_build_cge unstable snapshot
do_upload unstable
