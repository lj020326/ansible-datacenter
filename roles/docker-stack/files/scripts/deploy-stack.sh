#!/usr/bin/env bash

## ref: https://github.com/moby/moby/issues/34153
#docker stack deploy --compose-file docker-compose.yml docker_stack --with-registry-auth
docker stack deploy --compose-file docker-compose.yml docker_stack --with-registry-auth --resolve-image=always
