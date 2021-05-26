#!/usr/bin/env bash

## This script is used to test the BASH script commands
## of a Jenkins Job using the Cloud Foundry CLI.

## Parameters used to test the BASH script
## They will be provided by Jenkins plugins,
## Jenkins environment variables or job parameters
CF_USER=$1
CF_PASSWORD=$2
CF_ORG=$3
CF_SPACE=$4
API=$5
DOMAIN=$6
BUILD_VERSION=$7

## Variables used during Jenkins Build Process
APP_NAME=map-build-$BUILD_VERSION
HOST_NAME=$APP_NAME-dev

## Log into PCF endpoint - Provided via Jenkins Plugin
cf login -u $CF_USER -p $CF_PASSWORD -o $CF_ORG -s $CF_SPACE -a $API --skip-ssl-validation

# ^^^^^^^^^^^^^^^^^^^^ Commands for Jenkins Script ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

## These steps complete the following, they are the only required steps for the Jenkins Job
##
##   1. Determine the name of the deployed app. The naming convention for this
##      app is map-build-BUILD_NUMBER, ex map-build-45. We assume only 1 previous build
##      exist but this script can be modified to support multiple previous builds.
##
##   2. If an app is found by querying the list of deployed apps then unmap a
##      convenient url, ex map-dev.cfapps.io, and delete the existing app. In this
##      situation we are ok with downtime as we deploy the new app in development.
##
##   Note: route name must be unique in a foundation. If you use Pivotal Web Services
##         you need to make sure your convenient URL is unique.
##
##   3. Push the next released version, bind an existing Rabbit service to the app, map
##      the convenient URL to the new instance and start the app.
##
##   4. Log out
##

DEPLOYED_APP_NAME=$(cf apps | grep 'map-build-' | cut -d" " -f1)
if [ -n "$DEPLOYED_APP_NAME" ]; then
 cf unmap-route $DEPLOYED_APP_NAME $DOMAIN -n map-dev
 cf delete $DEPLOYED_APP_NAME -r -f
fi
cf push $APP_NAME -p artifacts/pcfdemo.war -m 1GB -n $HOST_NAME -i 1 -t 180 --no-start
cf bind-service $APP_NAME myRabbit
cf map-route $APP_NAME $DOMAIN -n map-dev
cf start $APP_NAME
cf lo
