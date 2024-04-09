#!/usr/bin/env bash

##
## source: https://fabianlee.org/2021/04/08/docker-determining-container-responsible-for-largest-overlay-directories/
##

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
SCRIPT_NAME=`basename $0`
OUTPUT_NAME="${SCRIPT_NAME%.*}"

RESULTS_FILE_OVERLAY=${OUTPUT_NAME}-overlay.txt
RESULTS_FILE_MAPPINGS=${OUTPUT_NAME}-mappings.txt
RESULTS_FILE_FINAL=${OUTPUT_NAME}.txt

# grab the size and path to the largest overlay dir
#du /var/lib/docker/overlay2 -h | sort -h | tail -n 100 | grep -vE "overlay2$" > large-overlay.txt
du -h --max-depth=1 /var/lib/docker/overlay2 | sort -hr | head -100 | grep -vE "overlay2$" > ${RESULTS_FILE_OVERLAY}

# construct mappings of name to hash
docker inspect $(docker ps -qa) | jq -r 'map([.Name, .GraphDriver.Data.MergedDir]) | .[] | "\(.[0])\t\(.[1])"' | sed 's/\/merged//' > ${RESULTS_FILE_MAPPINGS}

# for each hashed path, find matching container name
#cat ${RESULTS_FILE_OVERLAY} | xargs -l bash -c 'if grep $1 ${RESULTS_FILE_MAPPINGS}; then echo -n "$0 "; fi' > ${RESULTS_FILE_FINAL}

## https://unix.stackexchange.com/questions/113898/how-to-merge-two-files-based-on-the-matching-of-two-columns
join -j 2 -o 1.1,2.1,1.2 <(sort -k2 ${RESULTS_FILE_OVERLAY} ) <(sort -k2 ${RESULTS_FILE_MAPPINGS} ) | sort -h -k1 -r > ${RESULTS_FILE_FINAL}

cat ${RESULTS_FILE_FINAL}
