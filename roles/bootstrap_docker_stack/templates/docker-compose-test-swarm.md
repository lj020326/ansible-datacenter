
# How to test enhancements to the docker-compose.yml.j2 template

Use the site https://ansible.sivel.net/test/ to test.

## Set up test variables

Convert the ansible logged variable values and convert from json to yaml at: 
https://jsonformatter.org/json-to-yaml

Set up the variables section:
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

#__docker_stack__service_groups:
#  - name: base
#    source: role
#  - name: llama_cppserver
#    source: role
#  - name: ollama
#    source: role
#  - name: openwebui
#    source: role

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

## keys only for testing purposes
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
        FORCE_CONTAINER_REMOVAL: 0
        FORCE_IMAGE_REMOVAL: 1
        GRACE_PERIOD_SECONDS: 604800
        TZ: America/New_York
      image: 'clockworksoul/docker-gc-cron:latest'
      networks:
        - socket_proxy
      restart: unless-stopped
      volumes:
        - >-
          /home/container-user/docker/docker-gc/docker-gc-exclude:/etc/docker-gc-exclude
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
        - >-
          traefik.http.routers.dozzle-rtr.rule=Host(`dozzle.admin.dettonville.int`)
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
        - >-
          traefik.http.routers.portainer-rtr.rule=Host(`portainer.admin.dettonville.int`)
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
        - '/home/container-user/docker/portainer/data:/data'
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
        - '/var/lib/docker/volumes:/var/lib/docker/volumes'
    socket-proxy:
      container_name: socket-proxy
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
        update_config:
          order: stop-first
          parallelism: 1
      env_file:
        - socket_proxy/socket-proxy.env
      hostname: socket-proxy
      image: 'tecnativa/docker-socket-proxy:latest'
      networks:
        - socket_proxy
      ports:
        - protocol: tcp
          published: 2375
          target: 2375
      privileged: true
      restart: always
      volumes:
        - '/var/run/docker.sock:/var/run/docker.sock'
    traefik:
      container_name: traefik
      depends_on:
        - socket-proxy
      deploy:
        placement:
          constraints:
            - node.labels.traefik-enabled == true
        restart_policy:
          condition: on-failure
          delay: 30s
          max_attempts: 3
          window: 60s
        update_config:
          order: start-first
      env_file:
        - traefik/traefik.env
      image: 'traefik:v3.6'
      labels:
        - traefik.enable=true
        - traefik.http.middlewares.redirect-to-https.redirectscheme.scheme=https
        - traefik.http.routers.http-catchall.entrypoints=http
        - traefik.http.routers.http-catchall.middlewares=redirect-to-https
        - 'traefik.http.routers.http-catchall.rule=HostRegexp(`{host:.+}`)'
        - traefik.http.routers.http-catchall.priority=1
        - traefik.http.routers.ping.entrypoints=https
        - >-
          traefik.http.routers.ping.rule=Host(`traefik.admin.dettonville.int`)
          && PathPrefix(`/ping`)
        - traefik.http.routers.ping.service=ping@internal
        - traefik.http.routers.traefik-rtr.service=api@internal
        - traefik.http.routers.traefik-rtr.entrypoints=https
        - >-
          traefik.http.routers.traefik-rtr.rule=Host(`traefik.admin.dettonville.int`)
        - traefik.http.services.api.loadbalancer.server.port=8080
      networks:
        - traefik_public
        - socket_proxy
      ports:
        - mode: host
          protocol: tcp
          published: 80
          target: 80
        - mode: host
          protocol: tcp
          published: 443
          target: 443
      restart: unless-stopped
      volumes:
        - '/var/run/docker.sock:/var/run/docker.sock:ro'
        - '/home/container-user/docker/traefik:/etc/traefik'
        - '/home/container-user/docker/traefik/certs:/certs'
        - '/home/container-user/docker/dynamic:/dynamic'
        - '/home/container-user/docker/shared:/shared'
    watchtower:
      container_name: watchtower
      depends_on:
        - socket-proxy
      deploy:
        mode: replicated
        placement:
          constraints:
            - node.labels.traefik-enabled == true
        replicas: 1
      env_file:
        - watchtower/watchtower.env
      image: 'containrrr/watchtower:latest'
      networks:
        - net
        - socket_proxy
      restart: unless-stopped
    whoami:
      container_name: whoami
      deploy:
        mode: global
        restart_policy:
          condition: on-failure
          delay: 10s
          max_attempts: 3
          window: 120s
        update_config:
          delay: 10s
          order: start-first
          parallelism: 1
      image: containous/whoami
      labels:
        - traefik.enable=true
        - traefik.http.routers.whoami.entrypoints=https
        - >-
          traefik.http.routers.whoami.rule=Host(`whoami.admin.dettonville.cloud`)
          || Host(`whoami.admin.dettonville.int`)
        - traefik.http.services.whoami.loadbalancer.server.port=80
      networks:
        - traefik_public
      ports:
        - protocol: tcp
          published: 9080
          target: 80
  gitea:
    gitea:
      container_name: gitea
      depends_on:
        - postgres
      deploy:
        mode: replicated
        placement:
          constraints:
            - node.role == manager
        replicas: 1
        restart_policy:
          condition: on-failure
          delay: 40s
          max_attempts: 3
          window: 120s
        update_config:
          delay: 10s
          order: stop-first
          parallelism: 1
      env_file:
        - gitea/gitea.env
      healthcheck:
        interval: 30s
        retries: 3
        start_period: 280s
        test:
          - CMD
          - curl
          - '-f'
          - 'http://localhost:3000/api/healthz'
        timeout: 10s
      image: 'gitea/gitea:1.26'
      labels:
        - traefik.enable=true
        - traefik.http.routers.gitea.entrypoints=https
        - traefik.http.routers.gitea.rule=Host(`gitea.admin.dettonville.int`)
        - traefik.http.routers.gitea.service=gitea-svc
        - traefik.http.services.gitea-svc.loadbalancer.server.port=3000
      networks:
        - traefik_public
        - net
      ports:
        - mode: host
          protocol: tcp
          published: 3080
          target: 3000
        - mode: host
          protocol: tcp
          published: 2222
          target: 22
      restart: unless-stopped
      volumes:
        - '/home/container-user/docker/gitea/data:/data'
        - >-
          /etc/ssl/certs/ca-certificates.crt:/etc/ssl/certs/ca-certificates.crt:ro
        - '/etc/timezone:/etc/timezone:ro'
        - '/etc/localtime:/etc/localtime:ro'
  healthchecks:
    healthchecks:
      container_name: healthchecks
      env_file:
        - healthchecks/healthchecks.env
      image: ghcr.io/linuxserver/healthchecks
      labels:
        - traefik.enable=true
        - traefik.http.routers.healthchecks.entrypoints=https
        - >-
          traefik.http.routers.healthchecks.rule=Host(`healthchecks.admin.dettonville.int`)
        - traefik.http.routers.healthchecks.service=healthchecks-svc
        - traefik.http.services.healthchecks-svc.loadbalancer.server.port=8000
      networks:
        - traefik_public
      ports:
        - '8000:8000'
      restart: unless-stopped
      volumes:
        - '/home/container-user/docker/healthchecks:/config'
  keycloak:
    keycloak:
      container_name: keycloak
      depends_on:
        - postgres
      deploy:
        mode: replicated
        placement:
          constraints:
            - node.role == manager
        replicas: 1
        restart_policy:
          condition: on-failure
          delay: 60s
          max_attempts: 3
          window: 120s
        update_config:
          delay: 60s
          order: stop-first
          parallelism: 1
      env_file:
        - keycloak/keycloak.env
      healthcheck:
        interval: 5s
        retries: 15
        start_period: 240s
        test:
          - CMD
          - curl
          - '-f'
          - 'http://localhost:8080/auth/'
        timeout: 2s
      image: 'quay.io/keycloak/keycloak:11.0.3'
      labels:
        - traefik.enable=true
        - traefik.http.routers.keycloak.entrypoints=https
        - >-
          traefik.http.routers.keycloak.rule=Host(`auth.admin.dettonville.cloud`)
          || Host(`auth.admin.dettonville.int`)
        - traefik.http.routers.keycloak_insecure.entrypoints=http
        - >-
          traefik.http.routers.keycloak_insecure.rule=Host(`auth.admin.dettonville.int`)
        - traefik.http.routers.keycloak_insecure.middlewares=https-only@file
        - traefik.http.services.keycloak.loadbalancer.server.port=8080
      links:
        - postgres
      networks:
        - traefik_public
        - net
      ports:
        - '8081:8080'
      restart: unless-stopped
      volumes:
        - >-
          /home/container-user/docker/keycloak/themes:/opt/jboss/keycloak/themes/custome/:rw
        - 'keycloak_data:/data'
  llm_agent:
    crewai-workers:
      command: python worker_daemon.py
      container_name: crewai-workers
      deploy:
        mode: replicated
        replicas: 1
      env_file:
        - /home/container-user/docker/agent_stack/llm_agent.env
      image: 'python:3.11-slim'
      networks:
        - traefik_public
      restart: unless-stopped
      user: '1102:1102'
      volumes:
        - '/etc/localtime:/etc/localtime:ro'
        - '/home/container-user/docker/agent_stack/workers:/app'
      working_dir: /app
    langgraph-router:
      command: 'python -m uvicorn main:app --host 0.0.0.0 --port 8000'
      container_name: langgraph-router
      deploy:
        mode: replicated
        replicas: 1
      env_file:
        - /home/container-user/docker/agent_stack/llm_agent.env
      image: 'python:3.11-slim'
      labels:
        - traefik.enable=true
        - traefik.docker.network=traefik_public
        - >-
          traefik.http.routers.llm_agent.rule=Host(`orchestrator.admin.dettonville.int`)
        - traefik.http.routers.llm_agent.entrypoints=https
        - traefik.http.routers.llm_agent.tls=true
        - traefik.http.services.llm_agent.loadbalancer.server.port=8000
        - traefik.http.services.llm_agent.loadbalancer.server.scheme=http
      networks:
        - traefik_public
      restart: unless-stopped
      user: '1102:1102'
      volumes:
        - '/etc/localtime:/etc/localtime:ro'
        - '/home/container-user/docker/agent_stack/router:/app'
      working_dir: /app
  openbao:
    openbao:
      cap_add:
        - IPC_LOCK
      container_name: openbao
      deploy:
        mode: replicated
        restart_policy:
          condition: on-failure
          max_attempts: 3
        update_config:
          delay: 10s
          order: stop-first
          parallelism: 1
      env_file:
        - openbao/openbao.env
      healthcheck:
        interval: 10s
        retries: 10
        start_period: 30s
        test:
          - CMD-SHELL
          - openbao_info --is-vault-ready
        timeout: 10s
      image: 'lj020326/openbao-ansible:2.3.2'
      labels:
        - traefik.enable=true
        - traefik.http.routers.openbao.entrypoints=https
        - traefik.http.routers.openbao.rule=Host(`vault.admin.dettonville.int`)
        - traefik.http.routers.openbao.service=openbao-svc
        - traefik.http.services.openbao-svc.loadbalancer.server.port=8200
        - traefik.http.services.openbao-svc.loadbalancer.server.scheme=http
        - >-
          traefik.http.middlewares.openbao-forwarded-headers.headers.customrequestheaders.X-Forwarded-Proto=https
        - >-
          traefik.http.middlewares.openbao-forwarded-headers.headers.customrequestheaders.X-Forwarded-Host=vault.admin.dettonville.int
      networks:
        - traefik_public
        - net
      ports:
        - '8200:8200'
      restart: unless-stopped
      secrets:
        - ansible_vault_password
      user: '1102:1102'
      volumes:
        - '/etc/timezone:/etc/timezone:ro'
        - '/etc/localtime:/etc/localtime:ro'
        - '/home/container-user/docker/openbao/passwd:/etc/passwd:ro'
        - '/home/container-user/docker/openbao/group:/etc/group:ro'
        - '/home/container-user/docker/openbao/home:/vault'
  openldap:
    ldapadmin:
      container_name: ldapadmin
      depends_on:
        - openldap
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
        - openldap/ldapadmin.env
      image: 'wheelybird/ldap-user-manager:v1.5'
      labels:
        - traefik.enable=true
        - traefik.http.routers.ldapadmin.entrypoints=https
        - >-
          traefik.http.routers.ldapadmin.rule=Host(`ldapadmin.admin.dettonville.int`)
        - traefik.http.services.ldapadmin.loadbalancer.server.port=80
      networks:
        - net
        - traefik_public
      ports:
        - '18081:80'
      restart: unless-stopped
    openldap:
      command: '--copy-service --loglevel debug'
      container_name: openldap
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
          order: stop-first
          parallelism: 1
      env_file:
        - openldap/openldap.env
      image: 'osixia/openldap:1.5.0'
      networks:
        - net
      ports:
        - '389:389'
        - '636:636'
      restart: unless-stopped
      volumes:
        - '/home/container-user/docker/openldap/slapd/database:/var/lib/ldap'
        - '/home/container-user/docker/openldap/slapd/config:/etc/ldap/slapd.d'
        - >-
          /home/container-user/docker/openldap/slapd/certs:/container/service/slapd/assets/certs
        - >-
          /home/container-user/docker/openldap/ldif:/container/service/slapd/assets/config/bootstrap/ldif/custom
        - >-
          /home/container-user/docker/openldap/environment:/container/environment/01-custom
        - >-
          /home/container-user/docker/openldap/schema:/container/service/slapd/assets/config/bootstrap/schema
    phpldapadmin:
      container_name: phpldapadmin
      depends_on:
        - openldap
      deploy:
        mode: replicated
        replicas: 1
        restart_policy:
          condition: on-failure
          delay: 10s
          max_attempts: 3
          window: 120s
      environment:
        PHPLDAPADMIN_HTTPS: 'false'
        PHPLDAPADMIN_LDAP_HOSTS: openldap
      image: 'osixia/phpldapadmin:latest'
      labels:
        - traefik.enable=true
        - traefik.http.routers.phpldapadmin.entrypoints=https
        - >-
          traefik.http.routers.phpldapadmin.rule=Host(`phpldapadmin.admin.dettonville.int`)
        - traefik.http.services.phpldapadmin.loadbalancer.server.port=80
      networks:
        - traefik_public
        - net
      ports:
        - '18080:80'
      restart: unless-stopped
  postgres:
    pgadmin:
      container_name: pgadmin
      depends_on:
        - postgres
      deploy:
        mode: replicated
        replicas: 1
        restart_policy:
          condition: on-failure
          delay: 10s
          max_attempts: 3
          window: 20s
        update_config:
          delay: 10s
      env_file:
        - pgadmin/pgadmin.env
      image: 'dpage/pgadmin4:latest'
      labels:
        - traefik.enable=true
        - traefik.http.routers.pgadmin.entrypoints=https
        - >-
          traefik.http.routers.pgadmin.rule=Host(`pgadmin.admin.dettonville.int`)
        - traefik.http.routers.pgadmin_insecure.entrypoints=http
        - >-
          traefik.http.routers.pgadmin_insecure.rule=Host(`pgadmin.admin.dettonville.int`)
        - traefik.http.routers.pgadmin_insecure.middlewares=https-only@file
        - traefik.http.services.pgadmin.loadbalancer.server.port=80
      links:
        - postgres
      networks:
        - traefik_public
        - net
      ports:
        - '5050:80'
      restart: unless-stopped
      user: '1102:1102'
      volumes:
        - '/home/container-user/docker/pgadmin/passwd:/etc/passwd:ro'
        - '/home/container-user/docker/pgadmin/group:/etc/group:ro'
        - '/home/container-user/docker/pgadmin/data:/var/lib/pgadmin'
        - '/home/container-user/docker/pgadmin/log/pgadmin:/var/log/pgadmin'
    postgres:
      container_name: postgres
      deploy:
        mode: replicated
        placement:
          constraints:
            - node.role == manager
        replicas: 1
        restart_policy:
          condition: on-failure
          delay: 30s
          max_attempts: 3
          window: 120s
        update_config:
          delay: 10s
          order: stop-first
          parallelism: 1
      env_file:
        - postgres/postgres.env
      healthcheck:
        interval: 30s
        retries: 5
        start_period: 180s
        test:
          - CMD-SHELL
          - pg_isready -U postgres
        timeout: 10s
      image: 'postgres:11'
      networks:
        - net
      ports:
        - mode: host
          protocol: tcp
          published: 5432
          target: 5432
      restart: unless-stopped
      user: '1102:1102'
      volumes:
        - '/home/container-user/docker/postgres/passwd:/etc/passwd:ro'
        - '/home/container-user/docker/postgres/group:/etc/group:ro'
        - >-
          /home/container-user/docker/postgres/multiple-dbs:/docker-entrypoint-initdb.d
        - '/home/container-user/docker/postgres/config:/config'
        - '/home/container-user/docker/postgres/data:/var/lib/postgresql/data'
  redis:
    redis:
      container_name: redis
      entrypoint: |-
        redis-server 
          --appendonly yes 
          --requirepass ev9v0emv0rjf 
          --maxmemory 512mb 
          --maxmemory-policy
          noeviction
      environment:
        PGID: '1102'
        PUID: '1102'
        TZ: America/New_York
      image: 'redis:6.2.14'
      networks:
        - net
      restart: unless-stopped
      security_opt:
        - no-new-privileges=true
      volumes:
        - '/home/container-user/docker/redis:/data'
    rediscom:
      container_name: rediscom
      depends_on:
        - redis
      deploy:
        mode: replicated
        replicas: 1
        restart_policy:
          condition: on-failure
          delay: 10s
          max_attempts: 3
          window: 120s
      env_file:
        - redis/rediscom.env
      image: 'ghcr.io/joeferner/redis-commander:latest'
      labels:
        - traefik.enable=true
        - traefik.http.routers.rediscom.entrypoints=https
        - >-
          traefik.http.routers.rediscom.rule=Host(`rediscom.admin.dettonville.int`)
        - traefik.http.services.rediscom.loadbalancer.server.port=8081
      networks:
        - net
        - traefik_public
      restart: unless-stopped
      security_opt:
        - no-new-privileges=true
  registry:
    registry:
      container_name: registry
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
        - docker-registry/registry.env
      image: 'registry:2.8.2'
      networks:
        - net
      ports:
        - '5000:5000'
      restart: unless-stopped
      volumes:
        - '/data/docker_registry:/var/lib/registry'
        - '/home/container-user/docker/docker-registry/config/certs:/certs'
        - '/home/container-user/docker/docker-registry/config/files/auth:/auth'
        - >-
          /home/container-user/docker/docker-registry/config/config.yml:/etc/docker/registry/config.yml:ro
    registry-ui:
      container_name: registry-ui
      depends_on:
        - registry
      deploy:
        mode: replicated
        replicas: 1
        restart_policy:
          condition: on-failure
          delay: 10s
          max_attempts: 3
          window: 120s
      env_file:
        - docker-registry/registry-ui.env
      image: 'joxit/docker-registry-ui:2.5.7'
      labels:
        - traefik.enable=true
        - traefik.http.routers.registryfe-rtr.entrypoints=https
        - >-
          traefik.http.routers.registryfe-rtr.rule=Host(`registry.admin.dettonville.int`)
        - traefik.http.routers.registryfe-rtr.service=registryfe-svc
        - traefik.http.services.registryfe-svc.loadbalancer.server.port=80
        - traefik.http.services.registryfe-svc.loadbalancer.server.scheme=http
      links:
        - 'registry:registry'
      networks:
        - traefik_public
        - net
      restart: unless-stopped
      volumes:
        - >-
          /home/container-user/docker/docker-registry/config/certs/admin.dettonville.int.chain.pem:/etc/apache2/server.crt:ro
        - >-
          /home/container-user/docker/docker-registry/config/certs/admin.dettonville.int-key.pem:/etc/apache2/server.key:ro
  samba:
    samba:
      container_name: samba
      depends_on:
        - openldap
      deploy:
        mode: replicated
        placement:
          constraints:
            - node.role == manager
        replicas: 1
        restart_policy:
          condition: on-failure
          delay: 30s
          max_attempts: 3
          window: 120s
        update_config:
          delay: 10s
          order: stop-first
          parallelism: 1
      env_file:
        - samba/samba.env
      image: 'andrespp/samba-ldap:latest'
      networks:
        - net
        - traefik_public
      ports:
        - '139:139'
        - '445:445'
      restart: unless-stopped
      volumes:
        - '/etc/localtime:/etc/localtime:ro'
        - >-
          /home/container-user/docker/samba/libnss-ldap.conf:/etc/libnss-ldap.conf:ro
        - '/home/container-user/docker/samba/smb.conf:/etc/samba/smb.conf:ro'
        - >-
          /home/container-user/docker/samba/smbldap.conf:/etc/smbldap-tools/smbldap.conf:ro
        - >-
          /home/container-user/docker/samba/smbldap_bind.conf:/etc/smbldap-tools/smbldap_bind.conf:ro
        - '/data:/data'
  vikunja:
    vikunja:
      container_name: vikunja
      depends_on:
        vikunja-db:
          condition: service_healthy
      deploy:
        placement:
          constraints:
            - node.role == manager
      env_file:
        - vikunja/vikunja.env
      image: 'vikunja/vikunja:latest'
      labels:
        - traefik.enable=true
        - traefik.docker.network=traefik_public
        - traefik.http.routers.vikunja.rule=Host(`kanban.admin.dettonville.int`)
        - traefik.http.routers.vikunja.entrypoints=https
        - traefik.http.routers.vikunja.tls=true
        - traefik.http.services.vikunja.loadbalancer.server.port=3456
        - traefik.http.services.vikunja.loadbalancer.server.scheme=http
      networks:
        - traefik_public
        - net
      restart: unless-stopped
      user: '1102:1102'
      volumes:
        - '/home/container-user/docker/vikunja/files:/app/vikunja/files'
        - >-
          /home/container-user/docker/vikunja/config.yml:/etc/vikunja/config.yml:ro
    vikunja-db:
      container_name: vikunja-db
      env_file:
        - vikunja/postgres.env
      healthcheck:
        interval: 10s
        test:
          - CMD-SHELL
          - pg_isready -U vikunja
      image: 'postgres:16-alpine'
      networks:
        - net
      restart: unless-stopped
      user: '1102:1102'
      volumes:
        - '/home/container-user/docker/vikunja/db:/var/lib/postgresql/data'

