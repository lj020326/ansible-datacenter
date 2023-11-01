
# Notes on testing vm templates


## Downloading ISO images

```shell
$ cd /data/datacenter/jenkins/osimages/
$ BASE_URL="https://cloud.example.com/"
$ wget "${BASE_URL}/s/NbEwYM2Jse3Jmys/download/rhel-8.8-x86_64-dvd.iso"
$ wget "${BASE_URL}/s/ge9mTSwWsoZqym9/download/rhel-server-7.6-x86_64-dvd.iso"
$ wget "${BASE_URL}/s/xtaTH27BoeeJX23/download/rhel-9.2-x86_64-dvd.iso"
$ wget "${BASE_URL}/s/ge9mTSwWsoZqym9/download/windows-SRV2019.DC.ENU.MAY2021.iso"
$ 
```

```shell
$ cd /data/datacenter/jenkins/osimages/
$ wget --no-check-certificate "${BASE_URL}/s/xtdr8niWgyCRxoX/download/rhel-9.2-x86_64-dvd.iso"
$ ## 
$ curl --progress-bar -fsL -o rhel-9.2-x86_64-dvd.iso "${BASE_URL}/s/xtdr8niWgyCRxoX/download/rhel-9.2-x86_64-dvd.iso"
$ 
```

govc datastore.upload -ds=NFS_ISO /data/datacenter/jenkins/osimages/rhel-9.2-x86_64-dvd.iso iso-repos/linux/RHEL/9/rhel-9.2-x86_64-dvd.iso

govc vm.clone -debug -ds=NFS_Templates -vm=vm-templates-rhel-8-0012 -host=esxnpo1s4.alsac.stjude.org -folder=/DFW/vm/Templates -on=false -template vm-template-redhat8
