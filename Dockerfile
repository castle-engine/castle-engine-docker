# -*- mode: shell-script -*-
#
# Dockerfile that defines the Docker image for CGE cloud builds tools.
# Used by build.sh.

FROM debian:stable

# Install and configure Debian tools -----------------------------------------

# Reasons of packages:
# - wget is for downloading in /usr/local/fpclazarus/bin/add_new_fpc_version.sh
# - libgtkglext1-dev is for compiling applications on Linux
#   with CGE CastleWindow backend (pulls a lot of other -dev packages)
# - subversion is for gettting FPC/Lazarus trunk
# - default-jdk is for Android SDK
# - unzip is to unpack Android SDK
RUN apt-get update && \
  apt-get -y install \
    wget \
    libgtkglext1-dev \
    subversion \
    default-jdk \
    unzip

# Makes wget output shorter and better
ENV WGET_OPTIONS --progress=bar:force:noscroll

# Matches Debian default-jdk result
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/

# Android SDK, NDK -----------------------------------------------------------

# We call thes variables CGE_JENKINS_xxx, to make it clear that CGE *ignores them*,
# they are only useful for Dockerfile and scripts inside this Docker container.
ENV CGE_JENKINS_ANDROID_PLATFORM=23
ENV CGE_JENKINS_ANDROID_BUILD_TOOLS=23.0.2

ENV ANDROID_HOME=/usr/local/android/android-sdk/
ENV ANDROID_NDK_HOME=/usr/local/android/android-sdk/ndk-bundle/
ENV PATH="${PATH}:/usr/local/android/android-sdk/tools/:\
/usr/local/android/android-sdk/platform-tools/:\
/usr/local/android/android-sdk/ndk-bundle/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/:\
/usr/local/android/android-sdk/ndk-bundle/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/bin/:\
/usr/local/android/android-sdk/ndk-bundle/"

COPY sdk-tools-linux.zip /usr/local/android/android-sdk/sdk-tools-linux.zip
RUN cd /usr/local/android/android-sdk/ && unzip sdk-tools-linux.zip

RUN yes | /usr/local/android/android-sdk/tools/bin/sdkmanager --licenses

RUN /usr/local/android/android-sdk/tools/bin/sdkmanager --install \
  "platforms;android-${CGE_JENKINS_ANDROID_PLATFORM}" \
  "extras;google;google_play_services" \
  "build-tools;${CGE_JENKINS_ANDROID_BUILD_TOOLS}" \
  "extras;android;m2repository" \
  "ndk-bundle"

# android-cge-default-platform is used by our fpc.cfg
RUN ln -s \
  /usr/local/android/android-sdk/ndk-bundle/platforms/android-"${CGE_JENKINS_ANDROID_PLATFORM}" \
  /usr/local/android/android-sdk/ndk-bundle/platforms/android-cge-default-platform

RUN echo 'source /usr/local/fpclazarus/bin/setup.sh android-default' > /usr/local/android/setup.sh

# FPC + Lazarus --------------------------------------------------------------

# Expect fpclazarus-switchable already downloaded here
# RUN git clone git@gitlab.com:admin-michalis.ii.uni.wroc.pl/fpclazarus-switchable.git
COPY fpclazarus-switchable /usr/local/fpclazarus

RUN chown -R root:staff /usr/local/fpclazarus/ && \
    chmod -R a+rX /usr/local/fpclazarus/

RUN /usr/local/fpclazarus/bin/add_new_fpc_version.sh 3.0.2 1.6.4
RUN /usr/local/fpclazarus/bin/add_new_fpc_version.sh 3.0.4 1.8.0

RUN /usr/local/fpclazarus/bin/update_trunk.sh
# Make last stable default:
RUN /usr/local/fpclazarus/bin/set_default.sh 3.0.4

CMD echo 'Started container with CGE Cloud Builds Tools.' && \
  echo 'Test FPC "default" version:' && \
  . /usr/local/fpclazarus/bin/setup.sh default && \
  echo 'Performing all the tests:' && \
  /usr/local/fpclazarus/bin/test_fpc_version.sh 3.0.2 1.6.4 && \
  /usr/local/fpclazarus/bin/test_fpc_version.sh 3.0.4 1.8.0