```

## Template

Set up the template section (note replacement of filters with standard filters in the template):
```jinja
{{ 'Ansible managed' | comment(format="# {}") }}
{% macro render_service_option(key, container, swarm_mode, filter_type='scalar', indent=4) %}
  {%- set swarm_restricted_keys = ['container_name', 'network_mode', 'restart', 'privileged', 'security_opt', 'links', 'labels', 'secrets'] %}
  {%- if not (swarm_mode | bool and key in swarm_restricted_keys) %}
    {%- if container[key] is defined %}
      {%- set padding = " " * indent %}
{{ "\n" }}{{ padding }}{{ key }}:
      {%- if filter_type == 'scalar' %} {{ container[key] }}
      {%- elif filter_type == 'list_loop' %}
        {%- for item in container[key] %}
{{ "\n" }}{{ padding }}  - {{ item }}
        {%- endfor %}
      {%- elif filter_type == 'yaml' %}
{{ "\n" }}{{ padding }}  {{ container[key]
    | to_nice_yaml
    | indent(indent + 2, first=True) | trim }}
      {%- elif filter_type == 'command' %}
        {%- if container[key] is not string and container[key] is not mapping and container[key] is iterable %}
{{ "\n" }}{{ padding }}  {{ container[key]
    | to_nice_yaml
    | indent(indent + 2, first=True) | trim }}
        {%- else %} >-
{{ padding }}  {{ container[key] | indent(indent + 2, first=True) | trim }}
        {%- endif %}
      {%- endif %}
    {%- endif %}
  {%- endif %}
{% endmacro %}

