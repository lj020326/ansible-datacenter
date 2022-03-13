#!/usr/bin/env bash

debug_container=0

usage() {
    echo "" 1>&2
    echo "Usage: $0 command [filename]" 1>&2
#    echo "" 1>&2
#    echo "      optional:" 1>&2
#    echo "          -x: debug container" 1>&2
    echo "" 1>&2
    echo "      required:" 1>&2
    echo "          command:    " 1>&2
    echo "                 fetch-all (fetches a copy of each the files mentioned below)" 1>&2
    echo "                 fetch-conf (fetches a copy of the httpd sample.conf)" 1>&2
    echo "                 fetch-vhost (fetches a copy of the sample.conf vhost config http.inc)" 1>&2
    echo "                 fetch-log-access (fetches a copy of the apache access log)" 1>&2
    echo "                 fetch-log-error (fetches a copy of the apache error log)" 1>&2
    exit 1
}


fetch_file() {

    REMOTE_CREDS=$1
    REMOTE_HOST=$2
    REMOTE_PORT=$3
    REMOTE_FILE=$4
    FETCHED_FILE=${5-$(basename ${REMOTE_FILE})}
    REMOTE_HOST_URL="${REMOTE_CREDS}@${REMOTE_HOST}"

    IFS=':' read -ra ADDR <<< "${REMOTE_CREDS}"
    REMOTE_USER=${ADDR[0]}
    REMOTE_PW=${ADDR[1]}

    mkdir -p save/fetched
    #scp -P 4444 "${REMOTE_HOST_URL}:${REMOTE_FILE} save/fetched/${FETCHED_FILE}
    pscp -P ${REMOTE_PORT} -pw "${REMOTE_PW}" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_FILE}" "save/fetched/${FETCHED_FILE}"

}


if [ -z "${DEVCLOUD_APACHE_CREDS}" ]; then
    echo "must set environment variable DEVCLOUD_APACHE_CREDS before running"
    exit 1
fi

#PSCP="/usr/local/Cellar/putty/0.70/bin/pscp"
#PSCP="/usr/local/bin/pscp"

if [[ ! $(type -P pscp) ]] ; then
    echo "pscp executable must be in PATH"
    echo "pscp not found in PATH=[${PATH}]"
    exit 1
fi

while getopts ":x" opt; do
    case "${opt}" in
        x)
            debug_container=1
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

if [ $# -lt 1 ]; then
    echo "required command not specified" >&2
    usage
fi

command=$1
remote_filename=${2-""}
devcloud_creds=${DEVCLOUD_APACHE_CREDS}
devcloud_host="ech-10-170-129-105.dettonville.int"
devcloud_port="4444"
httpd_base_dir="/sys_apps_01/apache/server20Cent"
httpd_log_dir="${httpd_base_dir}/logs/sample"
httpd_conf_dir="${httpd_base_dir}/conf"

remote_filename_list="
${httpd_conf_dir}/sample.conf
${httpd_conf_dir}/vhosts-sample/http.inc
${httpd_log_dir}/access_log
${httpd_log_dir}/error_log
"

case "${command}" in
    "fetch-conf")
        if [ -z "${remote_filename}" ]; then
            remote_filename="sample.conf"
        fi
        fetch_file ${devcloud_creds} ${devcloud_host} ${devcloud_port} "${httpd_conf_dir}/${remote_filename}" sample_conf.conf
        ;;
    "fetch-vhost")
        if [ -z "${remote_filename}" ]; then
            remote_filename="vhosts-sample/http.inc"
        fi
        fetch_file ${devcloud_creds} ${devcloud_host} ${devcloud_port} "${httpd_conf_dir}/${remote_filename}" vhost_conf.conf
        ;;
    "fetch-log-access")
        if [ -z "${remote_filename}" ]; then
            remote_filename="access_log"
        fi
        fetch_file ${devcloud_creds} ${devcloud_host} ${devcloud_port} "${httpd_log_dir}/${remote_filename}" access.log
        ;;
    "fetch-log-error")
        if [ -z "${remote_filename}" ]; then
            remote_filename="error_log"
        fi
        fetch_file ${devcloud_creds} ${devcloud_host} ${devcloud_port} "${httpd_log_dir}/${remote_filename}" error.log
        ;;
    "fetch-all")
        for remote_filename in ${remote_filename_list}
        do
            fetch_file ${devcloud_creds} ${devcloud_host} ${devcloud_port} ${remote_filename}
        done

#        remote_filename="sample.conf"
#        fetch_file ${devcloud_creds} ${devcloud_host} ${devcloud_port} "${httpd_conf_dir}/${remote_filename}" sample_conf.conf
#        remote_filename="vhosts-sample/http.inc"
#        fetch_file ${devcloud_creds} ${devcloud_host} ${devcloud_port} "${httpd_conf_dir}/${remote_filename}" vhost_conf.conf
#        remote_filename="access_log"
#        fetch_file ${devcloud_creds} ${devcloud_host} ${devcloud_port} "${httpd_log_dir}/${remote_filename}" access.log
#        remote_filename="error_log"
#        fetch_file ${devcloud_creds} ${devcloud_host} ${devcloud_port} "${httpd_log_dir}/${remote_filename}" error.log
        ;;
    *)
        echo "Invalid command: $command" >&2
        usage
        ;;
esac

