# Functions for building Docker images.

# Enable BuildKit ( https://docs.docker.com/build/#to-enable-buildkit-builds )
# because:
# - We use "COPY --chmod...", see https://docs.docker.com/develop/develop-images/build_enhancements/
# - We may use other interesting features, see
#   https://medium.com/@tonistiigi/advanced-multi-stage-build-patterns-6f741b852fae
export DOCKER_BUILDKIT=1

# cleanup --------------------------------------------------------------------------

ORIGINAL_DIR=`pwd`

function finish ()
{
  cd $ORIGINAL_DIR

  # These are paranoid cleanups, during normal execution these should be removed anyway:
  rm -f docker-context.no-cge/android-cmdline-tools-linux.zip
  set +e
  docker rm test-without-cge > /dev/null 2>&1
  docker rm test-with-cge > /dev/null 2>&1
  set -e # ignore if no such container

  # This is necessary cleanup, during normal execution be don't bother trying to remove it:
  rm -Rf docker-context.cge/castle-engine/
}
trap finish EXIT

# functions ---------------------------------------------------------------------

# Install Android cmdline tools in docker-context.no-cge/
do_prerequisite_android_cmdline_tools ()
{
  # This could also be downloaded inside container.
  # But it's faster (during Dockerfile development),
  # to download it only once, outside of the container.
  #
  # Get the link from https://developer.android.com/studio/ :
  # - "Command line tools only",
  # - click on dialog where you accept the license,
  # - and then copy URL of the download.
  cd docker-context.no-cge/
  # latest version as of 2021-07-18
  wget 'https://dl.google.com/android/repository/commandlinetools-linux-7302050_latest.zip' \
    --output-document=android-cmdline-tools-linux.zip
  rm -Rf cmdline-tools/
  unzip android-cmdline-tools-linux.zip
  rm -f android-cmdline-tools-linux.zip
  cd ../
}

# Put PasDoc sources in docker-context.no-cge/
do_prerequisite_pasdoc_src ()
{
  cd docker-context.no-cge/
  rm -Rf pasdoc/
  git clone --depth 1 --single-branch --branch master https://github.com/pasdoc/pasdoc/
  cd ../
}

do_prerequisite_cleanup ()
{
  rm -Rf docker-context.no-cge/bin/
  mkdir -p docker-context.no-cge/bin/
}

# Put GitHub CLI ( https://cli.github.com/ ) binary in docker-context.no-cge/bin/
do_prerequisite_gh_cli ()
{
  cd docker-context.no-cge/

  # just pick latest from https://github.com/cli/cli/releases
  local GH_CLI_VERSION=2.51.0
  wget https://github.com/cli/cli/releases/download/v"${GH_CLI_VERSION}"/gh_"${GH_CLI_VERSION}"_linux_amd64.tar.gz --output-document gh.tar.gz

  local GH_CLI_DIR=gh_"${GH_CLI_VERSION}"_linux_amd64
  tar xzvf gh.tar.gz "${GH_CLI_DIR}"/bin/gh
  mv -f "${GH_CLI_DIR}"/bin/gh bin/gh
  rm -Rf "${GH_CLI_DIR}" gh.tar.gz

  cd ../
}

# Put repository_cleanup in docker-context.no-cge/bin/
do_prerequisite_repository_cleanup ()
{
  wget 'https://raw.githubusercontent.com/castle-engine/cge-scripts/master/repository_cleanup' \
    --output-document docker-context.no-cge/bin/repository_cleanup
}

# Put PVRTexToolCLI in docker-context.no-cge/bin/
# See https://github.com/floooh/oryol/tree/master/tools
# License on https://github.com/floooh/oryol/blob/master/tools/PowerVR_SDK_End_User_Licence_Agreement.txt
do_prerequisite_PVRTexToolCLI ()
{
  wget 'https://github.com/floooh/oryol/blob/master/tools/linux/PVRTexToolCLI?raw=true' \
    --output-document docker-context.no-cge/bin/PVRTexToolCLI
}

# Get Compressonator https://gpuopen.com/compressonator/ into docker-context.no-cge/
do_prerequisite_compressonator ()
{
  cd docker-context.no-cge/
  rm -Rf compressonatorcli compressonatorcli.tar.gz

  # Look at https://github.com/GPUOpen-Tools/Compressonator/releases for links
  TARGZ_VERSION=4.5.52
  wget https://github.com/GPUOpen-Tools/compressonator/releases/download/V"${TARGZ_VERSION}"/compressonatorcli-"${TARGZ_VERSION}"-Linux.tar.gz \
    --output-document compressonatorcli.tar.gz
  tar xzvf compressonatorcli.tar.gz
  mv compressonatorcli-"${TARGZ_VERSION}"-Linux/ compressonatorcli/
  rm -Rf compressonatorcli/documents compressonatorcli/images # not useful

  cat > bin/compressonatorcli <<EOF
#!/bin/bash
set -eu
# Pass arguments to another compressonatorcli script,
# which in turn calls compressonatorcli-bin.
# That next compressonatorcli script must get full absolute path in $0 to work.
/usr/local/compressonatorcli/compressonatorcli "\$@"
EOF
  cd ../
}

do_build ()
{
  docker build -t castle-engine-cloud-builds-tools:cge-none -f Dockerfile.no-cge docker-context.no-cge/
  docker build -t castle-engine-cloud-builds-tools:cge-none-fpc320 -f Dockerfile.no-cge docker-context.no-cge/ \
    --build-arg DOCKER_FPCLAZARUS_VERSION=3.2.0
  docker build -t castle-engine-cloud-builds-tools:cge-none-fpc331 -f Dockerfile.no-cge docker-context.no-cge/ \
    --build-arg DOCKER_FPCLAZARUS_VERSION=3.3.1
}

