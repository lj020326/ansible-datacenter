#!/usr/bin/env bash


DATE=`date +%Y%m%d%H%M%S`

echo "**********************************"
echo "*** installing cert"
echo "**********************************"

#CERT_DEST_DIR="~/.ssh"
#CERT_DEST_DIR="/home/administrator/.ssh"
CERT_DEST_DIR="${HOME}/.ssh"

#INITIAL_WD=`pwd`
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
echo "SCRIPT_DIR=[${SCRIPT_DIR}]"

CERT_SRC_DIR="${SCRIPT_DIR}/../certs/.ssh"

echo "CERT_SRC_DIR=[${CERT_SRC_DIR}]"
echo "CERT_DEST_DIR=[${CERT_DEST_DIR}]"

FROM="${CERT_SRC_DIR}/"
TO="${CERT_DEST_DIR}/"
BACKUP="${CERT_DEST_DIR}/backups"
#BACKUP="backups"

if [ ! -d $CERT_SRC_DIR ]; then
    echo "CERT_SRC_DIR not found at ${CERT_SRC_DIR}, exiting..."
    exit 1
fi

## rsync can backup and sync
## ref: https://www.digitalocean.com/community/tutorials/how-to-use-rsync-to-sync-local-and-remote-directories-on-a-vps

# OPTIONS=(
#     -arv
#     --update
#     --backup
#     --backup-dir=$BACKUP
# )

OPTIONS=(
    -arv
    --update
)

#echo "rsync ${OPTIONS[@]} $FROM $TO"
echo "rsync ${OPTIONS[@]} $FROM $TO"

rsync ${OPTIONS[@]} ${FROM} ${TO}

chmod 600 ${CERT_DEST_DIR}/id_rsa

