#!/bin/bash
set -eu

# Use this on michalis.ii to update FPC from trunk now.

# Change with new FPC version ------------------------------------------------

FPC_TRUNK_VERSION='3.1.1'
FPC_STABLE_VERSION='3.0.2'

# FPC SVN checkout/update --------------------------------------------------------

FPC_SOURCE_DIR=/usr/local/fpclazarus/"${FPC_TRUNK_VERSION}"/fpc/src
FPC_SOURCE_DIR_PARENT="`dirname \"${FPC_SOURCE_DIR}\"`"
if [ '!' -d "${FPC_SOURCE_DIR}" ]; then
  echo 'First FPC checkout'
  mkdir -p "${FPC_SOURCE_DIR_PARENT}"
  cd "${FPC_SOURCE_DIR_PARENT}"
  svn co http://svn.freepascal.org/svn/fpc/trunk `basename ${FPC_SOURCE_DIR}`
else
  svn update "${FPC_SOURCE_DIR}"
fi

# Prepare Android ------------------------------------------------------------

# This is a subset of /usr/local/android/setup.sh
BASE_ANDROID=/usr/local/android/
export ANDROID_HOME="${BASE_ANDROID}"android-sdk-linux/
export ANDROID_NDK_HOME="${BASE_ANDROID}"android-ndk-r10c/
export PATH="${ANDROID_HOME}"tools/:"${ANDROID_HOME}"platform-tools/:"${ANDROID_NDK_HOME}"toolchains/arm-linux-androideabi-4.6/prebuilt/linux-x86/bin/:"${ANDROID_NDK_HOME}":"${PATH}"

# FPC Build and install ----------------------------------------------------------

FPC_INSTALL_DIR=/usr/local/fpclazarus/"${FPC_TRUNK_VERSION}"/fpc/
mkdir -p "${FPC_INSTALL_DIR}"

cd "${FPC_SOURCE_DIR}"
# build with last stable fpc
. /usr/local/fpclazarus/bin/setup.sh "${FPC_STABLE_VERSION}"
make clean all install INSTALL_PREFIX="${FPC_INSTALL_DIR}"
make clean crossall crossinstall OS_TARGET=win32 CPU_TARGET=i386 INSTALL_PREFIX="${FPC_INSTALL_DIR}"
make clean crossall crossinstall OS_TARGET=win64 CPU_TARGET=x86_64 INSTALL_PREFIX="${FPC_INSTALL_DIR}"
make clean crossall crossinstall \
  OS_TARGET=android CPU_TARGET=arm CROSSOPT="-CfVFPV3" \
  INSTALL_PREFIX="${FPC_INSTALL_DIR}"

# Set symlinks ---------------------------------------------------------------

cd "${FPC_INSTALL_DIR}"/bin

set_ppc_symlink ()
{
  TARGET_NAME="$1"
  TARGET="../lib/fpc/${FPC_TRUNK_VERSION}/${TARGET_NAME}"

  if [ -f "${TARGET}" ]; then
    rm -f "${TARGET_NAME}"
    ln -s "${TARGET}" .
  fi
}

set_ppc_symlink ppc386
set_ppc_symlink ppcx64
set_ppc_symlink ppcrossx64
set_ppc_symlink ppcrossarm

# Fix permissions ------------------------------------------------------------

/usr/local/fpclazarus/bin/fix_permissions.sh

# ----------------------------------------------------------------------------
# After updating FPC, always update also Lazarus, to recompile it with latest FPC trunk

/usr/local/fpclazarus/bin/update_trunk_lazarus.sh

# Test new compiler ----------------------------------------------------------

. /usr/local/fpclazarus/bin/setup.sh "${FPC_TRUNK_VERSION}"
echo 'New FPC version logo:'
fpc -l
fpc -Tlinux -Pi386 -l | head -n 1
fpc -Twin32 -Pi386 -l | head -n 1
fpc -Twin64 -Px86_64 -l | head -n 1
fpc -Tandroid -Parm -l | head -n 1
