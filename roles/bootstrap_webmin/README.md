
# bootstrap_webmin

This role allows you to install [Webmin](http://www.webmin.com) service on linux hosts.

## Role variables

List of default variables available in the inventory:

```YAML
---
bootstrap_webmin__enabled: yes                       # Enable module

bootstrap_webmin__base_dir: "/usr/share/webmin"

bootstrap_webmin__repo_files :
  - "webmin.list"

bootstrap_webmin__modules:
  - url: https://download.webmin.com/download/modules/disk-usage-1.2.wbm.gz

```

## Detailed usage guide

Describe how to use in more detail...

## Testing
```shell
$ vagrant up
```
