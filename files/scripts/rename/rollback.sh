#!/usr/bin/env bash

#DATE=20170208131334
DATE=$1

echo "**********************************"
echo "*** Rolling back changes for DATE=$DATE"
echo "**********************************"

## to rollback changes
for f in `find . -iname "*.save.$DATE"`;
do
#    cmd="cp -p $f "`echo $f | sed s/.save.$DATE//`"";
    cmd="mv $f "`echo $f | sed s/.save.$DATE//`"";
    echo "$cmd"
    `$cmd`
done
