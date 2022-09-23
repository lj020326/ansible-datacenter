#!/usr/bin/env bash


verbosity=1
local_identifier="proxy-test"

usage() {
    echo "" 1>&2
    echo "Usage: $0 [-v number [0-3]] [-i string] proxy_target" 1>&2
    echo "" 1>&2
    echo "      optional:" 1>&2
    echo "          -v: [0-3] (browserstacklocal verbosity level - default is 1 for connectivity related debug)" 1>&2
    echo "          -i: browserstack-local-identifier (defaults to 'proxy-test')" 1>&2
    echo "" 1>&2
    echo "      required:" 1>&2
    echo "          proxy_target:    " 1>&2
    echo "                localhost (runs browserstacklocal with proxy set to localhost:80)" 1>&2
    echo "                devcloud41 (runs browserstacklocal with proxy set to ech-10-170-129-41.dettonville.int:80)" 1>&2
    echo "                devcloud105 (runs browserstacklocal with proxy set to ech-10-170-129-105.dettonville.int:1080)" 1>&2
    echo "" 1>&2
    echo "      example usage:" 1>&2
    echo "          $0 -v 2 -i test123 localhost" 1>&2
    echo "          $0 -i test124 devcloud41" 1>&2
    echo "          $0 devcloud105" 1>&2
    exit 1
}

run_browserstacklocal() {

    BS_KEY=$1
    REMOTE_HOST=$2
    REMOTE_PORT=$3
    LOCAL_IDENTIFIER=$4
    VERBOSITY=${5:-1}
    VERBOSE_ARGS=""

    mkdir -p logs
    SCRIPT_FILE=$(basename $0)
    LOG_FILE="logs/${SCRIPT_FILE%.*}.log"

    if [[ ${VERBOSITY} -ne 0 ]]; then
        VERBOSE_ARGS="--verbose ${VERBOSITY}"
    fi

    cmd="browserstacklocal --key ${BS_KEY} --local-identifier ${LOCAL_IDENTIFIER} --proxy-host ${REMOTE_HOST} --proxy-port ${REMOTE_PORT} --force-proxy -F ${VERBOSE_ARGS}"
    masked_cmd=`echo $cmd | sed "s/\(.*\)$BS_KEY/\1***/g"`
    echo "${masked_cmd}" > ${LOG_FILE}
    echo "${masked_cmd}"
    ${cmd} 2>&1 | tee -a ${LOG_FILE}

}

if [ -z "${BROWSERSTACK_KEY}" ]; then
    echo "must set environment variable BROWSERSTACK_KEY before running"
    exit 1
fi

if [[ ! $(type -P browserstacklocal) ]] ; then
    echo "browserstacklocal executable must be in PATH"
    echo "browserstacklocal not found in PATH=[${PATH}]"
    exit 1
fi


while getopts ":v:i:" opt; do
    case "${opt}" in
        v)
            verbosity=${OPTARG}
            ;;
        i)
            local_identifier=${OPTARG}
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

if [ $# != 1 ]; then
    echo "required proxy_target not specified" >&2
    usage
fi

proxy_target=$1
bs_key=${BROWSERSTACK_KEY}

case "${proxy_target}" in
    "localhost")
        proxy_host=localhost
        proxy_port=80
        ;;
    "devcloud41")
        proxy_host=ech-10-170-129-41.dettonville.int
        proxy_port=80
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

run_browserstacklocal ${bs_key} ${proxy_host} ${proxy_port} ${local_identifier} ${verbosity}
