#!/usr/bin/env bash

##################
# This script is a modified version of the publicly available script:
# https://raw.githubusercontent.com/moby/moby/master/contrib/download-frozen-image-v2.sh
## ref: https://github.com/schnatterer/docker-image-size/blob/master/scripts/docker-image-size-curl.sh
##################

set -eo pipefail

if [[ ! -z "${DEBUG}" ]]; then set -x; fi
GOARCH=${GOARCH-"amd64"}
GOOS=${GOOS-"linux"}

set -o nounset -o pipefail
#Not setting "-o errexit", because script checks errors and returns custom error messages

DOCKER_HUB_HOST=index.docker.io

## ref: https://stackoverflow.com/questions/69335984/problems-calling-dockers-v2-name-manifest-tag-api
declare -a DOCKER_HTTP_HEADER_ARRAY
DOCKER_HTTP_HEADER_ARRAY+=("application/vnd.docker.distribution.manifest.v2+json")
DOCKER_HTTP_HEADER_ARRAY+=("application/vnd.docker.distribution.manifest.list.v2+json")
DOCKER_HTTP_HEADER_ARRAY+=("application/vnd.oci.image.manifest.v1+json")
DOCKER_HTTP_HEADER_ARRAY+=("application/vnd.oci.image.index.v1+json")

###################
## we substitute the minus sign in `-H` with the respective octal code (\055H)
## ref: https://superuser.com/questions/1371834/escaping-hyphens-with-printf-in-bash
#DELIM='-H Accept:'
DELIM='\055H Accept:'
printf -v DOCKER_HTTP_CURL_HEADERS "${DELIM}%s " "${DOCKER_HTTP_HEADER_ARRAY[@]}"
DOCKER_HTTP_CURL_HEADERS="${DOCKER_HTTP_CURL_HEADERS% }"

LOG_ERROR=0
LOG_WARN=1
LOG_INFO=2
LOG_TRACE=3
LOG_DEBUG=4

logLevel=${LOG_DEBUG}
#logLevel=${LOG_INFO}

## https://www.pixelstech.net/article/1577768087-Create-temp-file-in-Bash-using-mktemp-and-trap
TMP_DIR=$(mktemp -d -p ~)

## ref: https://stackoverflow.com/questions/10982911/creating-temporary-files-in-bash
IMAGE_TAR_FILE=$(mktemp -u --suffix ".tgz")
IMAGE_TAR_FILE_SAVE=0

## keep track of the last executed command
#trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
## echo an error message before exiting
#trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT
#trap 'rm -fr "${TMP_DIR}"' EXIT
#trap '[ "${IMAGE_TAR_FILE_SAVE}" ] || rm -fr "${IMAGE_TAR_FILE}"' EXIT'

function main() {

  checkArgs "$@"
  checkRequiredCommands curl jq sed awk paste bc

  while getopts "f:hx" opt; do
      case "${opt}" in
          f)
              IMAGE_TAR_FILE="${OPTARG}"
              IMAGE_TAR_FILE_SAVE=1
              ;;
          x) LOG_LEVEL=$LOG_DEBUG ;;
          h) usage 1 ;;
          \?) usage 2 ;;
          :)
              echo "Option -$OPTARG requires an argument." >&2
              usage
              ;;
          *)
              usage
              ;;
      esac
  done
  shift $((OPTIND-1))

  if [ $# -lt 1 ]; then
      echo "required image[:tag][@digest] argument(s) not specified" >&2
      usage
  fi

  while [ $# -gt 0 ]; do
    IMAGE_NAME="${1}"
    url="$(determineUrl "${IMAGE_NAME}")"
    logDebug "url=${url}"

    response=$(queryManifest "${url}")
    logDebug "response[0]=${response}"

    if [[ "${?}" != "0" ]]; then exit 1; fi
  
    response=$(getManifestList "${response}" "${url}")
    logDebug "response[1]=${response}"

    sizes=$(echo ${response} | jq -e '.layers[].size' 2>/dev/null)
    logDebug "sizes=${sizes}"

    if [[ "${?}" = "0" ]]; then
        echo "${1}:" $(createAndPrintSum "${sizes}")
    else
        fail "main(): Response: ${response}"
    fi

    digests=$(echo ${response} | jq -e '.layers[].digest' 2>/dev/null)
    logInfo "digests=${digests}"

    downloadDigests "${1}" "${digests}"
    shift
  done
}

logError() {
  if [ $logLevel -ge $LOG_ERROR ]; then
  	echo -e "[ERROR]: ${1}"
  fi
}
logWarn() {
  if [ $logLevel -ge $LOG_WARN ]; then
  	echo -e "[WARN]: ${1}"
  fi
}
logInfo() {
  if [ $logLevel -ge $LOG_INFO ]; then
  	echo -e "[INFO]: ${1}"
  fi
}
logTrace() {
  if [ $logLevel -ge $LOG_TRACE ]; then
  	echo -e "[TRACE]: ${1}"
  fi
}
logDebug() {
  if [ $logLevel -ge $LOG_DEBUG ]; then
  	echo -e "[DEBUG]: ${1}"
  fi
}

function checkArgs() {

  if [[ $# != 1 ]]; then
    echo "Usage: $(basename "$0") NAME[:TAG|@DIGEST]"
    exit 1
  fi
}

function checkRequiredCommands() {
    missingCommands=""
    for currentCommand in "$@"
    do
        isInstalled "${currentCommand}" || missingCommands="${missingCommands} ${currentCommand}"
    done

    if [[ ! -z "${missingCommands}" ]]; then
        fail "checkRequiredCommands(): Please install the following commands required by this script:${missingCommands}"
    fi
}

function isInstalled() {
    command -v "${1}" >/dev/null 2>&1 || return 1
}

function get_target_arch() {
	if [ -n "${TARGETARCH:-}" ]; then
		echo "${TARGETARCH}"
		return 0
	fi

	if type "go" > /dev/null 2>&1; then
		go env GOARCH
		return 0
	fi

	if type "dpkg" > /dev/null 2>&1; then
		debArch="$(dpkg --print-architecture)"
		case "${debArch}" in
			armel | armhf)
				echo "arm"
				return 0
				;;
			*64el)
				echo "${debArch%el}le"
				return 0
				;;
			*)
				echo "${debArch}"
				return 0
				;;
		esac
	fi

	if type "uname" > /dev/null 2>&1; then
		uArch="$(uname -m)"
		case "${uArch}" in
			x86_64)
				echo amd64
				return 0
				;;
			arm | armv[0-9]*)
				echo arm
				return 0
				;;
			aarch64)
				echo arm64
				return 0
				;;
			mips*)
				echo >&2 "I see you are running on mips but I don't know how to determine endianness yet, so I cannot select a correct arch to fetch."
				echo >&2 "Consider installing \"go\" on the system which I can use to determine the correct arch or specify it explicitly by setting TARGETARCH"
				exit 1
				;;
			*)
				echo "${uArch}"
				return 0
				;;
		esac

	fi

	# default value
	echo >&2 "Unable to determine CPU arch, falling back to amd64. You can specify a target arch by setting TARGETARCH"
	echo amd64
}

