#!/bin/bash
set -eux

# Test what add_new_fpc_version_native.sh did.
# Pass the same arguments.

FPC_VERSION="$1"
LAZARUS_VERSION="$2"
shift 2

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
