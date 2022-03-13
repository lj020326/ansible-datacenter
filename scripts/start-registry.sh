#!/usr/bin/env bash

export REGISTRY_PROXY_REMOTEURL=https://registry-1.docker.io

echo "Starting registry..."
$(pwd)/venv/share/kolla/tools/start-registry

echo "Registry started!"
