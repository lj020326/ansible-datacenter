#!/usr/bin/env bash

## ref: http://archiva.apache.org/docs/2.2.5/userguide/deploy.html
#mvn deploy:deploy-file -Dfile=iDRACTools.9.4.0-3733.15734_amd64.tgz \
#		-DpomFile=iDRACTools.9.4.0-3733.15734_amd64.pom \
#		-DrepositoryId=archiva.snapshots \
#		-Durl=https://archiva.admin.dettonville.int:8443/repository/snapshots/

TARGET_ID=iDRACTools.9.4.0-3733-Debian.15734_amd64
TARGET_ARCHIVE=${TARGET_ID}.tgz
TARGET_POM=${TARGET_ID}.pom
TARGET_URL=https://archiva.admin.dettonville.int:8443/repository/snapshots/

## ref: http://archiva.apache.org/docs/2.2.5/userguide/deploy.html
mvn deploy:deploy-file -Dfile=${TARGET_ARCHIVE} \
  -DpomFile=${TARGET_POM} \
  -DrepositoryId=archiva.snapshots \
  -Durl=${TARGET_URL}