function get_target_variant() {
	echo "${TARGETVARIANT:-}"
}

function determineUrl() {

    DOCKER_IMAGE="${1}"
    URL_TYPE=${2-"manifest"}
    HOST=""
    EFFECTIVE_HOST=${HOST}

    if [[ ! "${DOCKER_IMAGE}" == *"/"* ]]; then
        EFFECTIVE_HOST=${DOCKER_HUB_HOST}
    else
        HOST="$(parseHost ${DOCKER_IMAGE})"
        if [[ "${HOST}" == "docker.io" ]]; then
          EFFECTIVE_HOST=${DOCKER_HUB_HOST}
        else
            if [[ ! "${HOST}" == *"."* ]]; then
                EFFECTIVE_HOST=${DOCKER_HUB_HOST}
                # First part was no host
                HOST=""
            fi
        fi
    fi

    IMAGE="$(parseImage ${DOCKER_IMAGE} ${HOST})"
    if [[ ! "${IMAGE}" == *"/"* ]] && [[ ${EFFECTIVE_HOST} == ${DOCKER_HUB_HOST} ]]; then
        EFFECTIVE_IMAGE="library/${IMAGE}"
    fi

    TAG="$(parseTag ${IMAGE} ${DOCKER_IMAGE})"
    if [[ -z "${TAG}" ]]; then
        TAG="latest"
    fi

    URL=""
    if [[ "${URL_TYPE}" == "manifest" ]]; then
      URL="https://${EFFECTIVE_HOST:-$HOST}/v2/${EFFECTIVE_IMAGE:-$IMAGE}/manifests/${TAG}"
    elif [[ "${URL_TYPE}" == "digest" ]]; then
      URL="https://${EFFECTIVE_HOST:-$HOST}/v2/${EFFECTIVE_IMAGE:-$IMAGE}/blobs"
    fi
    echo "${URL}"
}

function queryManifest() {
    url="${1}"
    header_auth=$(fetchDockerApiAuthHeader "${url}")

    # If trying to simplify this into a variable "-H $header_auth" you enter quoting hell
    if [[ -z "${header_auth}" ]]; then
        response=$(curl -sL ${DOCKER_HTTP_CURL_HEADERS} "${url}")
    else
        response=$(curl -sL -H "${header_auth}" ${DOCKER_HTTP_CURL_HEADERS} "${url}")
    fi

    if [[ "${?}" != "0" ]] ||  [[ -z ${response} ]]; then fail "queryManifest(): response empty"; fi
    echo "${response}"
}

