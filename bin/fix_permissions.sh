#!/bin/bash
set -eu

chmod -R 'a+rX'     /etc/fpc.cfg* /usr/local/fpclazarus/
chown -R root:staff /etc/fpc.cfg* /usr/local/fpclazarus/
