#!/usr/bin/env bash

docker stack deploy --compose-file docker-compose.yml docker_stack --with-registry-auth
