#!/usr/bin/env bash


DATE=`date +%Y%m%d%H%M%S`

echo "**********************************"
echo "*** installing bashrc         ****"
echo "**********************************"

DEST_DIR="${HOME}"
DEST_DIR2="./roles/bootstrap-user/files/bashenv"

#INITIAL_WD=`pwd`
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
echo "SCRIPT_DIR=[${SCRIPT_DIR}]"

SRC_DIR="${SCRIPT_DIR}"
SECRETS_DIR="$( cd "$SRC_DIR/../../private/env/" && pwd )"
export ANSIBLE_VAULT_PASSWORD_FILE=$HOME/.vault_pass

echo "SRC_DIR=[${SRC_DIR}]"
echo "DEST_DIR=[${DEST_DIR}]"
echo "SECRETS_DIR=[${SECRETS_DIR}]"

#FROM="${SRC_DIR}/.bash* ${SECRETS_DIR}/.bash*"
FROM="${SRC_DIR}/.bash*"
TO="${DEST_DIR}/"
BACKUP="${DEST_DIR}/.bash-backups"
BACKUP2="${DEST_DIR}/save"
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

OPTIONS2=(
    -arv
    --update
    --backup
    --backup-dir=$BACKUP2
)

#OPTIONS=(
#    -arv
#    --update
#)

echo "rsync ${OPTIONS[@]} ${FROM} ${DEST_DIR}/"
rsync ${OPTIONS[@]} ${FROM} ${DEST_DIR}/

echo "rsync ${OPTIONS2[@]} ${FROM} ${DEST_DIR2}/"
rsync ${OPTIONS2[@]} ${FROM} ${DEST_DIR2}/

if [ "${SECRETS_DIR}/.bash_secrets" -nt "${TO}/.bash_secrets" ]; then
  echo "deploying secrets ${SECRETS_DIR}/.bash_secrets"
  ## Do not need to specify password file since defined in ansible.cfg
  ansible-vault decrypt ${SECRETS_DIR}/.bash_secrets --output ${TO}/.bash_secrets --vault-password-file ~/.vault_pass
#  ansible-vault decrypt ${SECRETS_DIR}/.bash_secrets --output ${TO}/.bash_secrets
  chmod 600 ~/.bash_secrets
fi
