#!/usr/bin/env bash

## ref: https://github.com/lidarr/Lidarr/issues/515
## ref: https://bbs.archlinux.org/viewtopic.php?pid=1855695#p1855695
##
# frontend for:            cuetools, shntool, mp3splt
# optional dependencies:    flac, mac, wavpack, ttaenc
# v1.4 sen/Möbius14

SDIR=`pwd`

if ! [ -x "$(command -v cuetag)" ]; then
  echo 'Error: cuetag is not installed.' >&2
  echo '       install with 'apt-get install cuetools'' >&2
  exit 1
fi

tracknums()
{
    trackno=$(($1 + 1))
    boolval=1
    for (( i=1; i<$1; i++ ))
      do
        lz=""
        if [ i < 10 ]; then
            lz="0"
        fi
        if [[ -f "./split/$lz$i. *.flac" ]] || [[ -f "./split/$lz$i *.flac" ]]; then
            boolval=$boolval
        else
            boolval=0
        fi
    done
    return $boolval
}


checker()
{
    retval=1
    ft="$1"
    cf="$2.cue"
    adjfactor="0.88"
    tracksincue=$(find "./$cf" -type f -exec grep "[\n ]+TRACK [0-9]{1,3} AUDIO[\n ]+" {} | wc -c\;)
    indexincue=$(find "./$cf" -type f -exec grep "[\n ]+INDEX [0-9]{1,3}" {} | wc -c\;)
    trackssplitted=$(find ./split -type f -name "*.flac" | wc -c)
    if [ "$tracksincue" > "$trackssplitted" ] && [ "$indexincue" > "$trackssplitted" ]; then
        retval=0
        printf "\n\nERROR! ERROR! ERROR! ERROR! ERROR! ERROR!"
        printf "\n\nNo. of splitted tracks does not match contents of the .cue file.\nPlease check manually."
        printf "`pwd`/$cf"
    fi
    if [ "$tracksincue" > "$trackssplitted" || "$indexincue" > "$trackssplitted" ] && [ ! { "$tracksincue" > "$trackssplitted" && "$indexincue" > "$trackssplitted" } ]; then
        tracknos=$(($(tracknums $tracksincue) + $(tracknums $indexincue)))
        if [ $tracknos < 1 ]; then
            retval=0
        fi
    fi
    if [ "$ft" == "wav" ]; then
        adjfactor="0.6"
    fi
    origsize=$(find ./ -type f -maxdepth 1 -name "*.$ft" -print -exec sh -c "stat -c%s \"{}\"" \; | awk '{ SUM += $1} END { print SUM }')
    origsizeadj=$(echo $origsize*$adjfactor | bc)
    sourcefile=$((${origsizeadj%.*} - 1488))
    if [[ "$filetype" == "mp3" ]] || [[ "$ft" == "ogg" ]]; then
        totsize=$(find ./split -type f -name "*.$ft" -print -exec sh -c "stat -c%s \"{}\"" \; | awk '{ SUM += $1} END { print SUM }')
    else
        totsize=$(find ./split -type f -name "*.flac" -print -exec sh -c "stat -c%s \"{}\"" \; | awk '{ SUM += $1} END { print SUM }')
    fi
    printf "\nOriginal: $origsize\nAdjusted: $sourcefile\nTotal:    $totsize\n"
    if [ "$totsize" > "$sourcefile" ]; then
        return $retval
    else
        return 0
    fi
}


