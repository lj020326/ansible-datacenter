#!/usr/bin/env bash

##
## ref: https://www.osetc.com/en/how-to-run-cron-job-to-check-and-restart-service-if-dead-in-linux.html
##

#DEFAULT_PLIST="httpd mysqld"
DEFAULT_PLIST="smbd"

process_list=${DEFAULT_PLIST}
if [ $# == 1 ]; then
    process_list=$1
fi

for p in $process_list
do
#  echo "checking if process $p is running..."
  pgrep $p
  if [ $? -ne 0 ]
  then
    echo "process $p is NOT running -> restarting..."
    systemctl restart $p
  else
    echo "process $p is running, no restart required..."
  fi
done
