#!/usr/bin/env bash

## ref: https://www.howtouselinux.com/post/generate-ssh-key-pair-with-ssh-keygen-command

USERNAME="${1:-ansible@example.int}"
KEYFILE="${2:-ansible-ssh.key}"
ssh-keygen -t rsa -N "" -b 4096 -C ${USERNAME} -f ${KEYFILE}
