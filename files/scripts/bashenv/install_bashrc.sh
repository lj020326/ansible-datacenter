#!/usr/bin/env bash


DATE=`date +%Y%m%d%H%M%S`

echo "**********************************"
echo "*** installing bashrc         ****"
echo "**********************************"

DEST_DIR="${HOME}"

#INITIAL_WD=`pwd`
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
echo "SCRIPT_DIR=[${SCRIPT_DIR}]"

SRC_DIR="${SCRIPT_DIR}"

echo "SRC_DIR=[${SRC_DIR}]"
echo "DEST_DIR=[${DEST_DIR}]"

FROM="${SRC_DIR}/.bash*"
TO="${DEST_DIR}/"
BACKUP="${DEST_DIR}/.bash-backups"
#BACKUP="backups"

if [ ! -d $SRC_DIR ]; then
    echo "SRC_DIR not found at ${SRC_DIR}, exiting..."
    exit 1
fi

## rsync can backup and sync
## ref: https://www.digitalocean.com/community/tutorials/how-to-use-rsync-to-sync-local-and-remote-directories-on-a-vps

OPTIONS=(
    -arv
    --update
    --backup
    --backup-dir=$BACKUP
)

#OPTIONS=(
#    -arv
#    --update
#)

#echo "rsync ${OPTIONS[@]} $FROM $TO"
echo "rsync ${OPTIONS[@]} $FROM $TO"

rsync ${OPTIONS[@]} ${FROM} ${TO}

