#!/usr/bin/env bash

PROJECT_DIR=$( git rev-parse --show-toplevel )
echo "PROJECT_DIR=${PROJECT_DIR}"

find . -maxdepth 1 -type l -print -exec rm {} \;

cd "${PROJECT_DIR}/tests"

echo "Set up inventory symlink"
ln -sf ../inventory/dev inventory

echo "Set up collections symlink"
ln -sf ../collections

echo "Set up functionality symlinks (library/roles/vars)"
ln -sf ../library
ln -sf ../roles
ln -sf ../vars

echo "finished"
