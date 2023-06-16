## Installing Docker via Ansible
### Default Docker Install
```yaml
---
- hosts: all
  roles:
    - role: bootstrap-docker
```

### Install Docker w/devicemapper
```yaml
---
- hosts: all
  roles:
    - role: bootstrap-docker
      bootstrap_docker__storage_driver: devicemapper
      bootstrap_docker__block_device: /dev/sda3
```

### Install Docker w/HTTP Proxy Support
```yaml
---
- hosts: all
  roles:
    - role: bootstrap-docker
      bootstrap_docker__http_proxy: http://proxy.example.com:80/
      bootstrap_docker__https_proxy: https://proxy.example.com:443/
```

### Install Docker w/HTTP Proxy Support & without proxy on internal sites
```yaml
---
- hosts: all
  roles:
    - role: bootstrap-docker
      bootstrap_docker__http_proxy: http://proxy.example.com:80/
      bootstrap_docker__https_proxy: https://proxy.example.com:443/
      bootstrap_docker__no_proxy_params: "localhost,127.0.0.0/8,docker-registry.example.com"
```

### Install Docker and customize the storage directory of images and containers
```yaml
---
- hosts: all
  roles:
    - role: bootstrap-docker
      bootstrap_docker__graph: /home/docker
```

### Install/Upgrade Docker. Avoid container downtime during the upgrade of a Docker
```yaml
---
- hosts: all
  roles:
    - role: bootstrap-docker
      bootstrap_docker__live_restore: true
```
