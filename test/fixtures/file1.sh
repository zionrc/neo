#!/usr/bin/env bash

echo "Args: $@"

for var in "$@"; do
    echo "-> $var"
done
