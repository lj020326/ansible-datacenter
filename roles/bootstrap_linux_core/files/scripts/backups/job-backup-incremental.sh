#!/usr/bin/env bash

backupScript=/opt/scripts/rsync-incremental-backup-local

#srcDir=/data/Records
backupLabel=${1:-daily}
srcDir=${2:-/srv/data1/data/Records}
destDir=${3:-/srv/backups/records/${backupLabel}}
cfgPath=${4-~/.backups.cfg}

backupLabelMsg=${backupLabel^^}

if [ ! -e $cfgPath ]; then
    writeToLog "Config file ${cfgPath} not found, quitting now!"
    exit 1
fi

writeToLog "Reading configs from ${cfgPath} ...."
source ${cfgPath}

echo "emailFrom=${emailFrom}"
echo "emailTo=${emailTo}"
echo "logDir=${logDir}"

logFile=${logDir}/run-${backupLabel}-backup.log

echo "truncating log file ${logFile}"
mkdir -p ${logDir}
touch ${logFile}
cat /dev/null > ${logFile}

# Run the backup
${backupScript} "${srcDir}" "${destDir}" 2>&1 | tee -a ${logFile}
#${backupScript} ${backupLabel} ${srcDir} ${destDir} 2>&1 | tee -a ${logFile}

backupStatus=${?}

backupStatusMsg=""

# Check backup job success
if [ "${backupStatus}" -eq "0" ]
then
        echo "\n[$(date -Is)] Backup completed successfully\n"
        # Clear unneeded partials and lock file
        backupStatusMsg=SUCCESS
else
        echo "\n[$(date -Is)] Backup failed, try again later\n"
        backupStatusMsg=FAILED
fi

cat "${logFile}" | mail -s "[$backupStatusMsg] ${backupLabelMsg} rsync backup : ${srcDir}->${destDir}" -r ${emailFrom} ${emailTo}

exit ${backupStatus}
