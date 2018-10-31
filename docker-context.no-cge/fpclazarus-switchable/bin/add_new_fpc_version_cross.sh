#!/bin/bash
set -eux

# Compile and add FPC cross-compiler.
#
# Run this as root (sudo).
# Current dir doesn't matter.
#
# References:
# http://wiki.lazarus.freepascal.org/Cross_compiling
# http://wiki.lazarus.freepascal.org/Cross_compiling_for_Win32_under_Linux

FPC_VERSION="$1"
FPC_OS="$2"
FPC_CPU="$3"
# rest of parameters are passed to make crossinstall
shift 3

cd /tmp/fpcinst/
# Copy sources, to not pollute the clean sources
cp -R /usr/local/fpclazarus/${FPC_VERSION}/fpc/src/ src-for-${FPC_CPU}-${FPC_OS}
cd src-for-${FPC_CPU}-${FPC_OS}

# include the fpc version to bootstrap - same or previous
. /usr/local/fpclazarus/bin/setup.sh ${FPC_VERSION}

make crossall OS_TARGET=${FPC_OS} CPU_TARGET=${FPC_CPU}

rm -Rf /tmp/fpcinst/test-install
mkdir -p /tmp/fpcinst/test-install
make crossinstall OS_TARGET=${FPC_OS} CPU_TARGET=${FPC_CPU} PREFIX=/tmp/fpcinst/test-install "$@"
mv /tmp/fpcinst/test-install/lib/fpc/${FPC_VERSION}/units/${FPC_CPU}-${FPC_OS}/ /usr/local/fpclazarus/${FPC_VERSION}/fpc/lib/fpc/${FPC_VERSION}/units/
ls -Flah /usr/local/fpclazarus/${FPC_VERSION}/fpc/lib/fpc/${FPC_VERSION}/units/

# Fix permissions
/usr/local/fpclazarus/bin/fix_permissions.sh

# Copy fpc binary for another CPU

for F in /tmp/fpcinst/test-install/lib/fpc/${FPC_VERSION}/ppcross*; do
  FBASE=`basename $F`
  echo '----------------------------------------------------------'
  echo "Found cross-compiler to another CPU as $FBASE, which means the target CPU differs from current."

  cp -f /tmp/fpcinst/test-install/lib/fpc/${FPC_VERSION}/${FBASE} /usr/local/fpclazarus/${FPC_VERSION}/fpc/lib/fpc/${FPC_VERSION}/
  ln -s /usr/local/fpclazarus/${FPC_VERSION}/fpc/lib/fpc/${FPC_VERSION}/${FBASE} /usr/local/fpclazarus/${FPC_VERSION}/fpc/bin/
  ls -Flah /usr/local/fpclazarus/${FPC_VERSION}/fpc/lib/fpc/${FPC_VERSION}/
done

echo "OK: FPC ${FPC_VERSION} cross-compiler for ${FPC_OS} / ${FPC_CPU}."

