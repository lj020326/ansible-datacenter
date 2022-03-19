#!/bin/bash

## script below depends on having gnu command line utils
## if on macOS - follow the dirs at the link below to install gnu tools
## ref: https://www.topbug.net/blog/2013/04/14/install-and-use-gnu-command-line-tools-in-mac-os-x/

set -e

#DATE=`date +%Y%m%d`
#DATE=`date +%Y%m%d%H%M%S`
DATE=${DATE:-`date +%Y%m%d%H%M%S`}

#IGNORE_DIR=admin
IGNORE_DIR=${IGNORE_DIR:-admin}

#IGNORE_DIRS_FIND='-not -path "*/admin/*" -not -path "*/configs/*"'
IGNORE_DIRS_FIND=${IGNORE_DIRS_FIND:-'-not -path "*/admin/*" -not -path "*/configs/*"'}

#GREP_EXCLUDES="--exclude=\"*.save.*\" --exclude=\"\*.{png,jpg,gz,zip}\" --exclude-dir={node_modules,$IGNORE_DIRS,venv,.idea,.git}"
GREP_EXCLUDES=${GREP_EXCLUDES:-"--exclude=\"*.save.*\" --exclude=\"\*.{png,jpg,gz,zip}\" --exclude-dir={node_modules,$IGNORE_DIRS,venv,.idea,.git}"}

echo "date=$DATE"
echo "IGNORE_DIR=$IGNORE_DIR"
echo "IGNORE_DIRS_FIND=$IGNORE_DIRS_FIND"
echo "GREP_EXCLUDES=$GREP_EXCLUDES"


function cleanup_project() {
    echo "**********************************"
    echo "*** Cleanup unnecessary artifacts"
    echo "**********************************"

    FILES="CONTRIBUTING.md
CHANGELOG.md
ISSUE_TEMPLATE.md
INTHEWILD.md
TODO.md
LICENSE.txt
venv
.idea"

    for f in $FILES
    do
        echo "Processing $f"
        if test -f "$f"; then
            echo "Removing File $f"
            rm $f
        elif test -d "$f"; then
            echo "Removing Directory $f"
            rm -fr $f
        fi
    done

    return 0
}


function rename_project () {
    replace_pattern $FROM $TO
}


function replace_pattern () {
    exact=${3:-false}
    rename_files $1 $2 $exact
    replace_content $1 $2 $exact
}

function rename_files () {
    FROM=$1
    TO=$2
    exact=${3:-false}

    FROM2="$(tr '[:lower:]' '[:upper:]' <<< ${FROM:0:1})${FROM:1}"
    TO2="$(tr '[:lower:]' '[:upper:]' <<< ${TO:0:1})${TO:1}"

    FROM_ALL_CAPS=`echo "$FROM" | tr '[:lower:]' '[:upper:]'`
    TO_ALL_CAPS=`echo "$TO" | tr '[:lower:]' '[:upper:]'`
    #TO_ALL_CAPS="${TO,,}"

    echo "FROM_ALL_CAPS=$FROM_ALL_CAPS"
    echo "TO_ALL_CAPS=$TO_ALL_CAPS"


    echo "GREP_EXCLUDES=$GREP_EXCLUDES"
    #exit 0

    echo "**********************************"
    echo "*** renaming file from $FROM to $TO"
    echo "**********************************"

    ## rename files
#    cmd="find . -iname *$FROM* -type f ${IGNORE_DIRS_FIND} -exec stat -f '%z %N ' {} \; | sort -nr | cut -d ' ' -f2"
#    cmd="find . -iname *${FROM}* -type f ${IGNORE_DIRS_FIND} -printf '%d %p \n' | sort -nr | cut -d ' ' -f2"

    if [ $exact = "false" ]; then
        cmd="find . -iname *${FROM}* ${IGNORE_DIRS_FIND} -printf '%d %p \n' | sort -nr | cut -d ' ' -f2"
    else
        cmd="find . -name *${FROM}* ${IGNORE_DIRS_FIND} -printf '%d %p \n' | sort -nr | cut -d ' ' -f2"
    fi

    echo "$cmd"
    results=$(eval $cmd)
    echo "results=$results"

    for f in ${results}
    do
        if [ $exact = "false" ]; then
            cmd="mv $f `echo $f | sed "s/\(.*\)$FROM/\1$TO/g" | sed "s/\(.*\)$FROM_ALL_CAPS/\1$TO_ALL_CAPS/g"`"
        else
            echo "**EXACT MATCHES ONLY!"
            cmd="mv $f `echo $f | sed "s/\(.*\)$FROM/\1$TO/g"`"
        fi
        echo "$cmd"
        `$cmd`
    done

    return 0
}

function replace_content () {
    FROM=$1
    TO=$2
    exact=${3:-false}

    FROM2="$(tr '[:lower:]' '[:upper:]' <<< ${FROM:0:1})${FROM:1}"
    TO2="$(tr '[:lower:]' '[:upper:]' <<< ${TO:0:1})${TO:1}"

    FROM_ALL_CAPS=`echo "$FROM" | tr '[:lower:]' '[:upper:]'`
    TO_ALL_CAPS=`echo "$TO" | tr '[:lower:]' '[:upper:]'`
    #TO_ALL_CAPS="${TO,,}"

    echo "**********************************"
    echo "*** updating strings with $FROM to $TO"
    echo "**********************************"

    cmd="grep -iIr $GREP_EXCLUDES $FROM * | cut -f1 -d: | sort | uniq"
    echo $cmd
    results=$(eval $cmd)
    echo "results=$results"

    for i in ${results}
    do
        if [ ! -f $i.save.$DATE ]; then
            cmd="cp -p $i $i.save.$DATE"
            echo "$cmd"
            `$cmd`
        fi
        cmd="mv -f ${i} ${i}.save.$DATE.tmp"
        echo "$cmd"
        `$cmd`

        if [ $exact = "false" ]; then
            cmd="cat ${i}.save.${DATE}.tmp | sed \"s/${FROM}/${TO}/g\" | sed \"s/${FROM2}/${TO2}/gI\" | sed \"s/${FROM_ALL_CAPS}/${TO_ALL_CAPS}/g\" > $i"
        else
            echo "**EXACT MATCHES ONLY!"
            cmd="cat ${i}.save.${DATE}.tmp | sed \"s/${FROM}/${TO}/g\" > $i"
        fi
        echo "$cmd"
        results=$(eval $cmd)

        cmd="rm -f ${i}.save.${DATE}.tmp"
        echo "$cmd"
        `$cmd`
    done

    return 0
}

