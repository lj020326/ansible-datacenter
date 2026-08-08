#!/usr/bin/env bash

## source: https://techblog.jeppson.org/2016/11/automatically-extract-rar-files-downloaded-transmission/
##
## A simple script to extract a rar file inside a directory downloaded by Transmission.
## It uses environment variables passed by the transmission client to find
## and extract any rar files from a downloaded torrent into the folder they were found in.
##
#find /$TR_TORRENT_DIR/$TR_TORRENT_NAME -name "*.rar" -execdir unrar e -o- "{}" \;

## source: https://gist.github.com/RobertDeRose/9391f5da6273eab26f00d2e7c3c945d3

# The script could use more tesing, but it works well for my needs

function extract_rar() {
  isRar=$(ls | grep *.rar)
  timestamp=`date +%Y%m%d%H%M%S`
  unrar_staging=/downloads/tmp/unrar_staging_${timestamp}
#  unrar_staging=/downloads/tmp/unrar_staging
  mkdir -p ${unrar_staging}
  if [ -n "$isRar" ]; then
    # Handle an edge case with some distributors
    isPart01="$(ls *.rar | egrep -i 'part01.rar|part1.rar')"
    if [ -n "$isPart01" ]; then
      isRar=$isPart01
    fi
    toUnrar="$(pwd)/$isRar"
    # we need to move to new location so sonarr doesn't try to mv before its done
    # also, unrar doesn't support changing the filename on extracting, makes sense a little bit
    pushd ${unrar_staging}
#    fileName="$(unrar e -y $toUnrar | egrep "^\.\.\..*OK" | awk '{ print $2 }')"

    ## ref: https://superuser.com/questions/1189702/use-grep-or-other-to-tidify-the-output-of-7z-l
    fileName="$(7z l $toUnrar | tail -n+24 | head -n-9 | cut -c54-)"
    7z e $toUnrar
    # put it back so sonarr can now find it
    mv $fileName $(dirname $toUnrar)
    popd
  fi
#  rm -fr ${unrar_staging}
}

echo "Starting  - $(date)"

cd "$TR_TORRENT_DIR"

if [ -d "$TR_TORRENT_NAME" ]; then
  cd "$TR_TORRENT_NAME"
  #handle multiple episode packs, like those that contain a whole season, or just a single episode
  for rar in $(find . -name '*.rar' -exec dirname {} \; | sort -u);
  do
    pushd $rar
    extract_rar
    popd
  done
fi
