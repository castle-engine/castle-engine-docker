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
make crossinstall OS_TARGET=${FPC_OS} CPU_TARGET=${FPC_CPU} PREFIX=/tmp/fpcinst/test-install
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

echo 'Testing as jenkins ------------------------------------------------------'

# TODO: below assumes that OS in win32/win64, as we add .exe extension.

su jenkins <<EOF
set -eux

cd /tmp/
. /usr/local/fpclazarus/bin/setup.sh ${FPC_VERSION}

set +e
fpc -T${FPC_OS} -P${FPC_CPU} -l
set -e # ignore exit, it always makes error "No source file name in command line"

echo "begin Writeln('Hello from FPC'); end." > jenkins_fpclazarus_test.lpr
fpc -T${FPC_OS} -P${FPC_CPU} jenkins_fpclazarus_test.lpr
file jenkins_fpclazarus_test.exe

EOF

echo "OK: FPC ${FPC_VERSION} cross-compiler for ${FPC_OS} / ${FPC_CPU}."

