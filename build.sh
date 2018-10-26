#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# This could also be downloaded inside the container,
# but then we would need to provide GitLab password inside container,
# and developing the Dockerfile would be a bit more difficult
# (it's simply easier to change fpclazarus-switchable/ dir without committing
# each change, during testing).
if [ ! -d fpclazarus-switchable ]; then
  git clone git@gitlab.com:admin-michalis.ii.uni.wroc.pl/fpclazarus-switchable.git
else
  # TODO: uncomment
  cd fpclazarus-switchable/
  # git pull --rebase
  cd ../
fi

# This could also be downloaded inside container.
# But it's faster (during Dockerfile development),
# to download it only once, outside of the container.
#
# Get the link from https://developer.android.com/studio/ :
# - "Command line tools only",
# - click on dialog where you accept the license,
# - and then copy URL of the download.
# TODO: uncomment
#wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip --output-document=sdk-tools-linux.zip

docker build -t castle-engine-cloud-builds-tools:no-cge docker-context/

# TODO: use below
# docker images
# docker run castle-engine-cloud-builds-tools
# test: docker run -it castle-engine-cloud-builds-tools /bin/bash
# docker ps -a

# docker login
# docker tag image kambi/castle-engine-cloud-builds-tools:latest
# docker push kambi/castle-engine-cloud-builds-tools:latest
