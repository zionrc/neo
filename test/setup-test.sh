#!/usr/bin/env bash
set -e

rm -f /usr/local/bin/neo

./setup.sh

if [[ ! -f /usr/local/bin/neo ]]; then
    echo "Setup fail."
fi
