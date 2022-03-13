#!/usr/bin/env bash

FROM=~/repos/python/superset-dev/
TO=~/repos/python/mwviz/

IGNORE_DIR=admin

echo "**********************************"
echo "*** Syncing from $FROM to $TO"
echo "**********************************"

## REF: http://stackoverflow.com/questions/4585929/how-to-use-cp-command-to-exclude-a-specific-directory
EXCLUDES="--exclude=.idea --exclude=.git --exclude=node_modules"
EXCLUDES+=" --exclude=venv"
EXCLUDES+=" --exclude=history*.txt"
EXCLUDES+=" --exclude=*.save.*"
EXCLUDES+=" --exclude=.DS_Store"
EXCLUDES+=" --exclude=$IGNORE_DIR"

cmd="rsync -arv --update --progress ${EXCLUDES} ${FROM} ${TO}"
echo "$cmd"
results=$(eval $cmd)
echo "results=$results"
