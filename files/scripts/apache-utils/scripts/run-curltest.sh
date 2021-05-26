#!/usr/bin/env bash

verbosity=1
local_identifier="proxy-test"

usage() {
    echo "" 1>&2
    echo "Usage: $0 [-v number [0-3]] [proxy_target]" 1>&2
    echo "" 1>&2
    echo "      optional:" 1>&2
    echo "          -v: [0-3] (browserstacklocal verbosity level - default is 1 for connectivity related debug)" 1>&2
    echo "          proxy_target:    " 1>&2
    echo "                localhost (default - runs curl with proxy set to localhost:80)" 1>&2
    echo "                devcloud41 (runs curl with proxy set to ech-10-170-129-41.dettonville.int:80)" 1>&2
    echo "                devcloud105 (runs curl with proxy set to ech-10-170-129-105.dettonville.int:1080)" 1>&2
    echo "" 1>&2
    echo "      example usage:" 1>&2
    echo "          $0 -v 2 localhost" 1>&2
    echo "          $0 devcloud105" 1>&2
    exit 1
}

run_curltest() {

    PROXY_HOST=$1
    PROXY_PORT=$2
    TARGET_URL=$3
    VERBOSITY=${4-1}

    mkdir -p logs
    SCRIPT_FILE=$(basename $0)
    LOG_FILE="logs/${SCRIPT_FILE%.*}.log"

    VERBOSE_ARGS=""

    if [[ ${VERBOSITY} -eq 1 ]]; then
        VERBOSE_ARGS="-v"
    elif [[ ${VERBOSITY} -eq 2 ]]; then
        VERBOSE_ARGS="-vv"
    elif [[ ${VERBOSITY} -eq 3 ]]; then
        VERBOSE_ARGS="-vvv"
    fi

    cmd="curl --proxy-insecure ${VERBOSE_ARGS} -IsS --proxy http://${PROXY_HOST}:${PROXY_PORT} ${TARGET_URL}"
    echo "${cmd}" > ${LOG_FILE}
    echo "${cmd}"
    ${cmd} 2>&1 | tee -a ${LOG_FILE}
}

while getopts ":v:" opt; do
    case "${opt}" in
        v)
            verbosity=${OPTARG}
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            ;;
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

proxy_target=${1-"localhost"}
bs_key=${BROWSERSTACK_KEY}
proxy_port=80
target_url=${2-"https://www.browserstack.com/"}

case "${proxy_target}" in
    "localhost")
        proxy_host=localhost
        ;;
    "devcloud41")
        proxy_host=ech-10-170-129-41.dettonville.int
        ;;
    "devcloud105")
        proxy_host=ech-10-170-129-105.dettonville.int
        proxy_port=1080
        ;;
    *)
        echo "Invalid proxy_target: $proxy_target" >&2
        usage
        ;;
esac

run_curltest ${proxy_host} ${proxy_port} ${target_url} ${verbosity}
