#!/usr/bin/env bash

HOSTNAME_LIST="
media.example.org
apps.example.org
example.org
"

#HOSTNAME=${1:-media.example.org}
DNS_NAMESERVER=${1:-ns.example.org}

IFS=$'\n'
for HOSTNAME in ${HOSTNAME_LIST}
do
  sync_dns_cmd="python ${HOME}/bin/pfsense_api_client.py sync-host-ip-list ${HOSTNAME} ${DNS_NAMESERVER} --apply"
  echo "${sync_dns_cmd}"
  eval "${sync_dns_cmd}"

  reset_dns_cache="sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder"
  eval "${reset_dns_cache}"
  eval "${reset_dns_cache}"
done
