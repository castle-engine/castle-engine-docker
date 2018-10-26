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
  # if [ ! -d docker-context/fpclazarus-switchable ]; then
  #   git clone git@gitlab.com:admin-michalis.ii.uni.wroc.pl/fpclazarus-switchable.git docker-context/fpclazarus-switchable
  # else
  #   cd docker-context/fpclazarus-switchable/
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
  cd docker-context/
  wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip --output-document=sdk-tools-linux.zip
  rm -Rf tools/
  unzip sdk-tools-linux.zip
  rm -f sdk-tools-linux.zip
  cd ../
}

do_build ()
{
  docker build -t castle-engine-cloud-builds-tools:cge-none -f Dockerfile docker-context/
}

# Run tests
do_test ()
{
  docker rm cge-test
  docker run --name cge-test -it castle-engine-cloud-builds-tools:cge-none
  docker start cge-test
  echo 'Test setting FPC versions:'
  docker exec cge-test bash -c 'source /usr/local/fpclazarus/bin/setup.sh default'
  docker exec cge-test bash -c 'source /usr/local/fpclazarus/bin/setup.sh trunk'
  echo 'Performing all the tests:'
  docker exec cge-test /usr/local/fpclazarus/bin/test_fpc_version.sh 3.0.2 1.6.4
  docker exec cge-test /usr/local/fpclazarus/bin/test_fpc_version.sh 3.0.4 1.8.0
  docker rm cge-test
}

do_upload ()
{
  export DOCKER_ID_USER="kambi"
  docker login
  docker tag castle-engine-cloud-builds-tools:cge-none "${DOCKER_ID_USER}"/castle-engine-cloud-builds-tools:cge-none
  docker push "${DOCKER_ID_USER}"/castle-engine-cloud-builds-tools:cge-none
}

do_prerequisites
do_build
do_test
do_upload
