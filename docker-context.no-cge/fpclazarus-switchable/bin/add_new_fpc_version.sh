#!/bin/bash
set -eux

# Run this as root (through sudo).
# Current dir doesn't matter.
#
# This removes previous fpc and lazarus subdirectories of this version,
# so it can be used to reliably override existing version too.

FPC_VERSION="$1"
LAZARUS_VERSION="$2"
shift 2

/usr/local/fpclazarus/bin/add_new_fpc_version_native.sh ${FPC_VERSION}
/usr/local/fpclazarus/bin/add_new_fpc_version_cross.sh ${FPC_VERSION} win32 i386
/usr/local/fpclazarus/bin/add_new_fpc_version_cross.sh ${FPC_VERSION} win64 x86_64

if [ "${FPC_VERSION}" = '3.0.0' -o "${FPC_VERSION}" = '3.0.2' ]; then
  echo 'Not building Android/Arm cross-compiler for FPC ${FPC_VERSION}, too old'
else
  /usr/local/fpclazarus/bin/add_new_fpc_version_cross.sh ${FPC_VERSION} android arm CROSSOPT="-CfVFPV3"
fi

if [ "${FPC_VERSION}" = '3.0.0' -o "${FPC_VERSION}" = '3.0.2' -o "${FPC_VERSION}" = '3.0.4' ]; then
  echo 'Not building Android/Aarch64 cross-compiler for FPC ${FPC_VERSION}, too old'
else
  /usr/local/fpclazarus/bin/add_new_fpc_version_cross.sh ${FPC_VERSION} android aarch64
fi

/usr/local/fpclazarus/bin/add_new_fpc_version_lazarus.sh ${FPC_VERSION} ${LAZARUS_VERSION}

# Remove useless temp files, to conserve Docker image size
rm -Rf /tmp/fpcinst/
# Remove FPC sources and docs --  useless in a container, to conserve Docker image size
rm -Rf /usr/local/fpclazarus/${FPC_VERSION}/fpc/src/ \
       /usr/local/fpclazarus/${FPC_VERSION}/fpc/man/ \
       /usr/local/fpclazarus/${FPC_VERSION}/fpc/share/doc/

echo "OK: FPC ${FPC_VERSION} and Lazarus ${LAZARUS_VERSION} installed completely."
