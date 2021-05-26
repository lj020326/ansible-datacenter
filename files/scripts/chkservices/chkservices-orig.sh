#!/bin/bash
# Script to check services and start when something stops
# hflautert@gmail.com

FILE_PID="/var/run/chkservices.pid"
CONFIG_FILE="/etc/chkservices/chkservices.conf"

# Load conf
. $CONFIG_FILE

# Log function
LOG()
{
        logger -t chkservices[$$] $1
}

# Try to recover - start services function
START_SERVICE() {
        local SERVICE=$1
        /etc/init.d/$SERVICE start > /dev/null 2>&1
        # Some services like httpd could return status error if test just after start
        # So lets sleep a little bit
        sleep 3
        /etc/init.d/$SERVICE status > /dev/null 2>&1
        if [ $? -eq 0 ]; then
                LOG "The service $SERVICE was started successfully."
                local MAIL_BODY="The service $SERVICE has stopped, and was started successfuly by chkservices. Take a look on $HOSTNAME logs, and try to figure out what happened."
                local SUBJECT="Service $SERVICE has restarted on $HOSTNAME"
                echo "$MAIL_BODY" | mail -r $MAIL_FROM -s "$SUBJECT" $MAIL_TO
        else
                LOG "The service $SERVICE is stopped and need mantaince to get start."
                local MAIL_BODY="The service $SERVICE is stopped and need mantaince to get start. Access $HOSTNAME and check it out!"
                local SUBJECT="Service $SERVICE is stopped on $HOSTNAME"
                echo "$MAIL_BODY" | mail -r $MAIL_FROM -s "$SUBJECT" $MAIL_TO
                #XXX - Develop kill -9, remove pid, something like a powerfull restart
        fi
}

CHECK_FOR_PID () {
    if [ -e "$FILE_PID" ]
    then
        LOG  "The Pid File $FILE_PID already exists! See how program was stopped, remove it and start again!"
        exit 1
    fi
}

TEST_SERVICE() {

for i in `echo $SERVICES`; do

# If service exists, get status
test -e /etc/init.d/$i > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
        /etc/init.d/$i status 1> /dev/null 2> /dev/null
        # If is not running, try to start
        if [ $? != 0 ]; then
                LOG "The service $i is stopped, chkservices is going to restart it."
                START_SERVICE $i
        fi
        else
                LOG "The declared service $i, was not found."
        fi
done

sleep $INTERVAL

}

## Main
#
START_CHKSERVICES () {
    LOG "Starting up chkservices."
    while true
    do
        TEST_SERVICE
    done
}

CHECK_FOR_PID
START_CHKSERVICES &
echo "$!" > "$FILE_PID"
#
##