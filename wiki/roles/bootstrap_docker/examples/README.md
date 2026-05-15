```markdown
---
title: Installing Docker via Ansible
original_path: roles/bootstrap_docker/examples/README.md
category: Documentation
tags: [ansible, docker, installation, configuration]
---

# Installing Docker via Ansible

## Default Docker Install

```yaml
- hosts: all
  roles:
    - role: bootstrap_docker
```

## Install Docker with devicemapper Storage Driver

```yaml
- hosts: all
  roles:
    - role: bootstrap_docker
      bootstrap_docker__storage_driver: devicemapper
      bootstrap_docker__block_device: /dev/sda3
```

## Install Docker with HTTP Proxy Support

```yaml
- hosts: all
  roles:
    - role: bootstrap_docker
      bootstrap_docker__http_proxy: http://proxy.example.com:80/
      bootstrap_docker__https_proxy: https://proxy.example.com:443/
```

## Install Docker with HTTP Proxy and No Proxy for Internal Sites

```yaml
- hosts: all
  roles:
    - role: bootstrap_docker
      bootstrap_docker__http_proxy: http://proxy.example.com:80/
      bootstrap_docker__https_proxy: https://proxy.example.com:443/
      bootstrap_docker__no_proxy_params: "localhost,127.0.0.0/8,docker-registry.example.com"
```

## Customize Docker Storage Directory for Images and Containers

```yaml
- hosts: all
  roles:
    - role: bootstrap_docker
      bootstrap_docker__graph: /home/docker
```

## Install/Upgrade Docker with Live Restore to Avoid Container Downtime

```yaml
- hosts: all
  roles:
    - role: bootstrap_docker
      bootstrap_docker__live_restore: true
```

# Backlinks

- [Ansible Roles Documentation](../README.md)
- [Docker Configuration Guide](../../docker/README.md)
```

This improved Markdown document includes a standardized YAML frontmatter, clear headings, and a "Backlinks" section for better navigation and context.