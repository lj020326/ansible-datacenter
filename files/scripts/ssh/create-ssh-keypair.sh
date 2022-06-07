#!/usr/bin/env bash

## ref: https://www.howtouselinux.com/post/generate-ssh-key-pair-with-ssh-keygen-command

USERNAME="ansible@example.int"
KEYFILE=ansible-ssh.key
ssh-keygen -t rsa -N "" -b 4096 -C "${USERNAME}" -f ${KEYFILE}
