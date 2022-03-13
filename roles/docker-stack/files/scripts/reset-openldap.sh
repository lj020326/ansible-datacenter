#!/usr/bin/env bash

#DOCKER_CONFIG_DIR=/home/adminuser/docker
CONTAINER_NAME=openldap
CLEANUP_DIRS="openldap/slapd/database openldap/slapd/config"

usage() {
    echo "" 1>&2
    echo "Usage: ${0} [command]" 1>&2
    echo "" 1>&2
    echo "  Options:" 1>&2
    echo "     command:    build (only resets and builds docker image)" 1>&2
    echo "                 restart (default - resets, builds and restarts the openldap container)" 1>&2
    echo "" 1>&2
    echo "  Examples:" 1>&2
    echo "     ${0}"
    echo "     ${0} build"
    echo "     ${0} restart"
    exit 1
}

reset_container() {

    ACTION=${1-"BUILD"}

#    cd ${DOCKER_CONFIG_DIR}

    if [ "$(docker ps -qa --no-trunc --filter name=^/${CONTAINER_NAME}$)" ]; then
        echo "stopping ${CONTAINER_NAME}..." >&2
        docker-compose stop ${CONTAINER_NAME}
        echo "removing ${CONTAINER_NAME} container..." >&2
        docker-compose rm -f ${CONTAINER_NAME}
    fi

    echo "cleaning openldap database & configs..." >&2

#    rm openldap/slapd/database/*
#    rm -fr openldap/slapd/config/*
    for dir in $CLEANUP_DIRS
    do
        rm -fr $dir/*
    done

#    shopt -s nocasematch
#    if [[ ${ACTION} =~ "restart" ]]; then
    if [ "${ACTION,,}" = "restart" ]; then
        echo "starting ${CONTAINER_NAME} container..." >&2
        docker-compose up ${CONTAINER_NAME}
    fi
}

while getopts "h" opt; do
    case "${opt}" in
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

command="BUILD"
echo "$# = ${#}"
echo "$@ = ${@}"

if [ $# -eq 1 ]; then
    command=$1
else
    echo "command not specified, defaulting to build-only..." >&2
fi

reset_container ${command}
