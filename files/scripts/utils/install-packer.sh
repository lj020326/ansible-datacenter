#!/usr/bin/env bash

## ref: https://computingforgeeks.com/how-to-install-and-use-packer/

version="1.6.0"
archiveFile=packer_${version}_linux_amd64.zip
archiveUrl="https://releases.hashicorp.com/packer/${version}/${archiveFile}"

if [[ ! $(type -P unzip) ]] ; then
    echo "unzip not found, installing"
    sudo apt install unzip
fi

echo "fetch ${archiveUrl}"
wget ${archiveUrl}

echo "extract ${archiveFile}"
unzip ${archiveFile}

sudo mv packer /usr/local/bin
