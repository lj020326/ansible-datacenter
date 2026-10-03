---
harvested_date: '2026-08-07T18:07:09.198666+00:00'
original_path: roles/bootstrap_docker_stack/templates/docker-compose-test-swarm.md
source_type: legacy_markdown
title: How to Test Enhancements to the Docker Compose YAML Template
category: Docker
tags: [Docker, Ansible, Testing, Swarm]
---

# How to Test Enhancements to the Docker Compose YAML Template

Use the site [Ansible Test](https://ansible.sivel.net/test/) to test your enhancements.

## Introduction

This guide provides instructions on how to test enhancements to the `docker-compose.yml.j2` template using the Ansible Test site. It includes setting up test variables, configuring services, and running tests.

## Set Up Test Variables

Convert the Ansible logged variable values from JSON to YAML using [JSON Formatter](https://jsonformatter.org/json-to-yaml).

Set up the variables section as follows:

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
        FORCE_CONTAINER
... [truncated - large file] ...

## Troubleshooting

- If you encounter issues with network configuration, ensure that the subnets do not overlap with existing networks.
- If services fail to start, check the logs for error messages and verify that all dependencies are properly configured.
- If you experience performance issues, consider adjusting the resource limits for the services.

## Interpreting Test Results

- A successful test will result in all services starting without errors and being accessible via their defined endpoints.
- Check the logs for any warnings or errors that might indicate issues with the configuration.
- Verify that the services are properly connected and communicating with each other.

## Cleaning Up

After testing, it is important to clean up the test environment to avoid resource conflicts with other tests or production environments.

1. Stop and remove all containers created during the test.
2. Remove any networks created during the test.
3. Remove any volumes created during the test.
4. Remove any remaining Docker resources related to the test.

## Contributing Test Results

If your test results reveal improvements or identify issues, consider contributing your findings back to the project.

1. Document your test results and any changes made during testing.
2. Submit a pull request with your changes and documentation.
3. Provide detailed explanations of the changes and their impact on the project.

## Backlinks

[Add any relevant backlinks here]

## Related Resources

- [Ansible Test](https://ansible.sivel.net/test/)
- [JSON Formatter](https://jsonformatter.org/json-to-yaml)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Ansible Documentation](https://docs.ansible.com/)