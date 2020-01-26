#!/usr/bin/env bash

current=$(grep -e "^version=" neo.sh)
version=$(( $(echo ${current} | cut -s -d'=' -f2) + 1 ))

sed -i "s/${current}/version=${version}/" neo.sh

sha256sum neo.sh | cut -s -d' ' -f1 > neo.sig

git pull
git add .
git commit -am "Release (version=${version})"
git push

sleep 10

echo "Installing 'neo' as root..."
curl -sL https://raw.githubusercontent.com/zionrc/neo/master/setup.sh?ts=$(date +%s) | sudo bash -
