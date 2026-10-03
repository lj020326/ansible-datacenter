---
title: "Testing Docker Compose Template Enhancements"
harvested_date: "2023-10-07T18:07:09.196185+00:00"
original_path: "roles/bootstrap_docker_stack/templates/docker-compose-test-standalone.md"
source_type: "legacy_markdown"
category: "Docker"
tags: ["docker-compose", "Ansible", "testing", "template"]
---

# How to Test Enhancements to the `docker-compose.yml.j2` Template

This guide explains how to test your enhancements to the Docker Compose template using a standalone test environment.

## Prerequisites

Before you begin, ensure you have:
- Access to the [Ansible test site](https://ansible.sivel.net/test/)
- A tool to convert JSON to YAML, such as [JSON Formatter](https://jsonformatter.org/json-to-yaml)

## Set Up Test Variables

Convert the Ansible logged variable values from JSON to YAML using the tool available at [https://jsonformatter.org/json-to-yaml](https://jsonformatter.org/json-to-yaml).

Set up the variables section as follows:

```yaml
docker_stack__swarm_mode: false

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
  - name: base
    source: role
  - name: gluetun
    source: role
  - name: registry
    source: role
  - name: redis
    source: role
  - name: media
    source: role
  - name: photoprism
    source: role
  - name: openldap
    source: role
  - name: samba
    source: role

__docker_stack__secrets: []

__docker_stack__service_group_configs_tpl:
  base:
    certdumper:
      container_name: traefik_certdumper
      deploy:
        placement:
          constraints:
            - node.labels.traefik-enabled == true
        replicas: 1
        restart_policy:
          condition: on-failure
          delay: 10s
          max_attempts: 3
          window: 120s
      environment:
        DOMAIN: media.dettonville.cloud
      image: 'humenius/traefik-certs-dumper:latest'
      networks:
        - net
      security_opt:
        - no-new-privileges=true
      user: '1003:895'
      volumes:
        - '/home/media/docker/traefik/acme:/traefik:ro'
        - '/home/media/docker/shared/certs:/output:rw'
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
        FORCE_CONTAINER_REMOVAL: 0
        FORCE_IMAGE_REMOVAL: 1
        GRACE_PERIOD_SECONDS: 604800
        TZ: America/New_York
      image: 'clockworksoul/docker-gc-cron:latest'
      networks:
        - socket_proxy
      restart: unless-stopped
      volumes:
        - '/home/media/docker/docker-gc/docker-gc-exclude:/etc/docker-gc-exclude'
    dozzle:
      container_name: dozzle
      deploy:
        mode: replicated
        placement:
          constraints:
            - node.labels.traefik-enabled == true
        replicas: 1
        restart_policy:
          condition: on-failure
          delay: 10s
          max_attempts: 3
          window: 120s
      environment:
        DOCKER_HOST: 'tcp://socket-proxy:2375'
        DOZZLE_FILTER: status=running
        DOZZLE_LEVEL: info
      image: 'amir20/dozzle:latest'
      labels:
        - traefik.enable=true
        - traefik.http.routers.dozzle-rtr.entrypoints=https
        - traefik.http.routers.dozzle-rtr.rule=Host(`dozzle.media.johnson.int`)
        - traefik.http.routers.dozzle-rtr.service=dozzle-svc
        - traefik.http.services.dozzle-svc.loadbalancer.server.port=8080
      networks:
        - traefik_public
        - socket_proxy
      ports:
        - protocol: tcp
          published: 8080
          target: 8080
      restart: unless-stopped
      security_opt:
        - no-new-privileges=true
      volumes:
        - '/var/run/docker.sock:/var/run/docker.sock'
    portainer:
      command: '-H tcp://tasks.portainer-agent:9001 --tlsskipverify'
      container_name: portainer
      deploy:
        mode: replicated
        placement:
          constraints:
            - node.labels.traefik-enabled == true
        replicas: 1
        restart_policy:
          condition: on-failure
          delay: 5s
          max_attempts: 3
          window: 120s
        update_config:
          order: stop-first
          parallelism: 1
      environment:
        TZ: America/New_York
      image: 'portainer/portainer-ce:sts'
      labels:
        - traefik.enable=true
        - traefik.http.routers.portainer-rtr.entrypoints=https
        - traefik.http.routers.portainer-rtr.rule=Host(`portainer.media.johnson.int`)
        - traefik.http.routers.portainer-rtr.priority=1000
        - traefik.http.routers.portainer-rtr.service=portainer-svc
        - traefik.http.routers.portainer-rtr.tls=true
        - traefik.http.routers.portainer-rtr.middlewares=sslheaders@file
        - traefik.http.services.portainer-svc.loadbalancer.server.port=9000
        - traefik.http.services.portainer-svc.loadbalancer.server.scheme=http
        - traefik.http.services.portainer-svc.loadbalancer.passhostheader=true
      networks:
        - traefik_public
        - socket_proxy
      ports:
        - protocol: tcp
          published: 9010
          target: 9000
      restart: unless-stopped
      security_opt:
        - no-new-privileges=true
      volumes:
        - '/etc/localtime:/etc/localtime'
        - '/var/run/docker.sock:/var/run/docker.sock'
        - '/var/lib/docker/volumes:/var/lib/docker/volumes'
        - '/home/media/docker/portainer/data:/data'
    portainer-agent:
      container_name: portainer-agent
      deploy:
        mode: replicated
        placement:
          constraints:
            - node.labels.traefik-enabled == true
        replicas: 1
      image: 'portainer/agent:latest'
      networks:
        - socket_proxy
      volumes:
        - '/var/run/docker.sock:/var/run/docker.sock'
```

## Testing the Template

1. Go to the [Ansible test site](https://ansible.sivel.net/test/).
2. Create a new test playbook.
3. Copy and paste the YAML variables you've set up into the playbook.
4. Add your enhanced `docker-compose.yml.j2` template to the playbook.
5. Run the playbook and review the output.

## Conclusion

By following this guide, you should be able to test your enhancements to the Docker Compose template effectively. This process helps ensure that your changes work as expected before integrating them into your main environment.