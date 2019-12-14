#!/bin/bash
export neorx_label=neo

##
# neo
# ---
# by Francesco Bianco
# bianco@javanile.org
# MIT License
##

set -e

case "${neorx_command}" in
  upgrade|update|setup)
    curl -s "https://neorx.github.io/neo/setup.sh?ts=$(date +%s)" | bash -
    ;;
  help|*)
    echo "Undefined command, use: push, setup."
    ;;
esac
