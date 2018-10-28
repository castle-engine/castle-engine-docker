# Source this script in your shell.
# Note that this doesn't switch any symlinks,
# we do not have anything like /usr/local/fpclazarus/current/ ,
# to enable to compile various projects with various FPC versions in parallel by Jenkins.

export FPCLAZARUS_VERSION="$1"
echo 'Configured environment for FPC/Lazarus:' ${FPCLAZARUS_VERSION}
export PATH=/usr/local/fpclazarus/${FPCLAZARUS_VERSION}/fpc/bin/:"${PATH}"

export FPCLAZARUS_REAL_VERSION=`fpc -iV`
echo 'Real FPC version:' ${FPCLAZARUS_REAL_VERSION}

# This makes fpmake work OK.
export FPCDIR=/usr/local/fpclazarus/${FPCLAZARUS_VERSION}/fpc/lib/fpc/${FPCLAZARUS_REAL_VERSION}/

# The aliases are not automatically used in the Makefile, see
# https://stackoverflow.com/questions/7897549/make-ignores-my-python-bash-alias
# https://stackoverflow.com/questions/14451317/creating-an-alias-for-my-script-thru-makefile
# There are ways to workaround this ("make SHELL=..."),
# but we prefer for it to really work automatically,
# so that all scripts, that may call make, just automatically work with new setup.
#
# So we do this differently, by a script called "lazbuild" in fpc/bin/.
#
# alias lazbuild="lazbuild --lazarusdir=/usr/local/fpclazarus/$FPCLAZARUS_VERSION/lazarus"
