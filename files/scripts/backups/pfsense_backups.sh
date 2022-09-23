#!/usr/bin/env bash

#set -e
#set -x

## ref: https://github.com/pfsense/docs/blob/master/source/backup/remote-config-backup.rst

HOST=$1
#USER=$2
#PASS=$3
DESTPATH=${2:-/var/fwbackups}
CFGPATH=${3:-~/.fwbackup.cfg}

MAILTO=admin@dettonville.org
TIMESTAMP=`date +%Y%m%d%H%M%S`

logName="fwbackup_$(date -Id)_$(date +%H-%M-%S).log"
ownFolderName=".fwbackup"
logFolderName="log"

# Combinate previously defined variables for use (don't touch this)
ownFolderPath="${HOME}/${ownFolderName}"
tempLogPath="${ownFolderPath}/logs"
logFile="${tempLogPath}/${logName}"

# Prepare own folder
mkdir -p "${tempLogPath}"
touch "${logFile}"

writeToLog() {
	echo -e "${1}" | tee -a "${logFile}"
}

writeToLog "********************************"
writeToLog "*                              *"
writeToLog "*   PFSense fwbackup           *"
writeToLog "*                              *"
writeToLog "********************************"

if [ ! -e $CFGPATH ]; then
    writeToLog "Config file ${CFGPATH} not found, quitting now!"
    exit 1
fi

writeToLog "Reading config ${CFGPATH} ...."
source ${CFGPATH}
writeToLog "Config for the user: $USER"

([ -z "$HOST" ] || [ -z "$USER" ] || [ -z "$PASS" ]) && writeToLog "all 3 arguments must be defined in config: PFSENSE_HOST USERNAME PASSWORD " && exit 1;

if [ ! -d $DESTPATH ]; then
  mkdir -p $DESTPATH
fi

BACKUPFILE=$DESTPATH/config-router-$TIMESTAMP.xml;

writeToLog 'Connecting to '$HOST

#Get the initial CSRF Magic Token
#csrf=$(curl -s -S --insecure --cookie-jar cookies/${HOST}cookie.txt https://${HOST}/diag_backup.php | grep "name='__csrf_magic'" | sed 's/.*value="\(.*\)".*/\1/')

csrf=$(wget -qO- --keep-session-cookies --save-cookies cookies.txt \
  --no-check-certificate https://${HOST}/diag_backup.php \
  | grep "name='__csrf_magic'" | sed 's/.*value="\(.*\)".*/\1/')

csrf2=$(wget -qO- --keep-session-cookies --load-cookies cookies.txt \
  --save-cookies cookies.txt --no-check-certificate \
  --post-data "login=Login&usernamefld=$USER&passwordfld=$PASS&__csrf_magic=${csrf}" \
  https://${HOST}/diag_backup.php  | grep "name='__csrf_magic'" \
  | sed 's/.*value="\(.*\)".*/\1/;q')
#  | sed 's/.*value="\(.*\)".*/\1/')

#writeToLog "csrf=${csrf}"
#writeToLog "csrf2=${csrf2}"

wget --keep-session-cookies --load-cookies cookies.txt --no-check-certificate \
  --post-data "download=download&donotbackuprrd=yes&__csrf_magic=${csrf2}" \
  https://${HOST}/diag_backup.php -O $BACKUPFILE

writeToLog  "\n[$(date -Is)] Checking Results"

# check if credentials are valid
if grep -qi 'username or password' $BACKUPFILE; then
        writeToLog ; writeToLog "   !!! AUTHENTICATION ERROR (${HOST}): PLEASE CHECK LOGIN AND PASSWORD"; writeToLog
#        rm -f $BACKUPFILE
        exit 1
fi

grep --silent '^<?xml ' $BACKUPFILE || writeToLog "Downloaded file is not XML; is probably broken."
# xml file contains doctype when the URL is wrong
if grep -qi 'doctype html' $BACKUPFILE; then
	writeToLog ; writeToLog "   !!! URL ERROR (${HOST}): HTTP OR HTTPS ?"; writeToLog
#	rm -f $BACKUPFILE
	exit 1
fi

if [ -e $BACKUPFILE ]; then
	writeToLog "\n[$(date -Is)] FW Backup completed successfully\n"

	# Clear unneeded partials and lock file
	fwbackupFail=0
	cat "${logFile}" | mail -s "fwbackup: SUCCESS Backup for ${HOST}" -r admin@dettonville.org $MAILTO
    #sendemail -u "Firewall Backup Successful for $1" -f admin@dettonville.org -t $MAILTO -m "Success - pfSense backup - $1"
else
	writeToLog "\n[$(date -Is)] FW Backup failed, try again later\n"
	fwbackupFail=1
	cat "${logFile}" | mail -s "fwbackup: FAILED for ${HOST}" -r admin@dettonville.org $MAILTO
    #sendemail -u "Firewall Backup Failed for $1" -f admin@dettonville.org -t $MAILTO -m "Failure - pfSense backup - $1"
fi

exit "${fwbackupFail}"