function fetchDockerApiAuthHeader() {
    url="${1}"
    response=$(curl -sLi "${DOCKER_HTTP_CURL_HEADERS}" "${url}")
    httpResponseCode=$(echo "${response}" | head -n 1 | cut -d$' ' -f2)
    header_auth=""

    if [[ "${httpResponseCode}" == "401" ]]; then
      # e.g. Www-Authenticate: Bearer realm="https://auth.docker.io/token",service="registry.docker.io",scope="repository:library/debian:pull"
      # to: https://auth.docker.io/token?service=registry.docker.io&scope=repository:library/debian:pull
      # e.g. www-authenticate: Bearer realm="https://r.j3ss.co/auth",service="Docker registry",scope="repository:reg:pull"
      # to https://r.j3ss.co/auth?service=Docker%20registry&scope=repository:reg:pull'
      # URL encode any blanks such as service="Docker registry"
      # Remove all remaining spaces at the end to avoid quoting issues
      authUrl=$(echo "${response}" | grep -i www-Authenticate \
                | sed 's|.*Bearer realm="\(.*\)"|\1|' | sed 's|",service|?service|' | sed 's|",scope|\&scope|' | tr -d '"' \
                | sed 's| |%20|' |  tr -d '[:space:]' )
      token="$(curl -sSL "${authUrl}" | jq -e --raw-output .token)"
      header_auth="Authorization: Bearer ${token}"
    elif [[ "${httpResponseCode}" == "200" ]]; then
      response=$(echo ${response} | awk 'END{print}')
    else
      fail "queryManifest(): Request failed. Response: ${response}"
      echo "after fail"
    fi
    echo "${header_auth}"
}

function downloadDigests() {
  docker_image="${1}"
  digests="${2}"

  digestBaseUrl="$(determineUrl "${docker_image}" "digest")"
  logDebug "digestBaseUrl=${digestBaseUrl}"

  for digest in ${digests}
  do
#    logDebug "downloadDigests(): digest[0]=${digest}"

    digest="${digest%\"}"
    digest="${digest#\"}"

    logDebug "downloadDigests(): digest=${digest}"

    digestUrl="${digestBaseUrl}/${digest}"
#    printf -v digestUrl "%s/%s" "${digestBaseUrl}" "${digest}"

    logDebug "downloadDigests(): digestUrl=${digestUrl}"

    header_auth=$(fetchDockerApiAuthHeader "${digestUrl}")

    # If trying to simplify this into a variable "-H $header_auth" you enter quoting hell
    if [[ -z "${header_auth}" ]]; then
        response=$(curl -sL --output "${TMP_DIR}/${digest}" "${digestUrl}")
    else
        response=$(curl -sL -H "Accept-Encoding: identity" -H "${header_auth}" --output "${TMP_DIR}/${digest}" "${digestUrl}")
    fi

    if [[ "${?}" != "0" ]]; then fail "downloadDigests(): download failed"; fi
  done

  logInfo "downloadDigests(): all image layers downloaded successfully to ${TMP_DIR}"

}

function parseHost() {
    HOST="$(echo ${1} | sed 's@^\([^/]*\)/.*@\1@')"
    failIfEmpty ${HOST} "Unable to find repo Host in parameter: ${1}"
    echo "${HOST}"
}

function parseImage() {
    HOST="${2-}" # Might be empty
    if [[ ! -z "$HOST" ]]; then HOST="${HOST}/"; fi
    IMAGE=$(echo "${1}" | sed "s|^${HOST}\([^@:]*\):*.*|\1|")
    failIfEmpty ${IMAGE} "Unable to find image name in parameter: ${1}"
    echo ${IMAGE}
}

function parseTag() {
    IMAGE="${1}"
    echo "${2}" | sed "s|.*${IMAGE}[:@]*\(.*\)|\1|"
}

function getManifestList() {
  manifestJson="${1}"
  url="${2}"

  targetArch="$(get_target_arch)"
  targetVariant="$(get_target_variant)"

  mediaType=$(echo ${manifestJson} | jq -er '.mediaType' 2>/dev/null)
  ## ref: https://askubuntu.com/questions/459402/how-to-know-if-the-running-platform-is-ubuntu-or-centos-with-help-of-a-bash-scri
  case "${mediaType}" in
    *"application/vnd.docker.distribution.manifest.list.v2+json"* | *"application/vnd.oci.image.index.v1+json"*)
      newDigest=$(echo ${manifestJson} | jq -er  ".manifests[] | select(.platform.architecture == \"${targetArch}\" and .platform.os == \"${GOOS}\") | .digest")
      if [[ "${?}" = "0" ]]; then
          newUrl="$(echo ${url} | sed 's|\(.*\)/.*$|\1|')/${newDigest}"
          manifestJson=$(queryManifest "${newUrl}")
      else
        fail "getManifestList(): manifestJson: ${manifestJson}"
      fi
      ;;
  esac
  echo "${manifestJson}"
}

function createAndPrintSum() {
    echo $(( ($(echo "${1}" | paste -sd+ | bc) + 500000) / 1000 / 1000)) MB
}

function failIfEmpty() {
    if [[ -z "${1}" ]]; then
        fail "failIfEmpty(): ${2}"
    fi
}

function fail() {
    error "$@"
    error Calculating size failed for ${IMAGE_NAME}
    exit 1
}

function error() {
    echo "$@" 1>&2;
}

main "$@"
