#!/bin/bash
set -eux

# Compile and add FPC native version.
# At the beginning it removes existing FPC version in the same directory,
# to reliably add new one.
# The given version determines both links to download and directory names.
#
# Run this as root (sudo).
# Current dir doesn't matter.

FPC_VERSION="$1"
shift 1

# The architecture native to current host, name consistent with FPC tar.gz files
#FPC_HOST_CPU=i386
FPC_HOST_CPU=x86_64

# clean previous
rm -Rf /usr/local/fpclazarus/${FPC_VERSION}/fpc/
mkdir -p /usr/local/fpclazarus/${FPC_VERSION}/fpc/

rm -Rf /tmp/fpcinst/
mkdir /tmp/fpcinst/
cd /tmp/fpcinst/

# ----------------------------------------------------------------------------
# install official version for Linux with $FPC_HOST_CPU

# see https://sourceforge.net/projects/freepascal/files/Linux/${FPC_VERSION}/ for links
if [ "${FPC_VERSION}" = '3.2.0' ]; then
  FPC_URL="https://sourceforge.net/projects/freepascal/files/Linux/${FPC_VERSION}/fpc-${FPC_VERSION}-${FPC_HOST_CPU}-linux.tar/download"
  FPC_SUBDIR="fpc-${FPC_VERSION}-${FPC_HOST_CPU}-linux"
else
  # suitable for 3.0.2, 3.0.4, 3.2.2. So 3.2.0 was just an exception in the middle.
  FPC_URL="https://sourceforge.net/projects/freepascal/files/Linux/${FPC_VERSION}/fpc-${FPC_VERSION}.${FPC_HOST_CPU}-linux.tar/download"
  FPC_SUBDIR="fpc-${FPC_VERSION}.${FPC_HOST_CPU}-linux"
fi
wget "${WGET_OPTIONS:-}" "${FPC_URL}" --output-document fpc.tar
tar xvf fpc.tar
cd "${FPC_SUBDIR}"

# We will restore it after installation of FPC.
# For now, remove it, to make sure no links to our /usr/local/fpclazarus/fpc.cfg
# remain, and so it remains unmodified (paranoid).
rm -f /etc/fpc.cfg

echo '------------------------------------------------------------------------'
echo 'Running FPC installer.'

# Note: to make /etc/fpc.cfg work (it contains /usr/local/fpclazarus/$fpcversion),
# you really need to name this directory "${FPC_VERSION}", not anything else.
# You can later make symlinks to it, like default or android-default.
FPC_INSTALL_DIR="/usr/local/fpclazarus/${FPC_VERSION}/fpc/"
echo "Choosen ${FPC_INSTALL_DIR} as install prefix."

# Pass to install.sh 4 lines:
# - install dir
# - 3x "No" for "Install Textmode IDE", "Install documentation", "Install demos".
echo -e "${FPC_INSTALL_DIR}\nN\nN\nN\n" | ./install.sh

/usr/local/fpclazarus/bin/setup_fpc_etc.sh

# ----------------------------------------------------------------------------
# install sources

cd /tmp/fpcinst/
wget "${WGET_OPTIONS:-}" https://sourceforge.net/projects/freepascal/files/Source/${FPC_VERSION}/fpc-${FPC_VERSION}.source.tar.gz/download --output-document src.tar.gz
tar xzvf src.tar.gz
mv fpc-${FPC_VERSION} /usr/local/fpclazarus/${FPC_VERSION}/fpc/src

# ----------------------------------------------------------------------------
# Fix permissions (may be bad because of my restrictive umask)

/usr/local/fpclazarus/bin/fix_permissions.sh

echo "OK: FPC ${FPC_VERSION} (for host CPU, ${FPC_HOST_CPU})."
