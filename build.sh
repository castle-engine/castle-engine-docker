#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

do_prerequisites ()
{
  # This could also be downloaded inside the container,
  # but then we would need to provide GitLab password inside container,
  # and developing the Dockerfile would be a bit more difficult
  # (it's simply easier to change fpclazarus-switchable/ dir without committing
  # each change, during testing).
  #
  # Later: let this be managed using GIT submodules.
  #
  # if [ ! -d docker-context.no-cge/fpclazarus-switchable ]; then
  #   git clone git@gitlab.com:admin-michalis.ii.uni.wroc.pl/fpclazarus-switchable.git docker-context.no-cge/fpclazarus-switchable
  # else
  #   cd docker-context.no-cge/fpclazarus-switchable/
  #   git pull --rebase
  #   cd ../../
  # fi

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
  docker rm test-without-cge
  docker run --name test-without-cge -it castle-engine-cloud-builds-tools:cge-none
  docker start test-without-cge
  echo 'Test setting FPC versions:'
  docker exec test-without-cge bash -c 'source /usr/local/fpclazarus/bin/setup.sh default'
  docker exec test-without-cge bash -c 'source /usr/local/fpclazarus/bin/setup.sh trunk'
  echo 'Performing all the tests:'
  docker exec test-without-cge /usr/local/fpclazarus/bin/test_fpc_version.sh 3.0.2 1.6.4
  docker exec test-without-cge /usr/local/fpclazarus/bin/test_fpc_version.sh 3.0.4 1.8.0
  docker rm test-without-cge
}

do_build_cge ()
{
  local CGE_VERSION_LABEL="$1"
  local CGE_VERSION_TAG="$2"
  shift 2

  rm -Rf docker-context.cge/castle-engine/ # cleanup at beginning too, to be sure
  cd docker-context.cge/
  git https://github.com/castle-engine/castle-engine/
  if [ -n "${CGE_VERSION_TAG}" ]; then
    git checkout tags/"${CGE_VERSION_TAG}"
  fi
  cd ../

  # Note that regardless of "${CGE_VERSION_LABEL}",
  # we use the same Dockerfile.cge .
  # That's right, the images differ only in having different CGE code.

  docker build -t castle-engine-cloud-builds-tools:cge-"${CGE_VERSION_LABEL}" -f Dockerfile.cge docker-context.cge/

  rm -Rf docker-context.cge/castle-engine/ # cleanup

  docker rm test-with-cge
  docker run --name test-with-cge -it castle-engine-cloud-builds-tools:cge-"${CGE_VERSION_LABEL}"
  docker start test-with-cge
  docker exec test-with-cge /usr/local/fpclazarus/bin/test_fpc_version.sh 3.0.4 1.8.0
  docker rm test-with-cge
}

do_upload_all ()
{
  export DOCKER_ID_USER="kambi"
  docker login
  docker tag castle-engine-cloud-builds-tools:cge-none "${DOCKER_ID_USER}"/castle-engine-cloud-builds-tools:cge-none
  docker tag castle-engine-cloud-builds-tools:cge-stable "${DOCKER_ID_USER}"/castle-engine-cloud-builds-tools:cge-stable
  docker tag castle-engine-cloud-builds-tools:cge-unstable "${DOCKER_ID_USER}"/castle-engine-cloud-builds-tools:cge-unstable
  docker push "${DOCKER_ID_USER}"/castle-engine-cloud-builds-tools:cge-none
  docker push "${DOCKER_ID_USER}"/castle-engine-cloud-builds-tools:cge-stable
  docker push "${DOCKER_ID_USER}"/castle-engine-cloud-builds-tools:cge-unstable
}


# do_prerequisites
do_build
# do_test
do_build_cge stable v6.4
do_build_cge unstable ''
do_upload_all
