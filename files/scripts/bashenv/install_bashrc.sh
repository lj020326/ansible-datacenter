#!/usr/bin/env bash

DATE=`date +%Y%m%d%H%M%S`

echo "**********************************"
echo "*** installing bashrc         ****"
echo "**********************************"

#INITIAL_WD=`pwd`
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

## expect to be run from any non-project location/directory
PROJECT_DIR="$( cd "$SCRIPT_DIR/" && git rev-parse --show-toplevel )"

BASHENV_DIR="${SCRIPT_DIR}/bashenv"

SECRETS_DIR="${PROJECT_DIR}/files/private/env"
BASHENV_SECRETS_DIR="${PROJECT_DIR}/files/private/vault/bashenv"
export ANSIBLE_VAULT_PASSWORD_FILE=$HOME/.vault_pass

BACKUP_HOME_DIR="${HOME}/.bash-backups"
BACKUP_REPO_DIR1="${REPO_DIR1}/save"

echo "SCRIPT_DIR=${SCRIPT_DIR}"
echo "BASHENV_DIR=${BASHENV_DIR}"
echo "HOME=${HOME}"
echo "PROJECT_DIR=${PROJECT_DIR}"
echo "SECRETS_DIR=${SECRETS_DIR}"

UPDATE_REPO_CMD="cd ${PROJECT_DIR} && git pull origin main"
eval "${UPDATE_REPO_CMD}"

## rsync can backup and sync
## ref: https://www.digitalocean.com/community/tutorials/how-to-use-rsync-to-sync-local-and-remote-directories-on-a-vps

## REF: http://stackoverflow.com/questions/4585929/how-to-use-cp-command-to-exclude-a-specific-directory
EXCLUDES="--exclude=.idea"
EXCLUDES+=" --exclude=.git"
EXCLUDES+=" --exclude=venv"
EXCLUDES+=" --exclude=save"

RSYNC_OPTIONS_HOME=(
    -arv
    --update
    ${EXCLUDES}
    --backup
    --backup-dir=$BACKUP_HOME_DIR
)

RSYNC_OPTIONS_REPO1=(
    -arv
    --update
    ${EXCLUDES}
    --backup
    --backup-dir=$BACKUP_REPO_DIR1
)

echo "rsync ${RSYNC_OPTIONS_HOME[@]} ${BASHENV_DIR}/ ${HOME}/"
rsync "${RSYNC_OPTIONS_HOME[@]}" "${BASHENV_DIR}/" "${HOME}/"

#chmod +x ${SECRETS_DIR}/scripts/*.sh
#chmod +x ${SECRETS_DIR}/git/*.sh

echo "rsync env scripts"
rsync "${RSYNC_OPTIONS_HOME[@]}" "${SECRETS_DIR}/scripts/*.sh" "${HOME}/bin/"
rsync "${RSYNC_OPTIONS_HOME[@]}" "${SECRETS_DIR}/git/*.sh" "${HOME}/bin/"
rsync "${RSYNC_OPTIONS_HOME[@]}" "${SCRIPT_DIR}/ansible/*.sh" "${HOME}/bin/"
rsync "${RSYNC_OPTIONS_HOME[@]}" "${SCRIPT_DIR}/certs/*.sh" "${HOME}/bin/"
rsync "${RSYNC_OPTIONS_HOME[@]}" "${SCRIPT_DIR}/pfsense/*.sh" "${HOME}/bin/"
rsync "${RSYNC_OPTIONS_HOME[@]}" "${SCRIPT_DIR}/pfsense/*.py" "${HOME}/bin/"
chmod +x "${HOME}/bin/*.sh"
chmod +x "${HOME}/bin/*.py"

echo "deploying secrets ${BASHENV_SECRETS_DIR}/.bash_secrets"
rsync -arv --update "${BASHENV_SECRETS_DIR}/.bash_secrets" "${HOME}/"
chmod 600 "${HOME}/.bash_secrets"
