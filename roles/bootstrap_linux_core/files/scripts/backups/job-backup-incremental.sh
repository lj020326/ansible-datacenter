#!/usr/bin/env bash

VERSION="2025.6.12"

#SCRIPT_DIR="$(dirname "$0")"
SCRIPT_NAME="$(basename "$0")"

BACKUP_SCRIPT=/opt/scripts/rsync-incremental-backup-local

BACKUP_LABEL="daily"
SOURCE_DIR="/srv/records"
DEST_DIR="/srv/backups/records/${BACKUP_LABEL}"
#CONFIG_FILEPATH=${4:-"${HOME}/.backups.cfg"}
CONFIG_FILEPATH=""

## These defaults may be overridden by the file sourced from CONFIG_FILEPATH
EMAIL_FROM="backups@example.int"
EMAIL_TO="admin@example.int"
LOG_DIR="/var/log/backups"

# shellcheck disable=SC2034
MOUNT_NFS_SHARES=1

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
        # shellcheck disable=SC2034
        REVERSED_ARRAY_REF[VALUE]="$KEY"
    done
}

declare -A LOGLEVELSTR_TO_LEVEL
reverse_array LOGLEVEL_TO_STR LOGLEVELSTR_TO_LEVEL

#LOG_LEVEL=${LOG_DEBUG}
LOG_LEVEL=${LOG_INFO}

