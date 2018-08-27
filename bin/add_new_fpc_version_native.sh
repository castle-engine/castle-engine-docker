#!/bin/bash
set -eux

FPC_VERSION="$1"
shift 1

# The architecture native to michalis.ii.uni.wroc.pl, name consistent with FPC tar.gz files
#FPC_ARCH=i386
FPC_ARCH=x86_64

# clean previous
rm -Rf /usr/local/fpclazarus/${FPC_VERSION}/fpc/
mkdir -p /usr/local/fpclazarus/${FPC_VERSION}/fpc/

rm -Rf /tmp/fpcinst/
mkdir /tmp/fpcinst/
cd /tmp/fpcinst/

# ----------------------------------------------------------------------------
# install official version for Linux with $FPC_ARCH

# see https://sourceforge.net/projects/freepascal/files/Linux/${FPC_VERSION}/ for links
wget https://sourceforge.net/projects/freepascal/files/Linux/${FPC_VERSION}/fpc-${FPC_VERSION}.${FPC_ARCH}-linux.tar/download --output-document fpc.tar
tar xvf fpc.tar
cd fpc-${FPC_VERSION}.${FPC_ARCH}-linux/

cp -f /etc/fpc.cfg /etc/fpc.cfg.michalis-backup

echo '------------------------------------------------------------------------'
echo 'Running FPC installer.'
echo "Choose /usr/local/fpclazarus/${FPC_VERSION}/fpc/ as install prefix."
# Note: to make /etc/fpc.cfg work (it contains /usr/local/fpclazarus/$fpcversion),
# you really need to name it "${FPC_VERSION}", not anything else.
# You can later make symlinks to it, like default or android-default.
./install.sh

# The above may modify /etc/fpc.cfg, REVERT IT.
# We want to maintain /etc/fpc.cfg manually.
mv -f /etc/fpc.cfg.michalis-backup /etc/fpc.cfg

echo '---------------------------------------------------------------------'
echo 'Reverted /etc/fpc.cfg. Make sure it looks OK:'
cat /etc/fpc.cfg
echo 'End of /etc/fpc.cfg ---------------------------------------------'

# For now, just remove fppkg stuff.
mv -f /etc/fppkg* .
echo '/etc/fp* config files: -----------------------------------------------'
ls -Flah /etc/fp*

# ----------------------------------------------------------------------------
# install sources

cd /tmp/fpcinst/
wget https://sourceforge.net/projects/freepascal/files/Source/${FPC_VERSION}/fpc-${FPC_VERSION}.source.tar.gz/download --output-document src.tar.gz
tar xzvf src.tar.gz
mv fpc-${FPC_VERSION} /usr/local/fpclazarus/${FPC_VERSION}/fpc/src

# ----------------------------------------------------------------------------
# Fix permissions (may be bad because of my restrictive umask)

/usr/local/fpclazarus/bin/fix_permissions.sh

# ----------------------------------------------------------------------------
# Check

echo 'Testing as jenkins ------------------------------------------------------'

su jenkins <<EOF
set -eux

cd /tmp/
. /usr/local/fpclazarus/bin/setup.sh ${FPC_VERSION}
fpc -l
echo "begin Writeln('Hello from FPC'); end." > jenkins_fpclazarus_test.lpr
fpc jenkins_fpclazarus_test.lpr
./jenkins_fpclazarus_test

EOF

echo 'DONE OK.'
