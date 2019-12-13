#!/bin/bash
set -e

##
# neo
# ---
# by Francesco Bianco
# bianco@javanile.org
# MIT License
##

neo_bin=/usr/local/bin/neo
neo_src=https://neorx.github.io/neo/neo.sh

echo "Get: ${neo_src} -> ${neo_bin}"
curl --progress-bar -so "${neo_bin}" "${neo_src}"

echo "Inf: apply executable permission to ${neo_bin}"
chmod +x ${neo_bin}

echo "Done."
