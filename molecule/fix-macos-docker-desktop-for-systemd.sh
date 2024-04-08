#!/usr/bin/env bash

## ref: https://github.com/docker/for-mac/issues/6073

echo "Stop running Docker"
test -z "$(docker ps -q 2>/dev/null)" && osascript -e 'quit app "Docker"'

#echo "Install jq and moreutils so we can merge into the existing json file"
#brew install jq moreutils

echo "Add the needed cgroup config to docker settings.json"

echo '{"deprecatedCgroupv1": true}' | \
  jq -s '.[0] * .[1]' ~/Library/Group\ Containers/group.com.docker/settings.json - | \
  sponge ~/Library/Group\ Containers/group.com.docker/settings.json

echo "Restart docker desktop"
open --background -a Docker

