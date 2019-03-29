#!/bin/bash
set -eu

# Run build.sh, setting Docker user/password from local config

export docker_user=kambi
export docker_password=`cat docker_password.txt`
./build.sh "$@"
