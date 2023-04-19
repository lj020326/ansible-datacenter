#!/usr/bin/env bash

MARKDOWN_FILE=${1:-README.md}
DOWNLOAD_DIR=${2:-img}
ORIG_DIR="$( pwd . )"

echo "MARKDOWN_FILE=${MARKDOWN_FILE}"
echo "DOWNLOAD_DIR=${DOWNLOAD_DIR}"

IMAGE_FILES=$(grep ".png" "${MARKDOWN_FILE}" | sed 's/!\[\(.*\)\](\(.*\))/\2/')

#echo "IMAGE_FILES=${IMAGE_FILES}"
cd "${DOWNLOAD_DIR}"

DOWNLOAD_COUNT=0
for IMAGE_FILE in ${IMAGE_FILES}
do
  echo "*******************"
  echo "performing curl for IMAGE_FILE=${IMAGE_FILE}"
  ## Make Curl Dead Silent (but Print the Error)
  ## ref: https://catonmat.net/cookbooks/curl/make-curl-silent
  curlCmd="curl -S -s -O -J -L ${IMAGE_FILE}"
  echo "${curlCmd}"
  ${curlCmd}
  let DOWNLOAD_COUNT++
done

cd "${ORIG_DIR}"

echo "downloaded ${DOWNLOAD_COUNT} image files"
