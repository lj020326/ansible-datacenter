#!/usr/bin/env bash

BACKUP_SCRIPT=/opt/scripts/rsync-incremental-backup-local

BACKUP_LABEL=${1:-daily}
#SOURCE_DIR=/data/Records
SOURCE_DIR=${2:-/srv/data1/data/Records}
DEST_DIR=${3:-/srv/backups/records/${BACKUP_LABEL}}
CONFIG_FILEPATH=${4:-"${HOME}/.backups.cfg"}

## These defaults may be overridden by the file sourced from CONFIG_FILEPATH
EMAIL_FROM="${5:-backups@example.int}"
EMAIL_TO="${6:-admin@example.int}"
LOG_DIR="${7:-/var/log/backups}"

BACKUP_LABEL_MSG=${BACKUP_LABEL^^}

#### LOGGING RELATED
LOG_ERROR=0
LOG_WARN=1
LOG_INFO=2
LOG_TRACE=3
LOG_DEBUG=4

declare -A LOGLEVEL_TO_STR
LOGLEVEL_TO_STR["${LOG_ERROR}"]="ERROR"
LOGLEVEL_TO_STR["${LOG_WARN}"]="WARN"
LOGLEVEL_TO_STR["${LOG_INFO}"]="INFO"
LOGLEVEL_TO_STR["${LOG_TRACE}"]="TRACE"
LOGLEVEL_TO_STR["${LOG_DEBUG}"]="DEBUG"

function reverse_array() {
  local -n ARRAY_SOURCE_REF=$1
  local -n REVERSED_ARRAY_REF=$2
  # Iterate over the keys of the LOGLEVEL_TO_STR array
  for KEY in "${!ARRAY_SOURCE_REF[@]}"; do
    # Get the value associated with the current key
    VALUE="${ARRAY_SOURCE_REF[$KEY]}"
    # Add the reversed key-value pair to the REVERSED_ARRAY_REF array
    REVERSED_ARRAY_REF[$VALUE]="$KEY"
  done
}

declare -A LOGLEVELSTR_TO_LEVEL
reverse_array LOGLEVEL_TO_STR LOGLEVELSTR_TO_LEVEL

#LOG_LEVEL=${LOG_DEBUG}
LOG_LEVEL=${LOG_INFO}

function logError() {
  if [ $LOG_LEVEL -ge $LOG_ERROR ]; then
  	logMessage "${LOG_ERROR}" "${1}"
  fi
}
function logWarn() {
  if [ $LOG_LEVEL -ge $LOG_WARN ]; then
  	logMessage "${LOG_WARN}" "${1}"
  fi
}
function logInfo() {
  if [ $LOG_LEVEL -ge $LOG_INFO ]; then
  	logMessage "${LOG_INFO}" "${1}"
  fi
}
function logTrace() {
  if [ $LOG_LEVEL -ge $LOG_TRACE ]; then
  	logMessage "${LOG_TRACE}" "${1}"
  fi
}
function logDebug() {
  if [ $LOG_LEVEL -ge $LOG_DEBUG ]; then
  	logMessage "${LOG_DEBUG}" "${1}"
  fi
}
function abort() {
  logError "$@"
  exit 1
}
function fail() {
  logError "$@"
  exit 1
}

