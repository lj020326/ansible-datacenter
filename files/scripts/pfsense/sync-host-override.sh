#!/usr/bin/env bash

TARGET_HOST=${1:-media.example.com}
NS_HOST=${1:-ns.example.com}

## ref: https://unix.stackexchange.com/questions/426693/how-to-extract-just-the-ip-address-from-a-dns-query
echo "Get IP list for ${TARGET_HOST} from ${NS_HOST}"
ip_list=$(dig +short "${TARGET_HOST}" @${NS_HOST} | grep '^[.0-9]*$')

echo "ip_list=${ip_list}"

