#!/bin/bash
set -e

if [[ -z "$1" ]]; then
    echo ">>> Command required."
    exit 1
fi

if [[ -z "$2" ]]; then
    echo ">>> Label required."
    exit 1
fi

registry=https://neorx.github.io/registry/labels/${2:0:1}/${2:1:1}
callable=$(curl -s ${registry} | grep -m1 "$2" | cut -s -d' ' -f2)

if [[ -z "${callable}" ]]; then
    echo ">>> Label '$2' not in registry."
    exit 1
fi

echo ">>> Callable: https://${callable}.sh"

runnable=$(curl -s https://${callable}.sh)
#echo "${runnable}" | head -n2 | bash -
#echo "${neorx_label}"
#if [[ "${neorx_label}" != "$2" ]]; then
#    echo "Invalid file format."
#    exit 1
#fi

export neorx_command=$1
echo "${runnable}" | bash -
