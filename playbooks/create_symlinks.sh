#!/usr/bin/env bash

PROJECT_DIR=$( git rev-parse --show-toplevel )
echo "PROJECT_DIR=${PROJECT_DIR}"

cd "${PROJECT_DIR}/playbooks"

find . -maxdepth 1 -type l -print -exec rm {} \;

echo "==> Set up site.yml symlink"
ln -sf ../site.yml

echo "==> Set up collections symlink"
ln -sf ../collections

echo "==> Set up functionality symlinks (library/filter_plugins)"
#ln -sf ../library
ln -sf ../filter_plugins
ln -sf ../plugins

echo "==> Set up roles and vars symlinks (roles/vars)"
ln -sf ../roles
ln -sf ../vars

echo "==> Set up resource/other symlinks (molecule/files/etc)"
ln -sf ../molecule
#ln -sf ../files

echo "==> Set up inventory symlink"
#ln -sf ../inventory/dev inventory
ln -sf ../inventory

echo "==> Finished"
