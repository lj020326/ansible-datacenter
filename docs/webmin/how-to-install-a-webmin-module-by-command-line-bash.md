
# how to install a webmin module by command line (bash)?

## Issue/Question

I want to install a module in webmin by command line (bash). How do you do this?

Example:

```
wget https://download.webmin.com/download/modules/text-editor.wbm.gz
```

inside this .gz: text-editor.wbm

```
sudo tar -xf text-editor.wbm.gz
```

## Solution

[https://doxfer.webmin.com/Webmin/Module_Development](https://doxfer.webmin.com/Webmin/Module_Development)

According to creator Jamie Cameron it runs like this:

```shell
#RH
$ /usr/libexec/webmin/install-module.pl 
# Debian-Ubuntu
$ /usr/share/webmin/install-module.pl
```

Example module download and install 

```shell
$ wget https://download.webmin.com/download/modules/disk-usage-1.2.wbm.gz
$ sudo /usr/share/webmin/install-module.pl disk-usage-1.2.wbm.gz
```

## Reference

- https://unix.stackexchange.com/questions/523052/how-to-install-a-webmin-module-by-command-line-bash
- 