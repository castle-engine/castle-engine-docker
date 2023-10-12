#!/bin/bash
set -eux

# ---------------------------------------------------------------------
# Set up /etc/fpc.cfg to point to FPC installation in /usr/local/fpclazarus/ .
# Run this to allow FPC to find its units.
# ---------------------------------------------------------------------

# We want to maintain /etc/fpc.cfg manually.
rm -f /etc/fpc.cfg
ln -s /usr/local/fpclazarus/fpc.cfg /etc/fpc.cfg

echo '---------------------------------------------------------------------'
echo 'Using hardcoded /etc/fpc.cfg. Make sure it looks OK:'
cat /etc/fpc.cfg
echo 'End of /etc/fpc.cfg ---------------------------------------------'

# For now, just remove fppkg stuff.
mv -f /etc/fppkg* .
echo '/etc/fp* config files: -----------------------------------------------'
ls -Flah /etc/fp*
