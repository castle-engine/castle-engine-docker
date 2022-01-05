#!/bin/bash
set -eu

# Use this to update Lazarus from trunk, based on FPC trunk.

LAZARUS_GIT_HASH="$1"
shift 1

# Change with new FPC version ------------------------------------------------

FPC_TRUNK_VERSION='3.3.1'

# Lazarus GIT clone ----------------------------------------------------------

LAZARUS_SOURCE_DIR=/usr/local/fpclazarus/"${FPC_TRUNK_VERSION}"/lazarus
LAZARUS_SOURCE_DIR_PARENT="`dirname \"${LAZARUS_SOURCE_DIR}\"`"

echo 'Lazarus clone:'
rm -Rf "${LAZARUS_SOURCE_DIR}"
mkdir -p "${LAZARUS_SOURCE_DIR_PARENT}"
cd "${LAZARUS_SOURCE_DIR_PARENT}"
# Note: using  --depth 1 would also speed this up, but then doing "git checkout" to historic revisions is not possible
git clone --single-branch --branch main https://gitlab.com/freepascal.org/lazarus/lazarus.git `basename ${LAZARUS_SOURCE_DIR}`

cd "${LAZARUS_SOURCE_DIR}"
git checkout "${LAZARUS_GIT_HASH}"

# Remove .git, to conserve Docker container size
rm -Rf "${LAZARUS_SOURCE_DIR}"/.git/

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
