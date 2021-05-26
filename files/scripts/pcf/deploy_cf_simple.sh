#!/usr/bin/env bash

APP_NAME=map-build-$BUILD_VERSION
HOST_NAME=$APP_NAME-dev
# assuming only 1 previous build.
DEPLOYED_APP_NAME=$(cf apps | grep 'map-build-' | cut -d" " -f1)
if [ -n "$DEPLOYED_APP_NAME" ]; then
  cf unmap-route $DEPLOYED_APP_NAME $DOMAIN -n map-dev
  cf delete $DEPLOYED_APP_NAME -f
fi
cf push $APP_NAME -p artifacts/pcfdemo.war -m 1GB -n $HOST_NAME -i 1 -t 180 --no-start
cf bind-service $APP_NAME myRabbit
cf map-route $APP_NAME $DOMAIN -n map-dev
cf start $APP_NAME
cf lo