function log_error() {
    if [ "$LOG_LEVEL" -ge "$LOG_ERROR" ]; then
        logMessage "${LOG_ERROR}" "${1}"
    fi
}
function log_warn() {
    if [ "$LOG_LEVEL" -ge "$LOG_WARN" ]; then
        logMessage "${LOG_WARN}" "${1}"
    fi
}
function log_info() {
    if [ "$LOG_LEVEL" -ge "$LOG_INFO" ]; then
        logMessage "${LOG_INFO}" "${1}"
    fi
}
# shellcheck disable=SC2329
function log_trace() {
    if [ "$LOG_LEVEL" -ge "$LOG_TRACE" ]; then
        logMessage "${LOG_TRACE}" "${1}"
    fi
}
function log_debug() {
    if [ "$LOG_LEVEL" -ge "$LOG_DEBUG" ]; then
        logMessage "${LOG_DEBUG}" "${1}"
    fi
}
function abort() {
    log_error "$@"
    exit 1
}
# shellcheck disable=SC2329
function fail() {
    log_error "$@"
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
    for ((i = CALL_ARRAY_LENGTH - 1; i >= 0; i--)); do
        REVERSED_CALL_ARRAY+=("${CALLING_FUNCTION_ARRAY[i]}")
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

function usage() {
    echo "Usage: ${SCRIPT_NAME} [options]"
    echo ""
    echo "  Options:"
    echo "       -L [ERROR|WARN|INFO|TRACE|DEBUG] : run with specified log level (default: '${LOGLEVEL_TO_STR[${LOG_LEVEL}]}')"
    echo "       -c CONFIG_FILEPATH : default empty and not loaded (e.g. 'backups.cfg')"
    echo "       -f EMAIL_FROM : default 'backups@example.int'"
    echo "       -t EMAIL_TO : default 'admin@example.int'"
    echo "       -b BACKUP_LABEL : default 'daily'"
    echo "       -s SOURCE_DIR : default '/srv/data1/data/Records'"
    echo "       -d DEST_DIR : default '/srv/backups/records/daily'"
    echo "       -l LOG_DIR : default '/var/log/backups'"
    echo "       -v : show script version"
    echo "       -h : help"
    echo ""
    echo ""
    echo "  Examples:"
    echo "       ${SCRIPT_NAME} "
    echo "       ${SCRIPT_NAME} -b daily -s /data/lee -d /srv/backups/lee/daily"
    echo "       ${SCRIPT_NAME} -L DEBUG -b monthly -s /data/lee -d /srv/backups/lee/monthly"
    echo "       ${SCRIPT_NAME} -v"
    [ -z "$1" ] || exit "$1"
}

function main() {

    while getopts "L:c:f:t:b:s:d:l:vh" opt; do
        case "${opt}" in
        L) setLogLevel "${OPTARG}" ;;
        v) echo "${VERSION}" && exit ;;
        c) CONFIG_FILEPATH="${OPTARG}" ;;
        f) EMAIL_FROM="${OPTARG}" ;;
        t) EMAIL_TO="${OPTARG}" ;;
        b) BACKUP_LABEL="${OPTARG}" ;;
        s) SOURCE_DIR="${OPTARG}" ;;
        d) DEST_DIR="${OPTARG}" ;;
        l) LOG_DIR="${OPTARG}" ;;
        h) usage 1 ;;
        \?) usage 2 ;;
        *) usage ;;
        esac
    done
    shift $((OPTIND - 1))

    if [ $# -gt 0 ]; then
        log_warn "Additional unrecognized parameters will be ignored: [${*}]"
    fi

    if [ -n "${CONFIG_FILEPATH}" ]; then
        if [ ! -e "${CONFIG_FILEPATH}" ]; then
            #      log_warn "Config file ${CONFIG_FILEPATH} not found, skipping!"
            abort "Config file ${CONFIG_FILEPATH} not found, quitting now!"
        else
            log_info "Reading configs from ${CONFIG_FILEPATH} ...."
            # shellcheck disable=SC1090
            source "${CONFIG_FILEPATH}"
        fi
    fi

    LOG_FILE=${LOG_DIR}/run-${BACKUP_LABEL}-backup.log

    log_debug "BACKUP_LABEL=${BACKUP_LABEL}"
    log_debug "SOURCE_DIR=${SOURCE_DIR}"
    log_debug "DEST_DIR=${DEST_DIR}"
    log_debug "CONFIG_FILEPATH=${CONFIG_FILEPATH}"
    log_debug "EMAIL_FROM=${EMAIL_FROM}"
    log_debug "EMAIL_TO=${EMAIL_TO}"
    log_debug "LOG_DIR=${LOG_DIR}"
    log_debug "LOG_FILE=${LOG_FILE}"

    log_info "make sure NFS backup share is mounted"
    mount -a || { # catch
        log_error "*** Failed to mount NFS backup share, quitting!"
        exit 1
    }

    log_info "truncating log file ${LOG_FILE}"
    mkdir -p "${LOG_DIR}"
    touch "${LOG_FILE}"
    cat /dev/null >"${LOG_FILE}"

    # Run the backup
    BACKUP_SCRIPT_COMMAND="${BACKUP_SCRIPT} ${SOURCE_DIR} ${DEST_DIR} 2>&1 | tee ${LOG_FILE}"
    log_info "${BACKUP_SCRIPT_COMMAND}"
    #${BACKUP_SCRIPT} ${BACKUP_LABEL} ${SOURCE_DIR} ${DEST_DIR} 2>&1 | tee -a ${LOG_FILE}
    eval "${BACKUP_SCRIPT_COMMAND}"
    BACKUP_RETURN_CODE="${?}"

    BACKUP_STATUS_MSG=""

    # Check backup job success
    if [ "${BACKUP_RETURN_CODE}" -eq 0 ]; then
        log_info "[$(date -Is)] Backup completed successfully\n"
        # Clear unneeded partials and lock file
        BACKUP_STATUS_MSG=SUCCESS
    else
        log_info "[$(date -Is)] Backup failed, try again later\n"
        BACKUP_STATUS_MSG=FAILED
    fi

    mail -s "[$BACKUP_STATUS_MSG] ${BACKUP_LABEL_MSG} rsync backup : ${SOURCE_DIR}->${DEST_DIR}" -r "${EMAIL_FROM}" "${EMAIL_TO}" < "${LOG_FILE}"

    exit "${BACKUP_RETURN_CODE}"

}

main "$@"