{% if __docker_stack__networks | d({}) | length > 0 %}

networks:
  {%- for _network_key, _network_config in __docker_stack__networks.items() %}
{{ "\n" }}  {{ _network_key }}:
    {%- if _network_config.external | d(False) | bool %}
{{ "\n" }}    external: true
    {%- else %}
      {%- if docker_stack__swarm_mode | d(False) | bool %}
{{ "\n" }}    {{ _network_config
      | ansible.utils.remove_keys(target=['ipam_config','scope'])
      | to_nice_yaml
      | indent(4, first=False) | trim }}
      {%- else %}
{{ "\n" }}    {{ _network_config
      | ansible.utils.remove_keys(target=['driver','ipam_config','scope'])
      | to_nice_yaml
      | indent(4, first=False) | trim }}
      {%- endif %}
    {%- endif %}
  {%- endfor %}

{% endif %}

{%- if __docker_stack__volumes | d({}) | length > 0 %}

volumes:
  {{ __docker_stack__volumes | to_nice_yaml | indent(2, first=False) | trim }}
{% endif %}

{%- if docker_stack__swarm_mode | d(False) | bool %}
  {%- if __docker_stack__secrets | d({}) | length > 0 %}

secrets:
    {%- for _secret_name in __docker_stack__secrets.keys() | sort %}
{{ "\n" }}  {{ _secret_name }}:
    external: true
    {%- endfor %}
  {%- endif %}

