#!/bin/bash
set -eux

# Test what add_new_fpc_version_cross.sh did.
# Pass the same arguments.

FPC_VERSION="$1"
FPC_OS="$2"
FPC_CPU="$3"
shift 3

bash <<EOF
# TODO: below assumes that OS in win32/win64, as we add .exe extension.

mkdir -p /tmp/fpc-test/
cd /tmp/fpc-test/
. /usr/local/fpclazarus/bin/setup.sh ${FPC_VERSION}

set +e
fpc -T${FPC_OS} -P${FPC_CPU} -l
set -e # ignore exit, it always makes error "No source file name in command line"

echo "begin Writeln('Hello from FPC'); end." > jenkins_fpclazarus_test.lpr
fpc -T${FPC_OS} -P${FPC_CPU} jenkins_fpclazarus_test.lpr
file jenkins_fpclazarus_test.exe
EOF

# Remove temp files, conserve Docker image size
rm -Rf /tmp/fpc-test/
