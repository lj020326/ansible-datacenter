#!/usr/bin/env bash

DOCKER_CONTAINER_DIR=/home/container-user/docker
EMBOLD_BASE_DIR=${DOCKER_CONTAINER_DIR}/embold
EMBOLD_VERSION=1.9.13.1
EMBOLD_HTTP_PORT="3010"

mkdir -p ${EMBOLD_BASE_DIR}

docker run -m 10GB -d -p ${EMBOLD_HTTP_PORT}:3000 \
   --name EMBOLD_TEST \
   -e gamma_ui_public_host=http://localhost:3000 \
   -e RISK_XMX=-Xmx1024m \
   -e ANALYSER_XMX=-Xmx6072m \
   -e ACCEPT_EULA=Y \
   -v ${EMBOLD_BASE_DIR}/gamma_data:/opt/gamma_data \
   -v ${EMBOLD_BASE_DIR}/gamma_psql_data:/var/lib/postgresql \
   -v ${EMBOLD_BASE_DIR}/logs:/opt/gamma/logs \
   alsac-ose-images-rw.lb.alsac.stjude.org:443/embold:$EMBOLD_VERSION
#   embold/gamma:$EMBOLD_VERSION
