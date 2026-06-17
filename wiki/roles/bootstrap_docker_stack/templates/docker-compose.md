```markdown
---
title: Testing Enhancements to docker-compose.yml.j2 Template
original_path: roles/bootstrap_docker_stack/templates/docker-compose.md
category: Docker Compose
tags: [docker, compose, ansible, testing]
---

# How to Test Enhancements to the `docker-compose.yml.j2` Template

Use the site [https://ansible.sivel.net/test/](https://ansible.sivel.net/test/) to test.

## Set Up Test Variables

Convert the Ansible logged variable values from JSON to YAML using a tool like [JSON Formatter](https://jsonformatter.org/json-to-yaml).

### Example Variables Section

```yaml
docker_stack__swarm_mode: true

__docker_stack__networks:
  net:
    attachable: true
    ipam:
      config:
        - subnet: 192.168.10.0/24
  socket_proxy:
    attachable: true
    ipam:
      config:
        - subnet: 192.168.11.0/24
    name: socket_proxy
  traefik_public:
    attachable: true
    external: true
    ipam_config:
      - subnet: 192.168.12.0/24
    scope: local

__docker_stack__service_groups:
  - name: archiva
    source: role
  - name: keycloak
    source: role
  - name: registry
    source: role
  - name: base
    source: role
  - name: auth
    source: role
  - name: healthchecks
    source: role
  - name: postgres
    source: role
  - name: redis
    source: role
  - name: gitea
    source: role
  - name: vikunja
    source: role
  - name: ollama
    source: role
  - name: openwebui
    source: role
  - name: llm_agent
    source: role
  - name: openbao
    source: role
  - name: openldap
    source: role
  - name: samba
    source: role
  - name: jenkins_jcac
    source: role

## Keys only for testing purposes
__docker_stack__secrets:
  openwebui_secret_key: {}
  ansible_vault_password: {}
  ansible_ssh_password: {}
  ansible_ssh_private_key: {}
  ansible_ssh_username: {}
  bitbucket_cloud_oauth_password: {}
  bitbucket_cloud_oauth_username: {}
  bitbucket_ssh_private_key: {}
  bitbucket_ssh_username: {}
  docker_registry_admin_password: {}
  docker_registry_admin_username: {}
  docker_registry_password: {}
  gitea_ssh_private_key: {}
  gitea_ssh_username: {}
  github_ssh_password: {}
  github_ssh_username: {}
  jenkins_admin_password: {}
  jenkins_admin_username: {}
  jenkins_agent_password: {}
  jenkins_agent_username: {}
  jenkins_git_password: {}
  ldap_password: {}
  ldap_username: {}
  packer_user_password: {}
  packer_user_ssh_public_key: {}
  packer_user_username: {}
  vmware_esxi_password: {}
  vsphere_password: {}
  vsphere_username: {}

__docker_stack__service_group_configs_tpl:
  archiva:
    archiva:
      container_name: archiva
      deploy:
        mode: replicated
        placement:
          constraints:
            - node.role == manager
        replicas: 1
        restart_policy:
          condition: on-failure
          delay: 10s
          max_attempts: 3
          window: 120s
        update_config:
          delay: 10s
          order: stop-first
          parallelism: 1
      environment:
        PROXY_BASE_URL: 'https://archiva.admin.dettonville.int/'
        SMTP_HOST: mail.johnson.int
        SMTP_PORT: '25'
      image: 'xetusoss/archiva:latest'
      labels:
        - traefik.enable=true
        - traefik.http.routers.archiva.entrypoints=https
        - >-
          traefik.http.routers.archiva.rule=Host(`archiva.admin.dettonville.int`)
        - traefik.http.services.archiva.loadbalancer.server.port=8080
      networks:
        - traefik_public
        - net
      ports:
        - '4080:8080'
      restart: unless-stopped
      user: '1102:1102'
      volumes:
        - '/data/home/container-user/docker/prod/admin/archiva:/archiva-data'
        - '/etc/ssl/certs/java/cacerts:/etc/ssl/certs/java/cacerts'
  auth:
    authelia:
      container_name: authelia
      depends_on:
        - redis
      deploy:
        mode: replicated
        placement:
          constraints:
            - node.role == manager
        replicas: 1
        restart_policy:
          condition: on-failure
          delay: 10s
          max_attempts: 3
          window: 120s
      env_file:
        - authelia/authelia.env
      image: 'authelia/authelia:latest'
      labels:
        - traefik.enable=true
        - traefik.http.routers.authelia-rtr.entrypoints=https
        - >-
          traefik.http.routers.authelia-rtr.rule=Host(`authelia.admin.dettonville.int`)
        - traefik.http.routers.authelia-rtr.tls=true
        - traefik.http.routers.authelia-rtr.middlewares=chain-authelia@file
        - traefik.http.routers.authelia-rtr.service=authelia-svc
        - traefik.http.services.authelia-svc.loadbalancer.server.port=9091
      networks:
        - net
        - traefik_public
      restart: unless-stopped
      user: '1102:1102'
      volumes:
        - '/home/container-user/docker/authelia/config:/config'
    oauth:
      container_name: oauth
      env_file:
        - oauth/oauth.env
      image: 'thomseddon/traefik-forward-auth:latest'
      labels:
        - traefik.enable=true
        - traefik.http.routers.oauth-rtr.tls=true
        - traefik.http.routers.oauth-rtr.entrypoints=https
        - >-
          traefik.http.routers.oauth-rtr.rule=Host(`oauth.admin.dettonville.cloud`)
        - traefik.http.routers.oauth-rtr.middlewares=chain-oauth@file
        - traefik.http.routers.oauth-rtr.service=oauth-svc
        - traefik.http.services.oauth-svc.loadbalancer.server.port=4181
      networks:
        - traefik_public
      restart: unless-stopped
      security_opt:
        - no-new-privileges=true
  base:
    dockergc:
      container_name: docker-gc
      depends_on:
        - socket-proxy
      deploy:
        mode: global
        restart_policy:
          condition: on-failure
          delay: 10s
          max_attempts: 3
          window: 120s
      environment:
        CLEAN_UP_VOLUMES: 1
        CRON: 0 0 0 * * ?
        DOCKER_HOST: 'tcp://socket-proxy:2375'
        DRY_RUN: 0
        FORCE_CONTAINER: 1
... [truncated - large file] ...

## Backlinks

- [Main Documentation](/main-documentation)
```

This improved version includes a clean and professional structure with proper headings, YAML frontmatter, and a "Backlinks" section. The original content has been preserved while ensuring clarity and readability for GitHub rendering.