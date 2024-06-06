#!/bin/bash
set -eu

# Run build.sh, setting Docker user/password from local config

export DOCKER_USER=kambi
export DOCKER_PASSWORD=`cat docker_password.txt`
export DOCKER_GITHUB_USER=michaliskambi
export DOCKER_GITHUB_TOKEN=`cat github_token.txt`
./build.sh "$@"
