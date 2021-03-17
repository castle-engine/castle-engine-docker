#!/bin/bash
set -eux

# Test FPC/Lazarus combination using FPC/Lazarus version $1.

FPC_VERSION="$1"
shift 1

# Install "file" utility
apt-get update
apt-get --no-install-recommends -y install file

/usr/local/tests/bin/test_fpc_version_native.sh ${FPC_VERSION}
/usr/local/tests/bin/test_fpc_version_cross.sh ${FPC_VERSION} win32 i386
/usr/local/tests/bin/test_fpc_version_cross.sh ${FPC_VERSION} win64 x86_64
/usr/local/tests/bin/test_fpc_version_lazarus.sh ${FPC_VERSION}
