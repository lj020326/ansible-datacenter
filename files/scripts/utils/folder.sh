#!/usr/bin/env bash

scriptName="${0%.*}"
logFile="${scriptName}.log"

basedir=$HOME/repos
projFile=$basedir/configs/projects.conf

delim='|'

cd $basedir

#mkdir -p $basedir/config/projects.conf
if [ ! -f $projFile ]; then
    touch $projFile
fi

if [ -f $logFile ]; then
    rm $logFile
fi

writeToLog() {
    echo -e "${1}" | tee -a "${logFile}"
#    echo -e "${1}" >> "${logFile}"
}

usage () {
  cat <<__EOF__
Usage:
  ${0} [COMMANDS] [argument ...]

COMMANDS:
  help                            -- Show this help.
  fold                            -- Print information the page having given PAGE_ID.
  unfold                          -- Print html of the page having given PAGE_ID.

__EOF__
}


fold () {
    dirList=$(grep -r --include 'config' -le "bitbucket" ./ | sed 's/\/\.git\/config//g')

    for dir in ${dirList}
    do
        cd $basedir/$dir
        repo=$(git remote -v | cut -d' ' -f1 | grep bitbucket | uniq | sed 's/\t/\'${delim}'/g')
        project="${dir}${delim}${repo}"
        name=$(echo $project | cut -f2 -d"${delim}")

#        echo "project=${project}"
        grep -q -F "${project}" $projFile || echo "${project}" >> $projFile
        echo "git remote remove ${name}"
        git remote remove ${name}
    done

    echo "*** projFile ${projFile} ***"
    cat $projFile
}

unfold () {

    projList=$(cat $projFile)

    for project in ${projList}
    do
        dir=$(echo $project | cut -f1 -d"${delim}")
        name=$(echo $project | cut -f2 -d"${delim}")
        url=$(echo $project | cut -f3 -d"${delim}")

        cd $basedir/$dir
        echo "git remote add ${name} ${url}"
        git remote add ${name} ${url}
    done

}


CMD="${1-}"
shift
case "$CMD" in
  fold)
    fold "$@"
    ;;
  unfold)
    unfold "$@"
    ;;
  --help|help)
    usage
    exit 0
    ;;
  *)
    usage
    exit 1
esac

