#!/usr/bin/env bash

backupScript=/opt/scripts/job-backup-incremental.sh

backupLabel=monthly
#srcDir=/data/Records
srcDir=/srv/data1/data/Records
destDir=/srv/backups/records/${backupLabel}

# Run the backup
bash -x ${backupScript} ${backupLabel} ${srcDir} ${destDir}

exit ${?}
