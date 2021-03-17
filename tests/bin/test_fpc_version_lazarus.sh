#!/bin/bash
set -eux

# Test Lazarus with FPC/Lazarus combination from $1.

FPC_VERSION="$1"
shift 1

mkdir -p /tmp/lazarus-test/
cd /tmp/lazarus-test/

cat > test_package.lpk <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<CONFIG>
  <Package Version="4">
    <CompilerOptions>
      <Version Value="11"/>
      <SearchPaths>
        <UnitOutputDirectory Value="lib/\$(TargetCPU)-\$(TargetOS)"/>
      </SearchPaths>
    </CompilerOptions>
    <Name Value="test_package"/>
    <Type Value="RunAndDesignTime"/>
    <Files Count="1">
      <Item1>
        <Filename Value="testpackageunit.pas"/>
        <UnitName Value="TestPackageUnit"/>
      </Item1>
    </Files>
    <RequiredPkgs Count="1">
      <Item1>
        <PackageName Value="LazOpenGLContext"/>
      </Item1>
    </RequiredPkgs>
  </Package>
</CONFIG>
EOF

cat > testpackageunit.pas <<EOF
unit TestPackageUnit;
interface
implementation
end.
EOF

bash <<EOF
. /usr/local/fpclazarus/bin/setup.sh ${FPC_VERSION}

type lazarus-ide # cannot run, requires X
lazbuild --version
lazres
lrstolfm
type startlazarus # cannot run, requires X
updatepofiles

. /usr/local/fpclazarus/bin/setup.sh ${FPC_VERSION}
# lazbuild should be an alias that uses --lazarusdir=... always
lazbuild                         test_package.lpk
lazbuild --os=win32 --cpu=i386   test_package.lpk
lazbuild --os=win64 --cpu=x86_64 test_package.lpk

if [ -f ~/.lazarus/environmentoptions.xml ]; then
  echo '~/.lazarus/environmentoptions.xml exists, but will be ignored by us'
  cat ~/.lazarus/environmentoptions.xml
else
  echo '~/.lazarus/environmentoptions.xml does not exists, and we will not create it'
fi

echo '~/.cge-jenkins-lazarus/${FPC_VERSION}/environmentoptions.xml should exist and contain proper <LazarusDirectory Value="..." />'
cat ~/.cge-jenkins-lazarus/${FPC_VERSION}/environmentoptions.xml
EOF

# Remove temp files, conserve Docker image size
rm -Rf /tmp/lazarus-test/
