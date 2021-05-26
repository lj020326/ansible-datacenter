#!/usr/bin/env bash

##
## ref: https://gist.github.com/ipbastola/2760cfc28be62a5ee10036851c654600
##

#dpkg --list 'linux-image*'|awk '{ if ($1=="ii") print $2}'|grep -v `uname -r` | xargs sudo apt-get purge $1 -y

dpkg -l 'linux-image*' \
  | awk '{ if ($1=="ii") print $3}' \
  | sort -V | perl -p -e 's/\.\d+$//' \
  | uniq | sed "/`uname -r | sed -e 's/-generic//'`/Q" \
  | xargs -d ' ' -i rm -rf /boot/*-{}-*
