#!/bin/bash
export neorx_label=neo

##
# neo(rx) bash file
##

set -e

case "${neorx_command}" in
  upgrade|update|setup)
    curl -s https://neorx.github.io/neo/setup.sh?ts=$(date +%s) | bash -
    ;;
  help|*)
    echo "Undefined command, use: push, setup."
    ;;
esac
