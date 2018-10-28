#!/bin/bash
set -eux

# Test what add_new_fpc_version_native.sh did.
# Pass the same arguments.

FPC_VERSION="$1"
shift 1

bash <<EOF
mkdir -p /tmp/fpc-test/
cd /tmp/fpc-test/
. /usr/local/fpclazarus/bin/setup.sh ${FPC_VERSION}

set +e
fpc -l
set -e # Ignore exit status, this always fails with "error: no source code"

echo "begin Writeln('Hello from FPC'); end." > jenkins_fpclazarus_test.lpr
fpc jenkins_fpclazarus_test.lpr
./jenkins_fpclazarus_test
EOF

# Remove temp files, conserve Docker image size
rm -Rf /tmp/fpc-test/
