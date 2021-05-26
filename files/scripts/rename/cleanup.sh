#!/usr/bin/env bash

#DATE=20170208131334

for DATE in "$@"
do
    echo "**********************************"
    echo "*** Rolling back changes for DATE=$DATE"
    echo "**********************************"
    for f in `find . -iname "*.save.$DATE"`;
    do
        cmd="rm $f";
        echo "$cmd"
        `$cmd`
    done
done
