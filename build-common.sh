# Functions for building Docker images.

# cleanup --------------------------------------------------------------------------

ORIGINAL_DIR=`pwd`

function finish ()
{
  cd $ORIGINAL_DIR

  # These are paranoid cleanups, during normal execution these should be removed anyway:
  rm -f docker-context.no-cge/sdk-tools-linux.zip
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
  wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip --output-document=sdk-tools-linux.zip
  rm -Rf tools/
  unzip sdk-tools-linux.zip
  rm -f sdk-tools-linux.zip
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
  $DOCKER_TEST /usr/local/tests/bin/test_fpc_version.sh 3.0.2 1.6.4
  $DOCKER_TEST /usr/local/tests/bin/test_fpc_version.sh 3.0.4 1.8.0
  # back to strict mode
  IFS=$'\n\t'
}

do_build_cge ()
{
  local CGE_VERSION_LABEL="$1"
  local CGE_VERSION_TAG="$2"
  shift 2

  rm -Rf docker-context.cge/castle-engine/ # cleanup at beginning too, to be sure
  cd docker-context.cge/
  # Using --depth 1 to remove history from clone.
  # This makes clone faster, and (more important) makes resulting Docker image smaller.
  git clone --depth 1 --single-branch --branch "${CGE_VERSION_TAG}" https://github.com/castle-engine/castle-engine/
  # Add "make tools" target for CGE 6.4
  if [ "${CGE_VERSION_TAG}" = v6.4 ]; then
    cd castle-engine/
    patch -p1 < ../../cge-6.4.patch
    cd ../
  fi
  cd ../

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

do_upload ()
{
  local CGE_VERSION_LABEL="$1"
  shift 1

  export DOCKER_ID_USER="kambi"
  cat docker_password.txt | docker login --username="${DOCKER_ID_USER}" --password-stdin
  docker tag castle-engine-cloud-builds-tools:cge-"${CGE_VERSION_LABEL}" "${DOCKER_ID_USER}"/castle-engine-cloud-builds-tools:cge-"${CGE_VERSION_LABEL}"
  docker push "${DOCKER_ID_USER}"/castle-engine-cloud-builds-tools:cge-"${CGE_VERSION_LABEL}"
}
