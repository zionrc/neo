#!/bin/bash
export neorx_label=neo

##
# neo(rx) bash file
##

set -e

case "${neorx_command}" in
  setup)
    curl -s https://neorx.github.io/neo/setup.sh?ts=$(date +%s) | bash -
    ;;
  push)
    git add .; git commit -am "push"; git push
    ;;
  help|*)
    echo "Undefined command, use: push, setup."
    ;;
esac
