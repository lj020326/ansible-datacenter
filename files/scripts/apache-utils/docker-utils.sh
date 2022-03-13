#!/usr/bin/env bash

debug_container=0

usage() {
    echo "" 1>&2
    echo "Usage: $0 command image_type" 1>&2
#    echo "" 1>&2
#    echo "      optional:" 1>&2
#    echo "          -x: debug container" 1>&2
    echo "" 1>&2
    echo "      required:" 1>&2
    echo "          command:    build (builds docker image)" 1>&2
    echo "                      clean-build (cleans existing image and rebuilds)" 1>&2
    echo "                      deploy (deploys image to docker repo)" 1>&2
    echo "                      restart (restart container)" 1>&2
    echo "                      debug-container (debug container)" 1>&2
    echo "                      stop (stop container)" 1>&2
    echo "                      tail-log-access (tails apache access log from running container)" 1>&2
    echo "                      tail-log-error (tails apache error log from running container)" 1>&2
    echo "                      fetch-log-access (fetches a copy of the apache access log from running container)" 1>&2
    echo "                      fetch-log-error (fetches a copy of the apache error log from running container)" 1>&2
    echo "          image_type: (debian|centos7)" 1>&2
    exit 1
}

build_image() {

    IMAGE_TYPE=$1
    CLEAN_BUILD=${2-0}

    ARTIFACTORY_PROJECT=com-dettonville-api
    DOCKER_IMAGE_NAME="${ARTIFACTORY_PROJECT}/apache-proxy-${IMAGE_TYPE}"
    DOCKER_IMAGE_SRC_DIR="docker/${IMAGE_TYPE}"
    CONTAINER_NAME="apache-proxy-${IMAGE_TYPE}"

    if [ "$(docker ps -qa -f name=${CONTAINER_NAME})" ]; then
        #if [ "$(docker ps -q -f status=exited -f name=${CONTAINER_NAME})" ]; then
        if [ "$(docker ps -q -f name=${CONTAINER_NAME})" ]; then
            docker stop ${CONTAINER_NAME}
        fi
        docker rm ${CONTAINER_NAME}
    fi

    if [[ ${CLEAN_BUILD} -ne 0 ]]; then
        if [[ "$(docker images -q ${DOCKER_IMAGE_NAME} 2> /dev/null)" ]]; then
            docker rmi ${DOCKER_IMAGE_NAME}
        fi
    fi

    cd ${DOCKER_IMAGE_SRC_DIR}
    docker build -t ${DOCKER_IMAGE_NAME} .

}

deploy_image() {
    IMAGE_TYPE=$1
    ARTIFACTORY_PROJECT=com-dettonville-api
    DOCKER_IMAGE_NAME="${ARTIFACTORY_PROJECT}/apache-proxy-${IMAGE_TYPE}"
    DOCKER_IMAGE_SRC_DIR="docker/${IMAGE_TYPE}"
    DOCKER_REPO_URL="artifactory.dev.dettonville.int:6555"

    cd ${DOCKER_IMAGE_SRC_DIR}
    docker tag ${DOCKER_IMAGE_NAME} ${DOCKER_REPO_URL}/${DOCKER_IMAGE_NAME}

    docker login "https://${DOCKER_REPO_URL}"
    docker push ${DOCKER_REPO_URL}/${DOCKER_IMAGE_NAME}

}

