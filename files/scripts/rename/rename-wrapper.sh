#!/bin/bash

## script below depends on having gnu command line utils
## if on macOS - follow the dirs at the link below to install gnu tools
## ref: https://www.topbug.net/blog/2013/04/14/install-and-use-gnu-command-line-tools-in-mac-os-x/

set -e

#DATE=`date +%Y%m%d`
DATE=`date +%Y%m%d%H%M%S`
echo "date=$DATE"

IGNORE_DIRS=admin,configs,save,volumes,data
IGNORE_DIRS_FIND='-not -path "*/admin/*" -not -path "*/configs/*"'

GREP_EXCLUDES="--exclude=\"*.save.*\" --exclude=\"\*.{png,jpg,gz,zip}\" --exclude-dir={node_modules,$IGNORE_DIRS,venv,.idea,.git}"

echo "sourcing util functions"
. ../utils.sh

echo "****cleanup project"
cleanup_project
ret_val=$?
echo "ret_val=$ret_val"

FROM="dcapi_monitoring_service_tomcat_cookbook"
TO="monitoring_service_tomcat_cookbook"
echo "****replacing ${FROM} to ${TO}"
replace_pattern "${FROM}" "${TO}" true
ret_val=$?
echo "ret_val=$ret_val"

