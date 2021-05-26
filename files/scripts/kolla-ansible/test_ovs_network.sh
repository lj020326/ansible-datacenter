#!/usr/bin/env bash

NETNS_QROUTER_ID=$(ip netns ls | awk '/qrouter/ {print $1}')
NETNS_QDHCP_ID=$(ip netns ls | awk '/qdhcp/ {print $1}')
EXT_NET_DEV=cloudbr1

QR_INTID=$(ip netns exec ${NETNS_QROUTER_ID} ip a | awk '/: qr-/ {print $2}')
QG_INTID=$(ip netns exec ${NETNS_QROUTER_ID} ip a | awk '/: qg-/ {print $2}')
QR_INTID=${QR_INTID::-1}
QG_INTID=${QG_INTID::-1}

echo "QR_INTID=${QR_INTID}"
echo "QG_INTID=${QG_INTID}"

ip netns exec ${NETNS_ID} ping 1.1.1.1
ip netns exec ${NETNS_QROUTER_ID} ping 1.1.1.1
ip netns exec ${NETNS_QROUTER_ID} ping 192.168.0.1
