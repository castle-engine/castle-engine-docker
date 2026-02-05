#!/usr/bin/env bash
set -euo pipefail

# Change the "default" FPC version meaning to $1.
# Call from any directory, `pwd` doesn't matter.

cd /usr/local/fpclazarus/
rm -f default
ln -s "$1" default
echo 'Default FPC/Lazarus is now' "$1"
ls -Flah .
