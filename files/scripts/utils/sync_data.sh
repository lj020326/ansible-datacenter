#!/usr/bin/env bash

FROM=/data
#TO=/srv/iscsi-eqds1/
TO=/srv/iscsi-eqds1/

DATE=`date +%Y%m%d%H%M%S`

echo "**********************************"
echo "*** Syncing from $FROM to $TO"
echo "*** sync date=$DATE"
echo "**********************************"

## this is a good way to avoid running if the job is already running
## ref: http://bencane.com/2015/09/22/preventing-duplicate-cron-job-executions/
##
#PIDFILE=/home/administrator/jobs/sync_data.pid
PIDFILE=/var/run/backups/sync_data.pid
if [ -f $PIDFILE ]
then
  PID=$(cat $PIDFILE)
  ps -p $PID > /dev/null 2>&1
  if [ $? -eq 0 ]
  then
    echo "Job with PID [$PID] is already running"
    exit 1
  else
    ## Process not found assume not running
    echo $$ > $PIDFILE
    if [ $? -ne 0 ]
    then
      echo "Could not create PID file"
      exit 1
    fi
  fi
else
  echo $$ > $PIDFILE
  if [ $? -ne 0 ]
  then
    echo "Could not create PID file"
    exit 1
  fi
  echo "PID file [$PIDFILE] created"
fi

## REF: http://stackoverflow.com/questions/4585929/how-to-use-cp-command-to-exclude-a-specific-directory
EXCLUDES="--exclude=node_modules"
EXCLUDES+=" --exclude=venv"

OPTIONS="--progress"

## for rsync args
## ref: https://www.computerhope.com/unix/rsync.htm
rsync -xarzh --partial --update --delete --stats ${OPTIONS} ${EXCLUDES} ${FROM} ${TO}

rm $PIDFILE
