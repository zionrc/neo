#!/bin/bash

current=$(grep -e "^version=" neo.sh)
version=$(( $(echo ${current} | cut -s -d'=' -f2) + 1 ))

echo ${current} ${version}

sed -i "s/${current}/version=${version}/" neo.sh

sha256sum neo.sh | cut -s -d' ' -f1 > neo.sig

git add .
git commit -am "Release (version=${version})"
git push

sleep 5

curl -s https://raw.githubusercontent.com/zionrc/neo/master/setup.sh | sudo bash -
