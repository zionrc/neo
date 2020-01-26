#!/usr/bin/env bash

##
# neo
# ---
# by Francesco Bianco
# bianco@javanile.org
# MIT License
##

set -e

##
#
##
run_as_root() {
  local CMD="$*"

  if [[ $EUID -ne 0 ]]; then
    CMD="sudo $CMD"
  fi

  $CMD
}

##
#
##
main() {
  local neo_bin=/usr/local/bin/neo
  local neo_src=https://raw.githubusercontent.com/zionrc/neo/master/neo.sh

  echo -e "\e[43m\e[97m\e[1m INFO \e[0m Installing 'neo' as root..."
  run_as_root curl -sLo "${neo_bin}" "${neo_src}?ts=$(date +%s)"
  run_as_root chmod 755 "${neo_bin}"
  run_as_root chown 0:0 "${neo_bin}"
  echo -e "\e[42m\e[97m\e[1m DONE \e[0m Type 'neo --help' to begin."
}

##
#
##
main "$@"
