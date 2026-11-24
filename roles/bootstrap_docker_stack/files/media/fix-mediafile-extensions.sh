#!/usr/bin/env bash

VERSION="2025.6.12"

SCRIPT_NAME="$(basename "$0")"

MEDIA_DIR_DEFAULT="${HOME}/data/media/photos/"

DRYRUN_MODE=0
RENAME_FILE_EXTENSIONS_USING_PERL_RENAME=0

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

function isInstalled() {
    command -v "${1}" >/dev/null 2>&1 || return 1
}

function checkRequiredCommands() {
    missingCommands=""
    for currentCommand in "$@"; do
        isInstalled "${currentCommand}" || missingCommands="${missingCommands} ${currentCommand}"
    done

    if [[ -n "${missingCommands}" ]]; then
        fail "checkRequiredCommands(): Please install the following commands required by this script:${missingCommands}"
    fi
}

declare -A MIMETYPE_TO_EXTENSION
MIMETYPE_TO_EXTENSION["image/jpeg"]="jpg"
MIMETYPE_TO_EXTENSION["image/png"]="png"
MIMETYPE_TO_EXTENSION["image/gif"]="gif"

declare -A EXTENSION_TO_MIMETYPE
reverse_array MIMETYPE_TO_EXTENSION EXTENSION_TO_MIMETYPE

function rename_file_extensions() {
    local MEDIA_DIR="${1}"
    local FROM_EXTENSION="${2}"
    local FROM_MIMETYPE="unknown"

    ## ref: https://stackoverflow.com/a/13221491
    if [ "${EXTENSION_TO_MIMETYPE[${FROM_EXTENSION}]+abc}" ]; then
        FROM_MIMETYPE="${EXTENSION_TO_MIMETYPE[${FROM_EXTENSION}]}"
    else
        abort "Unknown mimetype of [${FROM_EXTENSION}]"
    fi

    log_info "Repair incorrect ${FROM_EXTENSION} media file extensions"

    ## ref: https://unix.stackexchange.com/questions/483871/how-to-find-files-by-file-type
    ## ref: https://stackoverflow.com/questions/39421969/how-can-i-change-the-extension-of-files-of-a-type-using-find-with-bash
    ## ref: https://stackoverflow.com/questions/23356779/how-can-i-store-the-find-command-results-as-an-array-in-bash
    FIND_CMD="find ${MEDIA_DIR} -type f -iname \"*.${FROM_EXTENSION}\" -exec bash -c '[[ \"\$( file --mime-type -b \"\$1\" )\" != *${FROM_MIMETYPE}* ]]' bash {} \; -print0"
    log_info "${FIND_CMD}"
    readarray -d '' FILES_WITH_INCORRECT_EXTENSION < <(eval "${FIND_CMD}")
    printf -v FILES_WITH_INCORRECT_EXTENSION_STR "%s\n" "${FILES_WITH_INCORRECT_EXTENSION[@]}"
    log_info "FILES_WITH_INCORRECT_EXTENSION => [${FILES_WITH_INCORRECT_EXTENSION_STR}]"

    for FILE in "${FILES_WITH_INCORRECT_EXTENSION[@]}"; do
        log_debug "FILE=${FILE}"

        TO_MIMETYPE=$(file --mime-type -b "$FILE")
        TO_EXTENSION="unknown"

        ## ref: https://stackoverflow.com/a/13221491
        if [ "${MIMETYPE_TO_EXTENSION[${TO_MIMETYPE}]+abc}" ]; then
            TO_EXTENSION="${MIMETYPE_TO_EXTENSION[${TO_MIMETYPE}]}"
            ## ref: https://stackoverflow.com/questions/12806987/unix-command-to-escape-spaces
            FILENAME_WITH_ESCAPE=$(printf %q "$FILE")
            MV_CMD="mv -- $FILENAME_WITH_ESCAPE ${FILENAME_WITH_ESCAPE%.*}.${TO_EXTENSION}"
            log_info "${MV_CMD}"
            if [ $DRYRUN_MODE -eq 0 ]; then
                eval "${MV_CMD}"
            fi
        else
            #      abort "Unknown mimetype of [${TO_MIMETYPE}] found for FILE=${FILE}"
            log_warn "Unknown mimetype of [${TO_MIMETYPE}] found for FILE=${FILE}"
        fi

    done

}

