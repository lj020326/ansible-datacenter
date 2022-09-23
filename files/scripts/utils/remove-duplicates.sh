#!/usr/bin/env bash

## ref: https://stackoverflow.com/questions/14826511/how-to-pick-top-line-of-each-group-of-related-lines-with-awk-after-unix-sort
debug=0
remove_dupes=0
find_dupes=0

usage() {
    retcode=${1:-1}
    echo "" 1>&2
    echo "Usage: $0 [-vrf] [dupefile]" 1>&2
    echo "" 1>&2
    echo "      optional:" 1>&2
    echo "          -x: debug mode" 1>&2
    echo "          -f: find dupes" 1>&2
    echo "          -r: remove dupes" 1>&2
    echo "          dupefile: file to store find duplicate results and used to apply dupe removal" 1>&2
    echo "                    default 'duplicates.txt'" 1>&2
    echo "" 1>&2
    echo "      example usage:" 1>&2
    echo "          $0 " 1>&2
    echo "          $0 test-dupes.txt" 1>&2
    echo "          $0 -f test-dupes.txt" 1>&2
    echo "          $0 -r test-dupes.txt" 1>&2
    echo "          $0 -fr test-dupes.txt" 1>&2
    exit ${retcode}
}

function find_dupes() {
  dupefile=$1
  #sort -k1,1 -k2,2 -k3,3nr $dupefile | \
  #    awk '$3 != x {print} {x = $3}'

  #sort -k1,1 -k3,3nr $dupefile | awk '$1 != x { print } { x = $1 }'

  #cat $dupefile | sed '/^$/d' | sort -k1,1 -k2,2r | awk '$1 != x { print } { x = $1 }'

  ## ref: https://stackoverflow.com/questions/19551908/finding-duplicate-files-according-to-md5-with-bash
  ## ref: https://superuser.com/questions/259148/bash-find-duplicate-files-mac-linux-compatible
#  find . -not -empty -type f -printf '%s\n' | \
#    sort -rn | uniq -d | \
#    xargs -I{} -n1 find . -type f -size {}c -print0 | \
#    xargs -0 md5sum | \
#    sort > $dupefile

  find . -not -empty -type f -printf '%s\n' | \
    sort -rn | uniq -d | \
    xargs -I{} -n1 find . -type f -size {}c -print0 | \
    xargs -0 md5sum | \
    sort | uniq -w32 --all-repeated=separate > $dupefile
}

function remove_dupes() {
  dupefile=$1

  dupefiles=`cat $dupefile | sed '/^$/d' | sort -k1,1 -k2,2r | awk '$1 != x { print } { x = $1 }'`

  IFS=$'\n'
  for file_record in $dupefiles; do
#      filename=`echo $file_record | tr -s ' ' | cut -d" " -f2`
#      filename=`echo $file_record | sed 's/^(.*)\s+(.*)/$2/'`
      filename=`echo $file_record | cut -c33- | sed 's/^\s*//'`

      if [[ "${filename}" =~ ^\./big/|^\./medium/|^\./small/ ]]; then
        echo "dupefile skipped: $filename begins with excluded directory"
      elif [ -f "${filename}" ]; then
          rm "${filename}"
          if [ $? -ne 0 ]; then
              echo "dupefile removed: $filename"
          fi
      else
          echo "dupefile not found: $filename"
      fi
  done
}

while getopts ":hxfr" opt; do
    case "${opt}" in
        x) debug=1 ;;
        f) find_dupes=1 ;;
        r) remove_dupes=1 ;;
        h) usage 0 ;;
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

dupefile=${1:-"duplicates.txt"}

([ $find_dupes -eq 0 ] && [ $remove_dupes -eq 0 ]) && echo "must specify one or both of the options (-f/-r) to find (-f) and/or remove (-r) duplicates" >&2 && usage 2;

#if ( [$find_dupes -eq 0] && [$remove_dupes -eq 0] ); then
#  echo "must specify one or both of the options (-f/-r) to find (-f) and/or remove (-r) duplicates" >&2
#  usage 2
#fi

if [ $find_dupes -eq 1 ]; then
  find_dupes $dupefile
fi

if [ $remove_dupes -eq 1 ]; then
  remove_dupes $dupefile
fi
