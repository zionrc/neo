#!/bin/bash

##
# neo
# ---
# by Francesco Bianco
# bianco@javanile.org
# MIT License
##

set -e

export neorx_registry=https://neorx.github.io/registry/labels

if [[ -z "$1" ]]; then
    echo ">>> Command required."
    exit 1
fi

if [[ -z "$2" ]]; then
    echo ">>> Label required."
    exit 1
fi

if [[ ${#2} -le 1 ]]; then
    echo ">>> Label too short."
    exit 1
fi

registry="${neorx_registry}/${2:0:1}/${2:1:1}?ts=$(date +%s)"
callable=$(curl -s "${registry}" | grep -m1 "^$2 *" | cut -s -d' ' -f2)

if [[ -z "${callable}" ]]; then
    echo ">>> Label '$2' not in registry."
    exit 1
fi

echo ">>> Callable: https://${callable}.sh"

runnable=$(curl -s "https://${callable}.sh?ts=$(date +%s)")

#echo "${runnable}" | head -n2 | bash -
#echo "${neorx_label}"
#if [[ "${neorx_label}" != "$2" ]]; then
#    echo "Invalid file format."
#    exit 1
#fi

export neorx_command=$1
if [[ "${neorx_mode}" == "print" ]]; then
  echo "${runnable}"
elif [[ "${neorx_mode}" == "debug" ]]; then
  echo "${runnable}" | bash -x -
else
  echo "${runnable}" | bash -
fi