function logMessage() {
  local LOG_MESSAGE_LEVEL="${1}"
  local LOG_MESSAGE="${2}"
  ## remove first item from FUNCNAME array
#  local CALLING_FUNCTION_ARRAY=("${FUNCNAME[@]:2}")
  ## Get the length of the array
  local CALLING_FUNCTION_ARRAY_LENGTH=${#FUNCNAME[@]}
  local CALLING_FUNCTION_ARRAY=("${FUNCNAME[@]:2:$((CALLING_FUNCTION_ARRAY_LENGTH - 3))}")
#  echo "CALLING_FUNCTION_ARRAY[@]=${CALLING_FUNCTION_ARRAY[@]}"

  local CALL_ARRAY_LENGTH=${#CALLING_FUNCTION_ARRAY[@]}
  local REVERSED_CALL_ARRAY=()
  for (( i = CALL_ARRAY_LENGTH - 1; i >= 0; i-- )); do
    REVERSED_CALL_ARRAY+=( "${CALLING_FUNCTION_ARRAY[i]}" )
  done
#  echo "REVERSED_CALL_ARRAY[@]=${REVERSED_CALL_ARRAY[@]}"

#  local CALLING_FUNCTION_STR="${CALLING_FUNCTION_ARRAY[*]}"
  ## ref: https://stackoverflow.com/questions/1527049/how-can-i-join-elements-of-a-bash-array-into-a-delimited-string#17841619
  local SEPARATOR=":"
  local CALLING_FUNCTION_STR
  CALLING_FUNCTION_STR=$(printf "${SEPARATOR}%s" "${REVERSED_CALL_ARRAY[@]}")
  CALLING_FUNCTION_STR=${CALLING_FUNCTION_STR:${#SEPARATOR}}

  ## ref: https://stackoverflow.com/a/13221491
  if [ "${LOGLEVEL_TO_STR[${LOG_MESSAGE_LEVEL}]+abc}" ]; then
    LOG_LEVEL_STR="${LOGLEVEL_TO_STR[${LOG_MESSAGE_LEVEL}]}"
  else
    abort "Unknown log level of [${LOG_MESSAGE_LEVEL}]"
  fi

  local LOG_LEVEL_PADDING_LENGTH=5

  local PADDED_LOG_LEVEL
  PADDED_LOG_LEVEL=$(printf "%-${LOG_LEVEL_PADDING_LENGTH}s" "${LOG_LEVEL_STR}")

  local LOG_PREFIX="${CALLING_FUNCTION_STR}():"
  echo -e "[${PADDED_LOG_LEVEL}]: ==> ${LOG_PREFIX} ${LOG_MESSAGE}"
}

function setLogLevel() {
  LOG_LEVEL_STR=$1

  ## ref: https://stackoverflow.com/a/13221491
  if [ "${LOGLEVELSTR_TO_LEVEL[${LOG_LEVEL_STR}]+abc}" ]; then
    LOG_LEVEL="${LOGLEVELSTR_TO_LEVEL[${LOG_LEVEL_STR}]}"
  else
    abort "Unknown log level of [${LOG_LEVEL_STR}]"
  fi

}


function main() {

  if [ ! -e $CONFIG_FILEPATH ]; then
      logError "Config file ${CONFIG_FILEPATH} not found, quitting now!"
      exit 1
  fi

  logInfo "Reading configs from ${CONFIG_FILEPATH} ...."
  source ${CONFIG_FILEPATH}

  logInfo "EMAIL_FROM=${EMAIL_FROM}"
  logInfo "EMAIL_TO=${EMAIL_TO}"
  logInfo "LOG_DIR=${LOG_DIR}"

  LOG_FILE=${LOG_DIR}/run-${BACKUP_LABEL}-backup.log

  logInfo "make sure backup nfs share is mounted"
  mount -a

  logInfo "truncating log file ${LOG_FILE}"
  mkdir -p ${LOG_DIR}
  touch ${LOG_FILE}
  cat /dev/null > ${LOG_FILE}

  # Run the backup
  BACKUP_SCRIPT_COMMAND="${BACKUP_SCRIPT} ${SOURCE_DIR} ${DEST_DIR} 2>&1 | tee -a ${LOG_FILE}"
  logInfo "${BACKUP_SCRIPT_COMMAND}"
  #${BACKUP_SCRIPT} ${BACKUP_LABEL} ${SOURCE_DIR} ${DEST_DIR} 2>&1 | tee -a ${LOG_FILE}
  ${BACKUP_SCRIPT_COMMAND}

  BACKUP_RETURN_CODE=${?}

  BACKUP_STATUS_MSG=""

  # Check backup job success
  if [ "${BACKUP_RETURN_CODE}" -eq "0" ]
  then
    logInfo "[$(date -Is)] Backup completed successfully\n"
    # Clear unneeded partials and lock file
    BACKUP_STATUS_MSG=SUCCESS
  else
    logInfo "[$(date -Is)] Backup failed, try again later\n"
    BACKUP_STATUS_MSG=FAILED
  fi

  cat "${LOG_FILE}" | mail -s "[$BACKUP_STATUS_MSG] ${BACKUP_LABEL_MSG} rsync backup : ${SOURCE_DIR}->${DEST_DIR}" -r ${EMAIL_FROM} ${EMAIL_TO}

  exit ${BACKUP_RETURN_CODE}

}

main "$@"
