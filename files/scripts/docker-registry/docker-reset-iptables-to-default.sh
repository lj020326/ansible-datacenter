#!/usr/bin/env bash

#############
## ref: https://stackoverflow.com/questions/62432972/getting-connection-reset-when-accessing-running-docker-container#62433399
#############
set -e

echo "==> Stop docker daemon"
systemctl stop docker

echo "==> Resetting iptables"
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -t nat -F
iptables -t mangle -F
iptables -F
iptables -X

echo "==> Start docker daemon"
systemctl start docker