{% endif %}

{%- if docker_stack__configs | d({}) | length > 0 %}

configs:
  {{ docker_stack__configs | to_nice_yaml | indent(2, first=False) | trim }}

{%- endif %}

services:
{% for service_group in __docker_stack__service_groups | sort(attribute='name') %}
  {%- if __docker_stack__service_group_configs_tpl[service_group.name] | d([]) | length > 0 %}
  ########################
  ## {{ service_group.name | upper }} GROUP SERVICES
    {%- for key, container in __docker_stack__service_group_configs_tpl[service_group.name].items() %}
      {%- if (container.active | d(True)) %}
      {%- if not loop.first %}
{{ "\n" }}
      {%- endif %}
{{ "\n" }}  {{ container.service_name if container.service_name is defined else key }}:
    image: {{ container.image }}
    {{- render_service_option("container_name", container, docker_stack__swarm_mode) }}
    {{- render_service_option("network_mode", container, docker_stack__swarm_mode) }}
    {{- render_service_option("restart", container, docker_stack__swarm_mode) }}
    {{- render_service_option("privileged", container, docker_stack__swarm_mode) }}
    {{- render_service_option("security_opt", container, docker_stack__swarm_mode, filter_type='yaml') }}
    {{- render_service_option("mem_limit", container, docker_stack__swarm_mode) }}
    {{- render_service_option("hostname", container, docker_stack__swarm_mode) }}
    {{- render_service_option("extra_hosts", container, docker_stack__swarm_mode, filter_type='yaml') }}
    {{- render_service_option("shm_size", container, docker_stack__swarm_mode) }}
    {{- render_service_option("user", container, docker_stack__swarm_mode) }}
    {{- render_service_option("cap_add", container, docker_stack__swarm_mode, filter_type='yaml') }}
    {{- render_service_option("devices", container, docker_stack__swarm_mode, filter_type='yaml') }}
    {{- render_service_option("depends_on", container, docker_stack__swarm_mode, filter_type='list_loop') }}
    {{- render_service_option("links", container, docker_stack__swarm_mode, filter_type='list_loop') }}
    {{- render_service_option("networks", container, docker_stack__swarm_mode, filter_type='yaml') }}
    {{- render_service_option("ports", container, docker_stack__swarm_mode, filter_type='yaml') }}
    {{- render_service_option("environment", container, docker_stack__swarm_mode, filter_type='yaml') }}
    {{- render_service_option("env_file", container, docker_stack__swarm_mode, filter_type='yaml') }}
    {{- render_service_option("healthcheck", container, docker_stack__swarm_mode, filter_type='yaml') }}
    {{- render_service_option("command", container, docker_stack__swarm_mode, filter_type='command') }}
    {{- render_service_option("entrypoint", container, docker_stack__swarm_mode, filter_type='command') }}
    {{- render_service_option("dns", container, docker_stack__swarm_mode, filter_type='yaml') }}
    {{- render_service_option("secrets", container, not docker_stack__swarm_mode, filter_type='yaml') }}
    {{- render_service_option("labels", container, docker_stack__swarm_mode, filter_type='yaml') }}

        {#- Handle complex deploy block conditional fallback separately #}
        {%- set _deploy_config = {} %}
        {%- if container.deploy is defined %}
            {%- if docker_stack__swarm_mode | d(False) | bool %}
                {%- set _deploy_config = container.deploy %}
            {%- else %}
                {%- set _deploy_config = container.deploy | ansible.utils.keep_keys(['resources']) %}
            {%- endif %}
        {%- endif %}
        {%- if docker_stack__swarm_mode | d(False) | bool %}
            {%- if container.labels is defined %}
                {%- set _ = _deploy_config.update({ 'labels': container.labels }) %}
            {%- endif %}
        {%- endif %}
        {%- if _deploy_config.keys() | length > 0 %}
{{ "\n" }}    deploy:
      {{ _deploy_config | to_nice_yaml | indent(6, first=False) | trim }}
        {%- endif %}

    {{- render_service_option("volumes", container, false, filter_type='yaml') }}
      {%- endif %}
    {%- endfor %}
  {%- endif %}
{{ "\n" }}
{% endfor %}

```
