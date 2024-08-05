#!/usr/bin/env bash

##
## ref: https://gist.github.com/cabal95/e36c06e716d3328b512b
##
BACKUPDEST="$1"
DOMAIN="$2"
MAXBACKUPS="$3"

if [ -z "$BACKUPDEST" -o -z "$DOMAIN" ]; then
    echo "Usage: ./vm-backup <backup-folder> <domain> [max-backups]"
    exit 1
fi

if [ -z "$MAXBACKUPS" ]; then
    MAXBACKUPS=6
fi

echo "Beginning backup for $DOMAIN"

#
# Generate the backup path
#
BACKUPDATE=`date "+%Y-%m-%d.%H%M%S"`
BACKUPDOMAIN="$BACKUPDEST/$DOMAIN"
BACKUP="$BACKUPDOMAIN/$BACKUPDATE"
mkdir -p "$BACKUP"

#
# Get the list of targets (disks) and the image paths.
#
TARGETS=`virsh domblklist "$DOMAIN" --details | grep ^file | awk '{print $3}'`
IMAGES=`virsh domblklist "$DOMAIN" --details | grep ^file | awk '{print $4}'`

#
# Create the snapshot.
#
DISKSPEC=""
for t in $TARGETS; do
    DISKSPEC="$DISKSPEC --diskspec $t,snapshot=external"
done
virsh snapshot-create-as --domain "$DOMAIN" --name backup --no-metadata \
	--atomic --disk-only $DISKSPEC >/dev/null
if [ $? -ne 0 ]; then
    echo "Failed to create snapshot for $DOMAIN"
    exit 1
fi

#
# Copy disk images
#
for t in $IMAGES; do
    NAME=`basename "$t"`
    cp "$t" "$BACKUP"/"$NAME"
done

#
# Merge changes back.
#
BACKUPIMAGES=`virsh domblklist "$DOMAIN" --details | grep ^file | awk '{print $4}'`
for t in $TARGETS; do
    virsh blockcommit "$DOMAIN" "$t" --active --pivot >/dev/null
    if [ $? -ne 0 ]; then
        echo "Could not merge changes for disk $t of $DOMAIN. VM may be in invalid state."
        exit 1
    fi
done

#
# Cleanup left over backup images.
#
for t in $BACKUPIMAGES; do
    rm -f "$t"
done

#
# Dump the configuration information.
#
virsh dumpxml "$DOMAIN" >"$BACKUP/$DOMAIN.xml"

#
# Cleanup older backups.
#
LIST=`ls -r1 "$BACKUPDOMAIN" | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}\.[0-9]+$'`
i=1
for b in $LIST; do
    if [ $i -gt "$MAXBACKUPS" ]; then
        echo "Removing old backup "`basename $b`
        rm -rf "$b"
    fi

    i=$[$i+1]
done

echo "Finished backup"
echo ""
