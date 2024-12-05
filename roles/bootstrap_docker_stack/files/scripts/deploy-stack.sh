#!/usr/bin/env bash

#docker network create --scope swarm net

## ref: https://stackoverflow.com/questions/48643466/docker-create-network-should-ignore-existing-network
docker network inspect traefik_public >/dev/null 2>&1 || \
    docker network create --scope swarm traefik_public

docker network inspect socket_proxy >/dev/null 2>&1 || \
    docker network create --scope swarm socket_proxy

## ref: https://github.com/moby/moby/issues/34153
#docker stack deploy --compose-file docker-compose.yml docker_stack --with-registry-auth
#docker stack deploy --compose-file docker-compose.yml docker_stack --with-registry-auth --resolve-image=always
docker stack deploy \
  --with-registry-auth \
  --resolve-image=always \
  --detach=true \
  --compose-file=docker-compose.yml \
  docker_stack
