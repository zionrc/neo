#!make

.PHONY: sha256sums

sha256sums:
	find * -type f -exec sha256sum "{}" + > SHA256SUMS

bump-version:
	echo "Bump version"
	#current=$(grep -e "^version=" neo.sh)
	#version=$(( $(echo ${current} | cut -s -d'=' -f2) + 1 ))
	#sed -i "s/${current}/version=${version}/" neo.sh

push: sha256sums
	git pull
	git add .
	git commit -am "Release (version=${version})"
	git push

release-and-install: bump-version push
	echo "Installing 'neo' as root..."
	sleep 10
	curl -sL https://raw.githubusercontent.com/zionrc/neo/master/setup.sh?ts=$(date +%s) | sudo bash -
