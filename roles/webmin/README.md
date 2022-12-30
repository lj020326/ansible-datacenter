
# webmin

This role allows you to install [Webmin](http://www.webmin.com) service on linux hosts.

## Role variables

List of default variables available in the inventory:

```YAML
---
webmin_enabled: yes                       # Enable module

webmin_base_dir: "/usr/share/webmin"

webmin_repo_files :
  - "webmin.list"

webmin_modules:
  - url: https://download.webmin.com/download/modules/disk-usage-1.2.wbm.gz

```

## Detailed usage guide

Describe how to use in more detail...

## Testing
```shell
$ ansible-galaxy install dettonville.webmin
$ vagrant up
```

## Reference

- https://github.com/AlbanAndrieu/ansible-webmin

## Contact

[![Linkedin](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/leejjohnson/)