## ref: https://unix.stackexchange.com/a/720132
function rename_file_extensions_using_perl_rename() {
    local MEDIA_DIR="${1}"
    #  local FROM_EXTENSION="${2}"

    checkRequiredCommands rename
    #  log_info "Repair incorrect ${FROM_EXTENSION} media file extensions"
    log_info "Repair incorrect file extensions"

    FIND_CMD="find ${MEDIA_DIR} -not -empty -type d -print0"
    log_info "${FIND_CMD}"
    readarray -d '' SUBDIRS < <(eval "${FIND_CMD}")
    printf -v SUBDIRS_STR "%s\n" "${SUBDIRS[@]}"
    log_info "SUBDIRS => [${SUBDIRS_STR}]"

    for SUBDIRECTORY in "${SUBDIRS[@]}"; do
        log_debug "SUBDIRECTORY=${SUBDIRECTORY}"
        ## ref: https://stackoverflow.com/questions/12806987/unix-command-to-escape-spaces
        DIRNAME_WITH_ESCAPE=$(printf %q "${SUBDIRECTORY}")

        # ref: https://unix.stackexchange.com/a/720132
        local RENAME_CMD_ARRAY=()
        RENAME_CMD_ARRAY+=("rename")
        if [ $DRYRUN_MODE -eq 1 ]; then
            RENAME_CMD_ARRAY+=("-n")
        fi
        RENAME_CMD_ARRAY+=("--")
        RENAME_CMD_ARRAY+=("'use File::MimeInfo::Magic qw(mimetype extensions);")
        RENAME_CMD_ARRAY+=("my \$ext;")
        RENAME_CMD_ARRAY+=("\$_ .= \".\$ext\" if ! /\./ && (\$ext = extensions mimetype\$_)'")
        #    RENAME_CMD_ARRAY+=("${DIRNAME_WITH_ESCAPE}/*.${FROM_EXTENSION}")
        RENAME_CMD_ARRAY+=("${DIRNAME_WITH_ESCAPE}/*")

        local RENAME_CMD="${RENAME_CMD_ARRAY[*]}"

        log_info "${RENAME_CMD}"
        eval "${RENAME_CMD}"
    done
}

function usage() {
    echo "Usage: ${SCRIPT_NAME} [options] [media_directory]"
    echo ""
    echo "  Options:"
    echo "       -L [ERROR|WARN|INFO|TRACE|DEBUG] : run with specified log level (default: '${LOGLEVEL_TO_STR[${LOG_LEVEL}]}')"
    echo "       -v : show script version"
    echo "       -d : dry run - show expected results but do not apply"
    echo "       -p : perl rename - rename file extensions using perl based rename instead of find based method"
    echo "       -h : help"
    echo ""
    echo "  Examples:"
    echo "       ${SCRIPT_NAME} "
    echo "       ${SCRIPT_NAME} -L DEBUG"
    echo "       ${SCRIPT_NAME} -v"
    echo "       ${SCRIPT_NAME} ~/data/media/photos/2020/2020-selfies/"
    echo "       ${SCRIPT_NAME} -L DEBUG ~/data/media/photos/2020/2020-selfies/"
    echo "       ${SCRIPT_NAME} -d 2012/"
    echo "       ${SCRIPT_NAME} -dp 2018/"
    [ -z "$1" ] || exit "$1"
}

function main() {

    while getopts "L:vdph" opt; do
        case "${opt}" in
        L) setLogLevel "${OPTARG}" ;;
        v) echo "${VERSION}" && exit ;;
        d) DRYRUN_MODE=1 ;;
        p) RENAME_FILE_EXTENSIONS_USING_PERL_RENAME=1 ;;
        h) usage 1 ;;
        \?) usage 2 ;;
        *) usage ;;
        esac
    done
    shift $((OPTIND - 1))

    MEDIA_DIR=${1:-"${MEDIA_DIR_DEFAULT}"}
    log_info "MEDIA_DIR => ${MEDIA_DIR}"

    if [ ${RENAME_FILE_EXTENSIONS_USING_PERL_RENAME} -eq 0 ]; then
        for FILE_MIMETYPE in "${!MIMETYPE_TO_EXTENSION[@]}"; do
            # Get the value associated with the current key
            FILE_EXTENSION="${MIMETYPE_TO_EXTENSION[$FILE_MIMETYPE]}"
            rename_file_extensions "${MEDIA_DIR}" "${FILE_EXTENSION}"
        done
    else
        rename_file_extensions_using_perl_rename "${MEDIA_DIR}"
    fi

    log_info "Finished repair of media file extensions"
}

main "$@"
