#!/bin/bash
set -eux

# Compile and add Lazarus, with units for native and cross-compiling.
# At the beginning it removes existing Lazarus version in the same directory,
# to reliably add new one.
# The given Lazarus version (in $2) is only used to download proper zip archive,
# it doesn't determine any dir name.
#
# Run this as root (sudo).
# Current dir doesn't matter.

FPC_VERSION="$1"
LAZARUS_VERSION="$2"
shift 2

if [ "${LAZARUS_VERSION}" = '1.6.4' ]; then
  LAZARUS_URL="https://sourceforge.net/projects/lazarus/files/Lazarus%20Zip%20_%20GZip/Lazarus%20${LAZARUS_VERSION}/lazarus-${LAZARUS_VERSION}-0.tar.gz/download"
else
  LAZARUS_URL="https://sourceforge.net/projects/lazarus/files/Lazarus%20Zip%20_%20GZip/Lazarus%20${LAZARUS_VERSION}/lazarus-${LAZARUS_VERSION}.tar.gz/download"
fi

cd /usr/local/fpclazarus/${FPC_VERSION}/
rm -Rf lazarus
wget "${WGET_OPTIONS:-}" "${LAZARUS_URL}" --output-document lazarus-src.tar.gz
tar xzvf lazarus-src.tar.gz
rm -f lazarus-src.tar.gz

# ----------------------------------------------------------------------------
# Compile Lazarus

. /usr/local/fpclazarus/bin/setup.sh ${FPC_VERSION}

cd /usr/local/fpclazarus/${FPC_VERSION}/lazarus/
make
make OS_TARGET=win32 CPU_TARGET=i386
make OS_TARGET=win64 CPU_TARGET=x86_64

# Not really useful
# rm -Rf /tmp/fpcinst/laz-temp-install/
# mkdir /tmp/fpcinst/laz-temp-install/
# make install INSTALL_PREFIX=/tmp/fpcinst/laz-temp-install/

ln -s ../../lazarus/lazarus /usr/local/fpclazarus/${FPC_VERSION}/fpc/bin/lazarus-ide
ln -s ../../lazarus/tools/lazres /usr/local/fpclazarus/${FPC_VERSION}/fpc/bin/
ln -s ../../lazarus/tools/lrstolfm /usr/local/fpclazarus/${FPC_VERSION}/fpc/bin/
ln -s ../../lazarus/startlazarus /usr/local/fpclazarus/${FPC_VERSION}/fpc/bin/
ln -s ../../lazarus/tools/updatepofiles /usr/local/fpclazarus/${FPC_VERSION}/fpc/bin/
# We simply have a single lazbuild implementation,
# symlink it only to have all binaries in one directory.
ln -s /usr/local/fpclazarus/bin/lazbuild /usr/local/fpclazarus/${FPC_VERSION}/fpc/bin/

# Fix permissions
/usr/local/fpclazarus/bin/fix_permissions.sh

echo "OK: Lazarus ${LAZARUS_VERSION} based on FPC ${FPC_VERSION}."