# Run tests
do_test ()
{
  IFS=$' \n\t'
  local DOCKER_TEST="docker run --name test-without-cge --rm --volume=`pwd`/tests:/usr/local/tests/:ro"
  $DOCKER_TEST castle-engine-cloud-builds-tools:cge-none
  echo 'Test setting FPC versions:'
  $DOCKER_TEST castle-engine-cloud-builds-tools:cge-none bash -c 'source /usr/local/fpclazarus/bin/setup.sh default'
  echo 'Performing all the tests:'
  $DOCKER_TEST castle-engine-cloud-builds-tools:cge-none /usr/local/tests/bin/test_fpc_version.sh 3.2.2
  $DOCKER_TEST castle-engine-cloud-builds-tools:cge-none-fpc331 /usr/local/tests/bin/test_fpc_version.sh 3.3.1
  $DOCKER_TEST castle-engine-cloud-builds-tools:cge-none-fpc320 /usr/local/tests/bin/test_fpc_version.sh 3.2.0
  # back to strict mode
  IFS=$'\n\t'
}

do_build_cge ()
{
  local CGE_VERSION_LABEL="$1"
  local CGE_VERSION_BRANCH="$2"
  shift 2

  rm -Rf docker-context.cge/castle-engine/ # cleanup at beginning too, to be sure
  cd docker-context.cge/
  # Using --depth 1 to remove history from clone.
  # This makes clone faster, and (more important) makes resulting Docker image smaller.
  git clone --depth 1 --single-branch --branch "${CGE_VERSION_BRANCH}" https://github.com/castle-engine/castle-engine/
  cd castle-engine/
  git log -1 > last_commit.txt
  cd ../../

  # Note that regardless of "${CGE_VERSION_LABEL}",
  # we use the same Dockerfile.cge .
  # That's right, the images differ only in having different CGE code.

  docker build -t castle-engine-cloud-builds-tools:cge-"${CGE_VERSION_LABEL}" -f Dockerfile.cge docker-context.cge/
}

do_test_cge ()
{
  local CGE_VERSION_LABEL="$1"
  shift 1

  IFS=$' \n\t'
  local DOCKER_TEST="docker run --name test-with-cge --rm castle-engine-cloud-builds-tools:cge-${CGE_VERSION_LABEL}"
  $DOCKER_TEST
  # When choosing this test, remember it has to be an example that is both
  # in CGE stable and unstable versions.
  $DOCKER_TEST bash -c 'cd /usr/local/castle-engine/examples/animations/play_animation && castle-engine compile'
  # back to strict mode
  IFS=$'\n\t'
}

if [ '(' "${DOCKER_USER:-}" = '' ')' -o '(' "${DOCKER_PASSWORD:-}" = '' ')' ]; then
  echo 'Docker user/password environment variables not defined (or empty), uploading would fail.'
  exit 1
fi

do_upload ()
{
  local CGE_VERSION_LABEL="$1"
  shift 1

  export DOCKER_ID_USER="${DOCKER_USER}"
  echo "${DOCKER_PASSWORD}" | docker login --username="${DOCKER_ID_USER}" --password-stdin
  docker tag castle-engine-cloud-builds-tools:cge-"${CGE_VERSION_LABEL}" "${DOCKER_ID_USER}"/castle-engine-cloud-builds-tools:cge-"${CGE_VERSION_LABEL}"
  docker push "${DOCKER_ID_USER}"/castle-engine-cloud-builds-tools:cge-"${CGE_VERSION_LABEL}"
}

# Upload to github packages, see https://github.com/castle-engine/castle-engine/packages?package_type=Docker
do_upload_github ()
{
  local CGE_VERSION_LABEL="$1"
  shift 1

  echo "${DOCKER_GITHUB_TOKEN}" | docker login docker.pkg.github.com --username="${DOCKER_GITHUB_USER}" --password-stdin
  docker tag castle-engine-cloud-builds-tools:cge-"${CGE_VERSION_LABEL}" docker.pkg.github.com/castle-engine/castle-engine/castle-engine-cloud-builds-tools:cge-"${CGE_VERSION_LABEL}"
  docker push docker.pkg.github.com/castle-engine/castle-engine/castle-engine-cloud-builds-tools:cge-"${CGE_VERSION_LABEL}"
}

# Do everything necessary to build and upload cge-none and cge-none-fpc* images.
#
# Note: Do this, including uploading, before do_build_cge,
# as Dockerfile.cge uses cge-none image from Dockerhub.
do_everything_for_image_none ()
{
  do_prerequisite_cleanup
  do_prerequisite_android_cmdline_tools
  do_prerequisite_pasdoc_src
  do_prerequisite_gh_cli
  do_prerequisite_repository_cleanup
  do_prerequisite_PVRTexToolCLI
  do_prerequisite_compressonator

  do_build
  do_test

  do_upload none
  do_upload none-fpc320
  do_upload none-fpc331
  do_upload_github none
  do_upload_github none-fpc320
  do_upload_github none-fpc331
}

# Do everything necessary to build and upload cge-stable image.
do_everything_for_image_stable ()
{
  do_build_cge stable v7.0-alpha.3
  do_test_cge stable
  do_upload stable
  do_upload_github stable
}

# Do everything necessary to build and upload cge-unstable image.
do_everything_for_image_unstable ()
{
  do_build_cge unstable snapshot
  do_test_cge unstable
  do_upload unstable
  do_upload_github unstable
}