restart_container() {

    IMAGE_TYPE=$1
    DEBUG=${2-0}

    ARTIFACTORY_PROJECT=com-dettonville-api
    DOCKER_IMAGE_NAME="${ARTIFACTORY_PROJECT}/apache-proxy-${IMAGE_TYPE}"
    DOCKER_IMAGE_SRC_DIR="docker/${IMAGE_TYPE}"
    CONTAINER_NAME="apache-proxy-${IMAGE_TYPE}"
    DATA_CONTAINER_NAME="proxy-data-${IMAGE_TYPE}"

    cd ${DOCKER_IMAGE_SRC_DIR}
    if [ ! "$(docker ps -qa -f name=${DATA_CONTAINER_NAME})" ]; then
        docker create --name ${DATA_CONTAINER_NAME} --volume "${PWD}/conf/":/opt/proxy-conf busybox /bin/true
    fi

    if [ "$(docker ps -qa -f name=${CONTAINER_NAME})" ]; then
        #if [ "$(docker ps -q -f status=exited -f name=${CONTAINER_NAME})" ]; then
        if [ "$(docker ps -q -f name=${CONTAINER_NAME})" ]; then
            docker stop ${CONTAINER_NAME}
            echo "container stopped"
        fi
        docker rm ${CONTAINER_NAME}
    fi

    if [[ ${DEBUG} -ne 0 ]]; then
        echo "debugging container - starting bash inside container:"
        docker run --name ${CONTAINER_NAME} --volume "${PWD}/certs":/opt/ssl/ --volumes-from ${DATA_CONTAINER_NAME} -p 80:80 -it --entrypoint /bin/bash ${DOCKER_IMAGE_NAME}
        exit 0
    fi

    docker run --name ${CONTAINER_NAME} --volume "${PWD}/certs":/opt/ssl/ --volumes-from ${DATA_CONTAINER_NAME} -p 80:80 -d ${DOCKER_IMAGE_NAME}
#    docker run --name ${CONTAINER_NAME} --volume "${PWD}/certs":/opt/ssl/ --volumes-from ${DATA_CONTAINER_NAME} --net=host -d ${DOCKER_IMAGE_NAME}

    echo "started container"
    echo "tailing container stdout..."

    docker logs -f ${CONTAINER_NAME}

}


stop_container() {

    IMAGE_TYPE=$1
    DEBUG=${2-0}

    ARTIFACTORY_PROJECT=com-dettonville-api
    DOCKER_IMAGE_NAME="${ARTIFACTORY_PROJECT}/apache-proxy-${IMAGE_TYPE}"
    CONTAINER_NAME="apache-proxy-${IMAGE_TYPE}"
    DOCKER_IMAGE_SRC_DIR="docker/${IMAGE_TYPE}"

    if [ "$(docker ps -qa -f name=${CONTAINER_NAME})" ]; then
        #if [ "$(docker ps -q -f status=exited -f name=${CONTAINER_NAME})" ]; then
        if [ "$(docker ps -q -f name=${CONTAINER_NAME})" ]; then
            docker stop ${CONTAINER_NAME}
            echo "container stopped"
        else
            echo "container not running"
        fi
    fi
}


tail_log() {

    IMAGE_TYPE=$1
    HTTPD_LOG_FILE=$2

    CONTAINER_NAME="apache-proxy-${IMAGE_TYPE}"

    docker exec -it ${CONTAINER_NAME} tail -50f ${HTTPD_LOG_FILE}
}

fetch_log() {

    IMAGE_TYPE=$1
    HTTPD_LOG_FILE=$2
    FETCHED_LOG_FILE=$(basename ${HTTPD_LOG_FILE})

    CONTAINER_NAME="apache-proxy-${IMAGE_TYPE}"

    docker cp ${CONTAINER_NAME}:${HTTPD_LOG_FILE} ${FETCHED_LOG_FILE}
}


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

if [ $# != 2 ]; then
    echo "required command and image arguments not specified" >&2
    usage
fi

command=$1
image_type=$2
httpd_log_dir=""

case "${image_type}" in
    "debian")
        httpd_log_dir="/var/log/apache2"
        ;;
    "centos7")
        httpd_log_dir="/var/log/httpd"
        ;;
    *)
        echo "Invalid image: $image_type" >&2
        usage
        ;;
esac

case "${command}" in
    "build")
        build_image $image_type 0
        ;;
    "clean-build")
        build_image $image_type 1
        ;;
    "deploy")
        deploy_image $image_type
        ;;
    "restart")
        restart_container $image_type $debug_container
        ;;
    "debug-container")
        debug_container=1
        restart_container $image_type $debug_container
        ;;
    "stop")
        stop_container $image_type
        ;;
    "tail-log-access")
        tail_log $image_type "${httpd_log_dir}/access.log"
        ;;
    "tail-log-error")
        tail_log $image_type "${httpd_log_dir}/error.log"
        ;;
    "fetch-log-access")
        fetch_log $image_type "${httpd_log_dir}/access.log"
        ;;
    "fetch-log-error")
        fetch_log $image_type "${httpd_log_dir}/error.log"
        ;;
    *)
        echo "Invalid command: $command" >&2
        usage
        ;;
esac
