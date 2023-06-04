#!/usr/bin/env bash

HOSTNAME=${1:-media.example.com}
DNS_NAMESERVER=${2:-ns.example.com}

## ref: https://unix.stackexchange.com/questions/426693/how-to-extract-just-the-ip-address-from-a-dns-query
echo "Get IP list for ${HOSTNAME} from ${DNS_NAMESERVER}"
ip_list=$(dig +short "${HOSTNAME}" @${DNS_NAMESERVER} | grep '^[.0-9]*$')

echo "ip_list=${ip_list}"

