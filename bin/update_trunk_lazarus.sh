#!/bin/bash
set -eu

# Use this to update Lazarus from trunk, based on FPC trunk.

LAZARUS_SVN_REVISION="$1"
shift 1

# Change with new FPC version ------------------------------------------------

FPC_TRUNK_VERSION='3.3.1'

# Lazarus SVN checkout/update --------------------------------------------------------

LAZARUS_SOURCE_DIR=/usr/local/fpclazarus/"${FPC_TRUNK_VERSION}"/lazarus
LAZARUS_SOURCE_DIR_PARENT="`dirname \"${LAZARUS_SOURCE_DIR}\"`"
if [ '!' -d "${LAZARUS_SOURCE_DIR}" ]; then
  echo 'First Lazarus checkout'
  mkdir -p "${LAZARUS_SOURCE_DIR_PARENT}"
  cd "${LAZARUS_SOURCE_DIR_PARENT}"
  svn co -r "${LAZARUS_SVN_REVISION}" https://svn.freepascal.org/svn/lazarus/trunk `basename ${LAZARUS_SOURCE_DIR}`
else
  svn update -r "${LAZARUS_SVN_REVISION}" "${LAZARUS_SOURCE_DIR}"
fi

# Build ----------------------------------------------------------------------

cd "${LAZARUS_SOURCE_DIR}"
. /usr/local/fpclazarus/bin/setup.sh "${FPC_TRUNK_VERSION}"
make
make OS_TARGET=win32 CPU_TARGET=i386
make OS_TARGET=win64 CPU_TARGET=x86_64

# Remove previous symlinks, if any
rm -f /usr/local/fpclazarus/"${FPC_TRUNK_VERSION}"/fpc/bin/lazarus-ide \
      /usr/local/fpclazarus/"${FPC_TRUNK_VERSION}"/fpc/bin/lazres \
      /usr/local/fpclazarus/"${FPC_TRUNK_VERSION}"/fpc/bin/lrstolfm \
      /usr/local/fpclazarus/"${FPC_TRUNK_VERSION}"/fpc/bin/startlazarus \
      /usr/local/fpclazarus/"${FPC_TRUNK_VERSION}"/fpc/bin/updatepofiles \
      /usr/local/fpclazarus/"${FPC_TRUNK_VERSION}"/fpc/bin/lazbuild

ln -s ../../lazarus/lazarus /usr/local/fpclazarus/"${FPC_TRUNK_VERSION}"/fpc/bin/lazarus-ide
ln -s ../../lazarus/tools/lazres /usr/local/fpclazarus/"${FPC_TRUNK_VERSION}"/fpc/bin/
ln -s ../../lazarus/tools/lrstolfm /usr/local/fpclazarus/"${FPC_TRUNK_VERSION}"/fpc/bin/
ln -s ../../lazarus/startlazarus /usr/local/fpclazarus/"${FPC_TRUNK_VERSION}"/fpc/bin/
ln -s ../../lazarus/tools/updatepofiles /usr/local/fpclazarus/"${FPC_TRUNK_VERSION}"/fpc/bin/
# We simply have a single lazbuild implementation,
# symlink it only to have all binaries in one directory.
ln -s /usr/local/fpclazarus/bin/lazbuild /usr/local/fpclazarus/"${FPC_TRUNK_VERSION}"/fpc/bin/

# Fix permissions ------------------------------------------------------------

/usr/local/fpclazarus/bin/fix_permissions.sh

# Test ----------------------------------------------------------------------

echo 'New Lazarus version:'
lazbuild --version
