# Copyright 2017 VMware, Inc.  All rights reserved.
# SPDX-License-Identifier: MIT OR GPL-3.0-only

# docker run -it -v $PWD:/ansible-role-govc --privileged -v /var/run/docker.sock:/var/run/docker.sock ubuntu:14.04  bash

apt-get update
apt-get install  -y   apt-transport-https     ca-certificates     curl     software-properties-common curl python-pip sudo
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update
sudo apt-get install -y docker-ce
pip install molecule docker

