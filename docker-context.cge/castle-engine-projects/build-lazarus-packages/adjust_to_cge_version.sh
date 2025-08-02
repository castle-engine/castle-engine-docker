#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# ----------------------------------------------------------------------
# Replace package names to reflect old version of CGE, see
# https://castle-engine.io/wp/2025/08/02/lazarus-packages-moved-renamed/
# ----------------------------------------------------------------------

do_replace ()
{
  local OLD="$1"
  local NEW="$2"
  shift 2

  echo "Replacing ${OLD} -> ${NEW}"

  sed -i "s/${OLD}/${NEW}/g" build_lazarus_packages.lpi
  sed -i "s/${OLD}/${NEW}/g" build_lazarus_packages.lpr
}

if [ `castle-engine --version` '!=' 'castle-engine 7.0-alpha.3' ]; then
  echo 'Not cge-stable, so not doing anything from adjust_to_cge_version.sh (as the example is already good for cge-unstable).'
  exit 0
fi

do_replace castle_engine_base castle_base
do_replace castle_engine_window castle_window
do_replace castle_engine_lcl castle_components
