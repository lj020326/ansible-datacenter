#!/usr/bin/env bash

export MARKDOWN_FILE=${1:-"README.md"}
export IMAGE_DIR=${2:-"./img"}
export ORIG_DIR="$( pwd . )"

echo "MARKDOWN_FILE=${MARKDOWN_FILE}"
echo "IMAGE_DIR=${IMAGE_DIR}"

echo "backup ${MARKDOWN_FILE} to ${MARKDOWN_FILE}.bak"
cp -p "${MARKDOWN_FILE}" "${MARKDOWN_FILE}.bak"

echo "Replace nested image references"
gsed -i 's/\[!\[\(.*\)\](http.*.\(png\|jpg\))\](\(.*\).png)/!\[\1\](\2.\3)/' "${MARKDOWN_FILE}"

#IMAGE_FILES=$(grep ".png" "${MARKDOWN_FILE}" | sed 's/!\[\(.*\)\](\(.*\))/\2/')
IMAGE_FILES=$(grep -e ".png" -e ".jpg" "${MARKDOWN_FILE}" | gsed 's/.*(\(\S*\).\(png\|jpg\).*/\1.\2/')

#echo "IMAGE_FILES=${IMAGE_FILES}"

mkdir -p "${IMAGE_DIR}"
cd "${IMAGE_DIR}"

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

echo "Replace image source location with local directory"
#gsed -i 's/!\[\(.*\)\](http.*\/\(.*\).png)/!\[\1\](\2.png)/' "${MARKDOWN_FILE}"
#gsed -i 's/!\[\(.*\)\](http.*\/\(.*\).png)/!\[\1\](${IMAGE_DIR}\/\2.png)/' "${MARKDOWN_FILE}"
gsed -i 's/!\[\(.*\)\](http.*\/\(.*\).\(png\|jpg\))/!\[\1\](${IMAGE_DIR}\/\2.\3)/' "${MARKDOWN_FILE}"

echo "Replace/Inject IMAGE_DIR environment var"
cp "${MARKDOWN_FILE}" "${MARKDOWN_FILE}.tmp"
#envsubst < "${MARKDOWN_FILE}.tmp" > "${MARKDOWN_FILE}"
envsubst '${IMAGE_DIR}' < "${MARKDOWN_FILE}.tmp" > "${MARKDOWN_FILE}"
rm "${MARKDOWN_FILE}.tmp"

echo "Compare with original"
sdiff -s "${MARKDOWN_FILE}.bak" "${MARKDOWN_FILE}"

echo "downloaded ${DOWNLOAD_COUNT} image files"
