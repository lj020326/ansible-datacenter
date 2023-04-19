#!/usr/bin/env bash

CONFIRM=0
LOGFILE_MIN_SIZE=50M
SCRIPT_NAME=$(basename $0)

usage() {
  retcode=${1:-1}
  echo "" 1>&2
  echo "Usage: ${SCRIPT_NAME} [options]" 1>&2
  echo "" 1>&2
  echo "     options:" 1>&2
  echo "       -y : provide answer yes to skip confirmation" 1>&2
  echo "       -h : help" 1>&2
  echo "" 1>&2
  echo "  Examples:" 1>&2
  echo "     ${SCRIPT_NAME} -y" 1>&2
  echo "     ${SCRIPT_NAME}" 1>&2
  echo "" 1>&2
  exit ${retcode}
}

while getopts "yhf" opt; do
    case "${opt}" in
        y) CONFIRM=1 ;;
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

## ref: https://stackoverflow.com/questions/60919979/limit-logfile-size-for-existing-containers-in-docker
## find large container log files exceeding 50
LARGE_LOG_FILES=$(find /var/lib/docker/containers/ -type f -size +${LOGFILE_MIN_SIZE} -name "*.log")

echo "log files exceeding ${LOGFILE_MIN_SIZE} => ${LARGE_LOG_FILES}"

##
for log_files in ${LARGE_LOG_FILES}; do
#  container_log_size=$(ls -lh "${log_files}" | cut -d ' ' -f 5)
  container_log_size=$(find "${log_files}" -exec ls -lh "{}" \; | cut -d ' ' -f 5)

  container_dir=$(dirname log_files)
  container_config_file=${container_dir}/config.v2.json
  echo "container_config_file=${container_config_file}"
  container_name=$(jq '.Name' ${container_config_file})
  echo "container_name=${container_name} => logfile size=${container_log_size}"
done

if [ $CONFIRM -eq 0 ]; then
  ## https://www.shellhacks.com/yes-no-bash-script-prompt-confirmation/
  read -p "Are you sure you want to remove large log files for the above listed containers? " -n 1 -r
  echo    # (optional) move to a new line
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
      exit 1
  fi
fi

find /var/lib/docker/containers/ -type f -size +50M -name "*.log" -delete
