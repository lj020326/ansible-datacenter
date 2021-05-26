#!/usr/bin/env bash

## ref: https://stackoverflow.com/questions/14826511/how-to-pick-top-line-of-each-group-of-related-lines-with-awk-after-unix-sort
debug=0
remove_cleanup=0
find_cleanup=0

#
# Ideally this script should be enhanced to do the following:
#
# Free up space in root/non-boot partition:
#
#	1. flush all postfix emails in queue:
#		ref: https://tecadmin.net/flush-postfix-mail-queue/
#
#		Flush All Emails
#		To delete or flush all emails from Postfix mail queue using the following command.
#
#		```
#		postsuper -d ALL
#		```
#
#	2. Clear systemd journals if they exceed X storage
#		This example will keep 1M worth of logs, clearing everything that exceeds this.
#
#		$ journalctl --vacuum-size=1M
#		...
#		Vacuuming done, freed 720.0M of archived journals on disk.
#
#	3. truncate log files
#
#		```
#		## sort to find large log files
#		ls -l --block-size=M | sort -k 5 -n
#		## then truncate the log file with the following
#		cat /dev/null > some_log_file.log
#	 	```
#	4. Remove mlocate db files and disable mlocate if appropriate:
#		ref: https://askubuntu.com/questions/268130/can-i-disable-updatedb-mlocate
#
#		It can be killed with:
#
#		sudo killall updatedb.mlocate
#		Or:
#
#		sudo kill -9 <PID>
#		It runs every day by cron. Disable it with:
#
#		sudo chmod -x /etc/cron.daily/mlocate
#		And if you want to re-enable it:
#
#		sudo chmod +x /etc/cron.daily/mlocate
#		share  improve this answer  follow
#		answered Mar 15 '13 at 12:51
#
#		don't forget to delete /var/lib/mlocate/mlocate.db as well
#


usage() {
    retcode=${1-1}
    echo "" 1>&2
    echo "Usage: $0 [-vrf] [cleanup-file]" 1>&2
    echo "" 1>&2
    echo "      optional:" 1>&2
    echo "          -x: debug mode" 1>&2
    echo "          -f: find files to clean" 1>&2
    echo "          -r: cleanup/remove files" 1>&2
    echo "          cleanup-file: file to store find cleanup results and used to apply cleanup removal" 1>&2
    echo "                    default 'duplicates.txt'" 1>&2
    echo "" 1>&2
    echo "      example usage:" 1>&2
    echo "          $0 " 1>&2
    echo "          $0 to-be-removed.txt" 1>&2
    echo "          $0 -f to-be-removed.txt" 1>&2
    echo "          $0 -r to-be-removed.txt" 1>&2
    echo "          $0 -fr to-be-removed.txt" 1>&2
    exit ${retcode}
}

function find_cleanup() {
  cleanupfile=$1


  find . -not -empty -type f -printf '%s\n' | \
    sort -rn | uniq -d | \
    xargs -I{} -n1 find . -type f -size {}c -print0 | \
    xargs -0 md5sum | \
    sort | uniq -w32 --all-repeated=separate > $cleanupfile
}

function remove_cleanup() {
  cleanupfile=$1

  cleanupfiles=`cat $cleanupfile | sed '/^$/d' | sort -k1,1 -k2,2r | awk '$1 != x { print } { x = $1 }'`

  IFS=$'\n'
  for file_record in $cleanupfiles; do
#      filename=`echo $file_record | tr -s ' ' | cut -d" " -f2`
#      filename=`echo $file_record | sed 's/^(.*)\s+(.*)/$2/'`
      filename=`echo $file_record | cut -c33- | sed 's/^\s*//'`

      if [[ "${filename}" =~ ^\./big/|^\./medium/|^\./small/ ]]; then
        echo "cleanupfile skipped: $filename begins with excluded directory"
      elif [ -f "${filename}" ]; then
          rm "${filename}"
          if [ $? -ne 0 ]; then
              echo "cleanupfile removed: $filename"
          fi
      else
          echo "cleanupfile not found: $filename"
      fi
  done
}

while getopts ":hxfr" opt; do
    case "${opt}" in
        x) debug=1 ;;
        f) find_cleanup=1 ;;
        r) remove_cleanup=1 ;;
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

cleanupfile=${1-"duplicates.txt"}

## ref: https://stackoverflow.com/questions/5908919/shell-script-to-delete-files-when-disk-is-full
## ref: https://liviutudor.com/2013/06/17/very-very-simple-bash-script-to-delete-old-log-files/#sthash.yf5cQamV.dpbs
FILESYSTEM=/dev/sda1 # or whatever filesystem to monitor
CAPACITY=95 # delete if FS is over 95% of usage
CACHEDIR=/home/user/lotsa_cache_files/

# Proceed if filesystem capacity is over than the value of CAPACITY (using df POSIX syntax)
# using [ instead of [[ for better error handling.
if [ $(df -P $FILESYSTEM | awk '{ gsub("%",""); capacity = $5 }; END { print capacity }') -gt $CAPACITY ]
then
    # lets do some secure removal (if $CACHEDIR is empty or is not a directory find will exit
    # with error which is quite safe for missruns.):
    find "$CACHEDIR" --maxdepth 1 --type f -exec rm -f {} \;
    # remove "maxdepth and type" if you want to do a recursive removal of files and dirs
    find "$CACHEDIR" -exec rm -f {} \;
fi


([ $find_cleanup -eq 0 ] && [ $remove_cleanup -eq 0 ]) && echo "must specify one or both of the options (-f/-r) to find (-f) and/or remove (-r) duplicates" >&2 && usage 2;

#if ( [$find_cleanup -eq 0] && [$remove_cleanup -eq 0] ); then
#  echo "must specify one or both of the options (-f/-r) to find (-f) and/or remove (-r) duplicates" >&2
#  usage 2
#fi

if [ $find_cleanup -eq 1 ]; then
  find_cleanup $cleanupfile
fi

if [ $remove_cleanup -eq 1 ]; then
  remove_cleanup $cleanupfile
fi
