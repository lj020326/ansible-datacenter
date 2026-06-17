#!/usr/bin/env bash

# ================================================
# Reset OpenLDAP - Docker Compose + Swarm Support
# ================================================

SERVICE_NAME="openldap"
STACK_PREFIX="docker_stack_"
CLEANUP_DIRS="
openldap/slapd/database
openldap/slapd/config
"

usage() {
    echo "" 1>&2
    echo "Usage: ${0} [command] [options]" 1>&2
    echo "" 1>&2
    echo "  Commands:" 1>&2
    echo "     build      (default) - Reset data only" 1>&2
    echo "     restart    - Reset data and restart service" 1>&2
    echo "" 1>&2
    echo "  Options:" 1>&2
    echo "     --service NAME         Service name (default: openldap)" 1>&2
    echo "     --stack-prefix PREFIX  Swarm stack prefix (default: docker_stack_)" 1>&2
    echo "     --force-standalone     Force standalone mode" 1>&2
    echo "" 1>&2
    echo "  Examples:" 1>&2
    echo "     ${0} restart" 1>&2
    echo "     ${0} restart --force-standalone" 1>&2
    exit 1
}

# Parse arguments
FORCE_STANDALONE=false
COMMAND="build"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --service)
            SERVICE_NAME="$2"
            shift 2
            ;;
        --stack-prefix)
            STACK_PREFIX="$2"
            shift 2
            ;;
        --force-standalone)
            FORCE_STANDALONE=true
            shift
            ;;
        build|restart)
            COMMAND="$1"
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage
            ;;
    esac
done

reset_container() {
    local action=$1
    local full_service_name="${STACK_PREFIX}${SERVICE_NAME}"

    echo "=== Resetting OpenLDAP Service: ${SERVICE_NAME} ==="

    # === Swarm Detection ===
    if [[ "$FORCE_STANDALONE" == true ]]; then
        MODE="standalone"
        echo "Standalone mode forced."
    else
        SWARM_STATUS=$(docker info --format '{{.Swarm.LocalNodeState}}' 2>/dev/null || echo "inactive")
        if [[ "$SWARM_STATUS" == "active" ]]; then
            MODE="swarm"
            echo "Swarm mode detected."
        else
            MODE="standalone"
            echo "Standalone (docker-compose) mode detected."
        fi
    fi

    # === Choose correct service identifier ===
    if [ "${MODE}" = "swarm" ]; then
        SERVICE_ID="${full_service_name}"
    else
        SERVICE_ID="${SERVICE_NAME}"
    fi

    echo "Using service name: ${SERVICE_ID}"

    # === Stop / Remove ===
    if [ "${MODE}" = "swarm" ]; then
        echo "Stopping Swarm service ${SERVICE_ID}..." >&2
        docker service scale "${SERVICE_ID}=0" 2>/dev/null || true
        sleep 2
        docker rm -f $(docker ps -aq --filter "name=^${SERVICE_ID}" 2>/dev/null) 2>/dev/null || true
    else
        echo "Stopping ${SERVICE_ID} via docker-compose..." >&2
        if docker ps -qa --no-trunc --filter "name=^/${SERVICE_ID}$" | grep -q .; then
            docker-compose stop "${SERVICE_ID}" 2>/dev/null || true
            docker-compose rm -f "${SERVICE_ID}" 2>/dev/null || true
        fi
    fi

    # === Clean data ===
    echo "Cleaning OpenLDAP database & configs..." >&2
    for dir in $CLEANUP_DIRS; do
        if [ -d "$dir" ]; then
            echo "  Cleaning ${dir}/*" >&2
            rm -fr "$dir/"* 2>/dev/null || true
        fi
    done

    # === Restart + Follow Logs ===
    if [ "${action,,}" = "restart" ]; then
        echo "Starting ${SERVICE_ID}..." >&2

        if [ "${MODE}" = "swarm" ]; then
            docker service scale "${SERVICE_ID}=1"
            echo "Service started. Following logs (Ctrl+C to stop)..."
            sleep 3
            docker service logs -f --tail=50 "${SERVICE_ID}"
        else
            docker-compose up -d "${SERVICE_ID}"
            echo "Showing logs (Ctrl+C to stop)..."
            docker-compose logs -f "${SERVICE_ID}"
        fi
    fi
}

reset_container "${COMMAND}"
echo "=== OpenLDAP reset completed in ${MODE} mode ==="
