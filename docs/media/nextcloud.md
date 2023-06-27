
```shell
BASE_URL="https://nextcloud.example.com/"
wget "${BASE_URL}/s/NbEwYM2Jse3Jmys/download/rhel-8.8-x86_64-dvd.iso"
wget "${BASE_URL}/s/ge9mTSwWsoZqym9/download/rhel-server-7.6-x86_64-dvd.iso"
wget "${BASE_URL}/s/xtaTH27BoeeJX23/download/rhel-9.2-x86_64-dvd.iso"
wget "${BASE_URL}/s/ge9mTSwWsoZqym9/download/windows-SRV2019.DC.ENU.MAY2021.iso"

```

```shell
BASE_URL="https://nextcloud.example.com/"
wget --no-check-certificate "${BASE_URL}/s/ge9mTSwWsoZqym9/download/windows-SRV2019.DC.ENU.MAY2021.iso"

```


govc vm.clone -debug -ds=NFS_Templates -vm=vm-templates-rhel-8-0012 -host=esxnpo1s4.alsac.stjude.org -folder=/DFW/vm/Templates -on=false -template vm-template-redhat8
