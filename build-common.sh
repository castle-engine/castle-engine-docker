# Functions for building Docker images.

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

do_prerequisites ()
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

  cd docker-context.no-cge/
  rm -Rf pasdoc/
  git clone --depth 1 --single-branch --branch master https://github.com/pasdoc/pasdoc/
  cd ../
}

do_build ()
{
  docker build -t castle-engine-cloud-builds-tools:cge-none -f Dockerfile.no-cge docker-context.no-cge/
}

# Run tests
do_test ()
{
  IFS=$' \n\t'
  local DOCKER_TEST="docker run --name test-without-cge --rm --volume=`pwd`/tests:/usr/local/tests/:ro -it castle-engine-cloud-builds-tools:cge-none"
  $DOCKER_TEST
  echo 'Test setting FPC versions:'
  $DOCKER_TEST bash -c 'source /usr/local/fpclazarus/bin/setup.sh default'
  $DOCKER_TEST bash -c 'source /usr/local/fpclazarus/bin/setup.sh trunk'
  echo 'Performing all the tests:'
  $DOCKER_TEST /usr/local/tests/bin/test_fpc_version.sh 3.0.2
  $DOCKER_TEST /usr/local/tests/bin/test_fpc_version.sh 3.0.4
  $DOCKER_TEST /usr/local/tests/bin/test_fpc_version.sh 3.2.0
  $DOCKER_TEST /usr/local/tests/bin/test_fpc_version.sh 3.2.2
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
  local DOCKER_TEST="docker run --name test-with-cge --rm -it castle-engine-cloud-builds-tools:cge-${CGE_VERSION_LABEL}"
  $DOCKER_TEST
  $DOCKER_TEST bash -c 'cd /usr/local/castle-engine/examples/fps_game/ && castle-engine compile'
  # back to strict mode
  IFS=$'\n\t'
}

if [ '(' "${docker_user:-}" = '' ')' -o '(' "${docker_password:-}" = '' ')' ]; then
  echo 'Docker user/password environment variables not defined (or empty), uploading would fail.'
  exit 1
fi

do_upload ()
{
  local CGE_VERSION_LABEL="$1"
  shift 1

  export DOCKER_ID_USER="${docker_user}"
  echo "${docker_password}" | docker login --username="${DOCKER_ID_USER}" --password-stdin
  docker tag castle-engine-cloud-builds-tools:cge-"${CGE_VERSION_LABEL}" "${DOCKER_ID_USER}"/castle-engine-cloud-builds-tools:cge-"${CGE_VERSION_LABEL}"
  docker push "${DOCKER_ID_USER}"/castle-engine-cloud-builds-tools:cge-"${CGE_VERSION_LABEL}"
}

# Upload to github packages, see https://github.com/castle-engine/castle-engine/packages?package_type=Docker
do_upload_github ()
{
  local CGE_VERSION_LABEL="$1"
  shift 1

  echo "${docker_github_token}" | docker login docker.pkg.github.com --username="${docker_github_user}" --password-stdin
  docker tag castle-engine-cloud-builds-tools:cge-"${CGE_VERSION_LABEL}" docker.pkg.github.com/castle-engine/castle-engine/castle-engine-cloud-builds-tools:cge-"${CGE_VERSION_LABEL}"
  docker push docker.pkg.github.com/castle-engine/castle-engine/castle-engine-cloud-builds-tools:cge-"${CGE_VERSION_LABEL}"
}
