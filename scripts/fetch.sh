#!/usr/bin/env bash

debug_container=0

CONTAINER_BASEDIR="/home/media/docker"

remote_user="administrator"
remote_host="media.johnson.int"

src_filename="config.ini"
target_dir="save/files"

usage() {
#    reset
    echo "" 1>&2
    echo "Usage: ${0} [options] container_name" 1>&2
    echo "" 1>&2
    echo "  Options:" 1>&2
    echo "     -r HOST : set remote host used to retrieve files, defaults to \"${remote_host}\"" 1>&2
    echo "     -t TARGET_DIR : set target dir, defaults to \"save/files/\"" 1>&2
    echo "" 1>&2
    echo "  Required:" 1>&2
    echo "     container_name:    " 1>&2
    echo "       traefik (fetches a copy of the traefik settings)" 1>&2
    echo "       portainer (fetches a copy of the portainer settings)" 1>&2
    echo "       heimdall (fetches a copy of the heimdall settings)" 1>&2
    echo "       heimdall-int (fetches a copy of the heimdall-int settings)" 1>&2
    echo "       organizr (fetches a copy of the organizr settings)" 1>&2
    echo "       openvpn (fetches a copy of the openvpn settings)" 1>&2
    echo "       sabnzbd (fetches a copy of the sabnzbd sabnzbd.ini)" 1>&2
    echo "       transmission (fetches a copy of the transmission settings)" 1>&2
    echo "       couchpotato (fetches a copy of the couchpotato config.ini)" 1>&2
    echo "       homeass (fetches a copy of the homeass settings)" 1>&2
    echo "       sonarr (fetches a copy of the sonarr settings)" 1>&2
    echo "       radarr (fetches a copy of the radarr settings)" 1>&2
    echo "       lidarr (fetches a copy of the lidarr settings)" 1>&2
    echo "       medusa (fetches a copy of the medusa config.ini)" 1>&2
    echo "       ombi (fetches a copy of the ombi settings)" 1>&2
    echo "       hydra (fetches a copy of the hydra settings)" 1>&2
    echo "       jackett (fetches a copy of the jackett settings)" 1>&2
    echo "       nextcloud (fetches a copy of the nextcloud settings)" 1>&2
    echo "       pydio (fetches a copy of the pydio settings)" 1>&2
    echo "       all (fetches all files for all containers above)" 1>&2
    echo "" 1>&2
    echo "     container_name: name of the docker container used to retrieve files" 1>&2
    echo "" 1>&2
    echo "  Examples:" 1>&2
    echo "     ${0} couchpotato" 1>&2
    echo "     ${0} medusa -r media.johnson.int -t save/other" 1>&2
    echo "     ${0} medusa -t save/other" 1>&2
    echo "     ${0} all" 1>&2
    echo "" 1>&2
    exit ${1}
}

fetch_file() {

    src_user=$1
    src_host=$2
    container=$3
    target_basedir=$4

    target_container_dir="${target_basedir}/${container}/docker/"
    mkdir -p ${target_container_dir}

    #container_config_dir="${CONTAINER_BASEDIR}/${container}/*.{ini,json}"
    container_config_dir="${CONTAINER_BASEDIR}/${container}/"

    echo ""
    echo "************"
    echo "fetching settings for ${container}"

    #scp "${src_host_url}:${src_file}" "${target_container_dir}"
    #scp "${src_user}@${src_host}:${src_file}" "${target_container_dir}"
    #scp "${src_user}@${src_host}:${container_config}" "${target_container_dir}"
    #rsync -avh "${src_user}@${src_host}:${container_config_dir}" "${target_container_dir}"

    ## ref: https://unix.stackexchange.com/questions/4712/rsync-two-file-types-in-one-command
#    rsync -arvh \
#        --update --progress \
    rsync -arvh \
        --include='**/*.ini' \
        --include='**/*.json' \
        --include='**/*.conf' \
        --include='**/*.toml' \
        --include='**/*.xml' \
        --include='**/config.php' \
        --include='**/etc/*' \
        --exclude='www' \
        --exclude='data' \
        --exclude='MediaCover' \
        --exclude='xdg' \
        --exclude='sess' \
        --exclude='php' \
        --exclude='Downloads' \
        --exclude='downloads' \
        --exclude='incomplete' \
        --exclude='info' \
        --exclude='resume' \
        --exclude='torrents' \
        --exclude='watch' \
        --exclude='*.*' \
        "${src_user}@${src_host}:${container_config_dir}" \
        "${target_container_dir}"
}

if [[ ! $(type -P scp) ]] ; then
    echo "scp executable must be in PATH"
    echo "scp not found in PATH=[${PATH}]"
    exit 1
fi

while getopts "r:t:hx" opt; do
    case "${opt}" in
        r) remote_host="${OPTARG}" ;;
        t) target_dir="${OPTARG}" ;;
        x) debug_container=1 ;;
        h) usage 1 ;;
        \?) usage 2 ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            usage 3
            ;;
        *)
            usage 4
            ;;
    esac
done
shift $((OPTIND-1))

if [ $# -lt 1 ]; then
    echo "required container_name not specified" >&2
    usage 5
fi

container=$1

container_list="
traefik
portainer
cobbler
heimdall
heimdall-int
organizr
openvpn
sabnzbd
transmission
medusa
couchpotato
homeassistant
sonarr
radarr
lidarr
ombi
hydra
jackett
nextcloud
pydio
"

case "${container}" in
    "all")
        for container_name in ${container_list}
        do
            echo "fetching config for ${container_name}.."
            fetch_file ${remote_user} ${remote_host} ${container_name} ${target_dir}
        done
        ;;
    *)
        fetch_file ${remote_user} ${remote_host} ${container} ${target_dir}
        ;;
esac


