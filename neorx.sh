#!/bin/bash
export neorx_label=neo

##
# neo(rx) file
##

case "${neorx_command}" in
  setup) curl -s https://git.io/neorx | bash - ;;
  push)  git add .; git commit -am "push"; git push ;;
  *)     echo "Undefined command, use: push, setup." ;;
esac
