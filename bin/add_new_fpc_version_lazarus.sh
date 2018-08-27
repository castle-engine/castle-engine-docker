#!/bin/bash
set -eux

FPC_VERSION="$1"
LAZARUS_VERSION="$2"
shift 2

cd /usr/local/fpclazarus/${FPC_VERSION}/
rm -Rf lazarus
wget https://sourceforge.net/projects/lazarus/files/Lazarus%20Zip%20_%20GZip/Lazarus%20${LAZARUS_VERSION}/lazarus-${LAZARUS_VERSION}.tar.gz/download --output-document lazarus-src.tar.gz
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

echo 'Testing as jenkins ------------------------------------------------------'

# ----------------------------------------------------------------------------
# check Lazarus

su jenkins <<EOF
set -eux

. /usr/local/fpclazarus/bin/setup.sh ${FPC_VERSION}

type lazarus-ide # cannot run, requires X
lazbuild --version
lazres
lrstolfm
type startlazarus # cannot run, requires X
updatepofiles

cd /var/lib/jenkins/workspace/castle_game_engine_build/
make clean

. /usr/local/fpclazarus/bin/setup.sh ${FPC_VERSION}
# lazbuild should be an alias that uses --lazarusdir=... always
lazbuild packages/castle_base.lpk
lazbuild packages/castle_components.lpk
lazbuild --os=win32 --cpu=i386 packages/castle_components.lpk
lazbuild --os=win64 --cpu=x86_64 packages/castle_components.lpk

if [ -f ~/.lazarus/environmentoptions.xml ]; then
  echo '~/.lazarus/environmentoptions.xml exists, but will be ignored by us'
  cat ~/.lazarus/environmentoptions.xml
else
  echo '~/.lazarus/environmentoptions.xml does not exists, and we will not create it'
fi

echo '~/.michalis-lazarus/${FPC_VERSION}/environmentoptions.xml should exist and contain proper <LazarusDirectory Value="..." />'
cat ~/.michalis-lazarus/${FPC_VERSION}/environmentoptions.xml

EOF

echo 'DONE OK.'
