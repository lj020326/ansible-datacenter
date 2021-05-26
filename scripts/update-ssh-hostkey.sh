#!/usr/bin/env bash

HOST=$1

## ref:
ssh-keygen -f "/home/administrator/.ssh/known_hosts" -R ${HOST}

## ref: https://www.techrepublic.com/article/how-to-easily-add-an-ssh-fingerprint-to-your-knownhosts-file-in-linux/
ssh-keyscan -H ${HOST} >> ~/.ssh/known_hosts