splitter()
{
    printf "\n\nCUEFILENAME: $2\n"
    cfn="$2"
    if [ "$1" = "." ]; then
        echo "False Path!"
    else
        if [ "$1" = "" ]; then
            DIR=$SDIR
        else
            case $1 in
                -h | --help )
                    echo "Usage: cuesplit [Path]"
                    echo "       The default path is the current directory."
                    exit
                    ;;
                * )
                DIR=$1
            esac
        fi
        echo -e "\

        Directory: $DIR
        ________________________________________
        "
        cd "$DIR"
        cuefiles=$(find ./ -maxdepth 1 -type f -name "*.cue" | wc -c)
        printf "Number of Cuefiles: $cuefiles"
        TYPE=`ls -t1`
        case $TYPE in
            *.ape*)
                mkdir split
                if [ "$cuefiles" > 1 ] && [[ -f "$cfn.ape" ]]; then
                    shnsplit -d split -f "$cfn.cue" -o "flac flac -V --best -o %f -" "$cfn.ape" -t "%n. %p - %t"
                else
                    shnsplit -d split -f *.cue -o "flac flac -V --best -o %f -" *.ape -t "%n. %p - %t"
                fi
                rm -f split/00.*pregap*
                cuetag "$cfn.cue" split/*.flac
                if [ -z "$(ls -A ./split)" ]; then
                    echo "Failure"
                    rmdir split
                elif [[ "$(checker 'ape' $cfn)" -eq 0 ]]; then
                    echo "Failure 2"
                else
                    if [ "$cuefiles" > 1 ] && [[ -f "$cfn.ape" ]]; then
                        rm -f "$cfn.ape"
                    else
                        rm -f *.ape
                    fi
                    mv split/*.flac ./
                    rmdir split
                    echo "Success"
                fi
                ;;

            *.flac*)
                mkdir split
                if [ "$cuefiles" > 1 ] && [[ -f "$cfn.flac" ]]; then
                    shnsplit -d split -f "$cfn.cue" -o "flac flac -V --best -o %f -" "$cfn.flac" -t "%n. %p - %t"
                else
                    shnsplit -d split -f *.cue -o "flac flac -V --best -o %f -" *.flac -t "%n. %p - %t"
                fi
                rm -f split/00.*pregap*
                cuetag "$cfn.cue" split/*.flac
               if [ -z "$(ls -A ./split)" ]; then
                    echo "Failure"
                    rmdir split
                elif [[ "$(checker 'flac' $cfn)" -eq 0 ]]; then
                    echo "Failure 2"
                else
                    if [ "$cuefiles" > 1 ] && [[ -f "$cfn.flac" ]]; then
                        rm -f "$cfn.flac"
                    else
                        rm -f *.flac
                    fi
                    mv split/*.flac ./
                    rmdir split
                    echo "Success"
                fi
                ;;

            *.mp3*)
                mkdir split
                if [ "$cuefiles" > 1 ] && [[ -f "$cfn.mp3" ]]; then
                    mp3splt -no "@n. @p - @t" -c "$cfn.cue" "$cfn.mp3"
                else
                    mp3splt -no "@n. @p - @t" -c *.cue *.mp3
                fi
                cuetag "$cfn.cue" split/*.mp3
                if [ -z "$(ls -A ./split)" ]; then
                    echo "Failure"
                    rmdir split
                elif [[ "$(checker 'mp3' $cfn)" -eq 0 ]]; then
                    echo "Failure 2"
                else
                    if [ "$cuefiles" > 1 ] && [[ -f "$cfn.mp3" ]]; then
                        rm -f "$cfn.mp3"
                    else
                        rm -f *.mp3
                    fi
                    mv split/*.mp3 ./
                    rmdir split
                    echo "Success"
                fi
                ;;

            *.ogg*)
                mkdir split
                if [ "$cuefiles" > 1 ] && [[ -f "$cfn.ogg" ]]; then
                    mp3splt -no "@n. @p - @t" -c "$cfn.cue" "$cfn.ogg"
                else
                    mp3splt -no "@n. @p - @t" -c *.cue *.ogg
                fi
                cuetag *.cue split/*.ogg
                if [ -z "$(ls -A ./split)" ]; then
                    echo "Failure"
                    rmdir split
                elif [[ "$(checker 'ogg' $cfn)" -eq 0 ]]; then
                    echo "Failure 2"
                else
                    if [ "$cuefiles" > 1 ] && [[ -f "$cfn.ogg" ]]; then
                        rm -f "$cfn.ogg"
                    else
                        rm -f *.ogg
                    fi
                    mv split/*.ogg ./
                    rmdir split
                    echo "Success"
                fi
                ;;

            *.tta*)
                mkdir split
                if [ "$cuefiles" > 1 ] && [[ -f "$cfn.tta" ]]; then
                    shnsplit -d split -f "$cfn.cue" -o "flac flac -V --best -o %f -" "$cfn.tta" -t "%n. %p - %t"
                else
                    shnsplit -d split -f *.cue -o "flac flac -V --best -o %f -" *.tta -t "%n. %p - %t"
                fi
                rm -f split/00.*pregap*
                cuetag "$cfn.cue" split/*.flac
                if [ -z "$(ls -A ./split)" ]; then
                    echo "Failure"
                    rmdir split
                elif [[ "$(checker 'tta' $cfn)" -eq 0 ]]; then
                    echo "Failure 2"
                else
                    if [ "$cuefiles" > 1 ] && [[ -f "$cfn.tta" ]]; then
                        rm -f "$cfn.tta"
                    else
                        rm -f *.tta
                    fi
                    mv split/*.flac ./
                    rmdir split
                    echo "Success"
                fi
                ;;

            *.wv*)
                mkdir split
                if [ "$cuefiles" > 1 ] && [[ -f "$cfn.wv" ]]; then
                    shnsplit -d split -f "$cfn.cue" -o "flac flac -V --best -o %f -" "$cfn.wv" -t "%n. %p - %t"
                else
                    shnsplit -d split -f *.cue -o "flac flac -V --best -o %f -" *.wv -t "%n. %p - %t"
                fi
                rm -f split/00.*pregap*
                cuetag "$cfn.cue" split/*.flac
                if [ -z "$(ls -A ./split)" ]; then
                    echo "Failure"
                    rmdir split
                elif [[ "$(checker 'wv' $cfn)" -eq 0 ]]; then
                    echo "Failure 2"
                else
                    if [ "$cuefiles" > 1 ] && [[ -f "$cfn.wv" ]]; then
                        rm -f "$cfn.wv"
                    else
                        rm -f *.wv
                    fi
                    mv split/*.flac ./
                    rmdir split
                    echo "Success"
                fi
                ;;

            *.wav*)
                mkdir split
                if [ "$cuefiles" > 1 ] && [[ -f "$cfn.wav" ]]; then
                    shnsplit -d split -f "$cfn.cue" -o "flac flac -V --best -o %f -" "$cfn.wav" -t "%n. %p - %t"
                else
                    shnsplit -d split -f *.cue -o "flac flac -V --best -o %f -" *.wav -t "%n. %p - %t"
                fi
                rm -f split/00*pregap*
                cuetag "$cfn.cue" split/*.flac
                if [ -z "$(ls -A ./split)" ]; then
                    echo "Failure"
                    rmdir split
                elif [[ "$(checker 'wav' $cfn)" -eq 0 ]]; then
                    echo "Failure 2"
                else
                    if [ "$cuefiles" > 1 ] && [[ -f "$cfn.wav" ]]; then
                        rm -f "$cfn.wav"
                    else
                        rm -f *.wav
                    fi
                    mv split/*.flac ./
                    rmdir split
                    echo "Success"
                fi
                ;;

            * )
            echo "Error: Found no files to split!"
            echo "       --> APE, FLAC, MP3, OGG, TTA, WV, WAV"
        esac
    fi
}

if [[ $1 == *$'\n'* ]]; then
    IFS=$'\n'
    strings=($1)
    for (( i=0; i<${#strings[@]}; i++ ))
      do
        if [[ "${strings[$i]}" == "\"." ]] || [[ "${strings[$i]}" == "." ]] || [[ "${strings[$i]}" == "" ]] || [[ "${strings[$i]}" == "\"" ]]; then
            printf " "
        else
            dpath="$SDIR${strings[$i]:1}"
            splitter "$dpath"
        fi
    done
else
    find "$1" -type f -name "*.cue" -print | while read f; do
        h="$(dirname "$f")"
        printf "$h\n"
    done
    find "$1" -type f -name "*.cue" -print | while read f; do
        h="$(dirname "$f")"
        g="$(basename "$f")"
        splitter "$h" "${g:0:-4}"
    done
fi
exit
