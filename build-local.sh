#!/usr/bin/env bash
set -euo pipefail

# Run build.sh, setting Docker user/password from local config

export DOCKER_USER='kambi'
DOCKER_PASSWORD="$(cat docker_password.txt)"
export DOCKER_PASSWORD
export DOCKER_GITHUB_USER='michaliskambi'
DOCKER_GITHUB_TOKEN="$(cat github_token.txt)"
export DOCKER_GITHUB_TOKEN
./build.sh "$@"
