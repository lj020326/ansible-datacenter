
# How to test enhancements to the docker-compose.yml.j2 template

Use the site https://ansible.sivel.net/test/ to test.

## Set up test variables

Convert the ansible logged variable values and convert from json to yaml at: 
https://jsonformatter.org/json-to-yaml

Set up the variables section:
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

## keys only for testing purposes
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
        - >-
          traefik.http.routers.portainer-rtr.rule=Host(`portainer.media.johnson.int`)
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
          traefik.http.routers.ping.rule=Host(`traefik.media.johnson.int`) &&
          PathPrefix(`/ping`)
        - traefik.http.routers.ping.service=ping@internal
        - traefik.http.routers.traefik-rtr.service=api@internal
        - traefik.http.routers.traefik-rtr.entrypoints=https
        - >-
          traefik.http.routers.traefik-rtr.rule=Host(`traefik.media.johnson.int`)
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
        - '/home/media/docker/traefik:/etc/traefik'
        - '/home/media/docker/traefik/certs:/certs'
        - '/home/media/docker/dynamic:/dynamic'
        - '/home/media/docker/shared:/shared'
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
          traefik.http.routers.whoami.rule=Host(`whoami.media.dettonville.cloud`)
          || Host(`whoami.media.johnson.int`)
        - traefik.http.services.whoami.loadbalancer.server.port=80
      networks:
        - traefik_public
      ports:
        - protocol: tcp
          published: 9080
          target: 80
  gluetun:
    openvpn:
      cap_add:
        - net_admin
      container_name: openvpn
      devices:
        - '/dev/net/tun:/dev/net/tun'
      env_file:
        - gluetun/gluetun.env
      image: 'lj020326/gluetun:latest'
      networks:
        - traefik_public
      ports:
        - '8168:8168'
        - '8888:8888/tcp'
        - '8388:8388/tcp'
        - '8388:8388/udp'
      restart: unless-stopped
      volumes:
        - '/home/media/docker/gluetun/config:/gluetun'
  media:
    airsonic:
      active: false
      container_name: airsonic
      environment:
        JAVA_OPTS: '-Dserver.use-forward-headers=true'
        PGID: '895'
        PUID: '1003'
      image: 'lscr.io/linuxserver/airsonic:latest'
      labels:
        - traefik.enable=true
        - traefik.http.routers.airsonic-rtr.entrypoints=https
        - >-
          traefik.http.routers.airsonic-rtr.rule=Host(`airsonic.media.johnson.int`)
        - traefik.http.routers.airsonic-rtr.middlewares=chain-no-auth@file
        - traefik.http.routers.airsonic-rtr.service=airsonic-svc
        - traefik.http.services.airsonic-svc.loadbalancer.server.port=4040
      networks:
        - traefik_public
      restart: unless-stopped
      security_opt:
        - no-new-privileges=true
      volumes:
        - '/srv/media/music:/music'
        - '/home/media/docker/airsonic/config:/config'
        - '/home/media/docker/airsonic/podcasts:/podcasts'
        - '/home/media/docker/airsonic/playlists:/playlists'
        - '/home/media/docker/shared:/shared'
        - '/etc/timezone:/etc/timezone:ro'
        - '/etc/localtime:/etc/localtime:ro'
    bazarr:
      container_name: bazarr
      environment:
        PGID: '895'
        PUID: '1003'
        TZ: America/New_York
      image: 'lscr.io/linuxserver/bazarr:latest'
      labels:
        - traefik.enable=true
        - traefik.http.routers.bazarr.entrypoints=https
        - traefik.http.routers.bazarr.rule=Host(`bazarr.media.johnson.int`)
        - traefik.http.routers.lidarr_insecure.entrypoints=http
        - >-
          traefik.http.routers.lidarr_insecure.rule=Host(`bazarr.media.johnson.int`)
        - traefik.http.routers.lidarr_insecure.middlewares=https-only@file
        - traefik.http.services.bazarr.loadbalancer.server.port=6767
      networks:
        - traefik_public
      restart: unless-stopped
      security_opt:
        - no-new-privileges=true
      volumes:
        - '/srv/media:/nas'
        - '/home/media/docker/bazarr:/config'
        - '/home/media/docker/shared:/shared'
        - >-
          /etc/ssl/certs/ca-certificates.crt:/etc/ssl/certs/ca-certificates.crt:ro
    calibre:
      container_name: calibre
      depends_on:
        - openvpn
      devices:
        - '/dev/dri:/dev/dri'
      environment:
        DRINODE: /dev/dri/renderD128
        DRI_NODE: /dev/dri/renderD128
        NO_GAMEPAD: true
        PGID: '895'
        PIXELFLUX_WAYLAND: true
        PUID: '1003'
        TZ: America/New_York
        UMASK_SET: '002'
      image: 'lscr.io/linuxserver/calibre:latest'
      labels:
        - traefik.enable=true
        - traefik.http.routers.calibre-rtr.entrypoints=https
        - >-
          traefik.http.routers.calibre-rtr.rule=Host(`calibre.media.johnson.int`)
        - traefik.http.routers.calibre-rtr.middlewares=chain-no-auth@file
        - traefik.http.routers.calibre-rtr.service=calibre-svc
        - traefik.http.services.calibre-svc.loadbalancer.server.port=8080
      network_mode: 'service:openvpn'
      restart: unless-stopped
      security_opt:
        - seccomp=unconfined
      volumes:
        - '/home/media/docker/calibre:/config'
        - '/srv/media/books:/books'
        - '/export/media/downloads:/downloads'
    calibre-web:
      container_name: calibre-web
      depends_on:
        - openvpn
      environment:
        DOCKER_MODS: 'lscr.io/linuxserver/calibre-web:calibre'
        PGID: '895'
        PUID: '1003'
        TZ: America/New_York
        UMASK: '002'
      image: 'lscr.io/linuxserver/calibre-web:latest'
      labels:
        - traefik.enable=true
        - traefik.http.routers.calibre-web-rtr.entrypoints=https
        - >-
          traefik.http.routers.calibre-web-rtr.rule=Host(`calweb.media.johnson.int`)
        - traefik.http.routers.calibre-web-rtr.middlewares=chain-no-auth@file
        - traefik.http.routers.calibre-web-rtr.service=calibre-web-svc
        - traefik.http.services.calibre-web-svc.loadbalancer.server.port=8083
      network_mode: 'service:openvpn'
      restart: unless-stopped
      security_opt:
        - no-new-privileges=true
      volumes:
        - '/home/media/docker/calibre-web:/config'
        - '/srv/media/books:/books'
        - '/home/media/docker/shared:/shared'
    dupeguru:
      container_name: dupeguru
      environment:
        GROUP_ID: '895'
        TZ: America/New_York
        UMASK: '002'
        USER_ID: '1003'
      image: 'jlesage/dupeguru:latest'
      labels:
        - traefik.enable=true
        - traefik.http.routers.dupeguru-rtr.entrypoints=https
        - >-
          traefik.http.routers.dupeguru-rtr.rule=Host(`dupeguru.media.johnson.int`)
        - traefik.http.routers.dupeguru-rtr.middlewares=chain-no-auth@file
        - traefik.http.routers.dupeguru-rtr.service=dupeguru-svc
        - traefik.http.services.dupeguru-svc.loadbalancer.server.port=5800
      networks:
        - traefik_public
      restart: unless-stopped
      security_opt:
        - no-new-privileges=true
      volumes:
        - '/etc/localtime:/etc/localtime:ro'
        - '/dev/shm:/dev/shm'
        - '/home/media/docker/dupeguru:/config'
        - '/export/media/downloads/wip_media:/wip_media'
        - '/srv/media/music/lidarr:/storage'
        - '/home/media/docker/shared:/shared'
        - >-
          /etc/ssl/certs/ca-certificates.crt:/etc/ssl/certs/ca-certificates.crt:ro
    duplicati:
      active: false
      container_name: duplicati
      environment:
        PGID: '895'
        PUID: '1003'
        TZ: America/New_York
      image: 'lscr.io/linuxserver/duplicati:latest'
      labels:
        - traefik.enable=true
        - traefik.http.routers.duplicati-rtr.entrypoints=https
        - >-
          traefik.http.routers.duplicati-rtr.rule=Host(`duplicati.media.johnson.int`)
        - traefik.http.routers.duplicati-rtr.service=duplicati-svc
        - traefik.http.routers.duplicati-rtr.middlewares=chain-no-auth@file
        - traefik.http.services.duplicati-svc.loadbalancer.server.port=8200
      networks:
        - traefik_public
      restart: unless-stopped
      security_opt:
        - no-new-privileges=true
      volumes:
        - '/home/media/docker/duplicati:/config'
        - '/srv/media:/nas'
        - '/home/media/docker/shared:/userdir'
    embyms:
      active: false
      container_name: embyms
      devices:
        - '/dev/dri:/dev/dri'
      environment:
        GID: '895'
        HOSTNAME: emby
        TZ: America/New_York
        UID: '1003'
      image: 'emby/embyserver:latest'
      labels:
        - traefik.enable=true
        - traefik.http.routers.embyms-rtr.entrypoints=https
        - traefik.http.routers.embyms-rtr.rule=Host(`emby.media.johnson.int`)
        - traefik.http.routers.embyms-rtr.middlewares=chain-no-auth@file
        - traefik.http.routers.embyms-rtr.service=embyms-svc
        - traefik.http.services.embyms-svc.loadbalancer.server.port=8096
      networks:
        - traefik_public
      ports:
        - '8096:8096/tcp'
        - '8920:8920/tcp'
      restart: unless-stopped
      security_opt:
        - no-new-privileges=true
      volumes:
        - '/dev/shm:/transcode'
        - '/home/media/docker/embyms:/config'
        - '/srv/media:/nas'
        - '/export/media/downloads:/downloads'
    flaresolverr:
      container_name: flaresolverr
      depends_on:
        - openvpn
      environment:
        CAPTCHA_SOLVER: none
        LOG_HTML: 'false'
        LOG_LEVEL: info
        TZ: America/New_York
      image: 'ghcr.io/flaresolverr/flaresolverr:latest'
      labels:
        - traefik.enable=true
        - traefik.http.routers.flaresolverr.entrypoints=https
        - >-
          traefik.http.routers.flaresolverr.rule=Host(`flaresolverr.media.johnson.int`)
        - traefik.http.routers.flaresolverr_insecure.entrypoints=http
        - >-
          traefik.http.routers.flaresolverr_insecure.rule=Host(`flaresolverr.media.johnson.int`)
        - traefik.http.routers.flaresolverr_insecure.middlewares=https-only@file
        - traefik.http.services.flaresolverr.loadbalancer.server.port=8191
      network_mode: 'service:openvpn'
      restart: unless-stopped
    handbrake:
      active: false
      container_name: handbrake
      environment:
        AUTOMATED_CONVERSION_KEEP_SOURCE: 1
        CLEAN_TMP_DIR: 1
        DISPLAY_HEIGHT: 960
        DISPLAY_WIDTH: 1600
        GROUP_ID: '895'
        KEEP_APP_RUNNING: 1
        TZ: America/New_York
        UMASK: '002'
        USER_ID: '1003'
        VNC_PASSWORD: password
      image: 'jlesage/handbrake:latest'
      labels:
        - traefik.enable=true
        - traefik.http.routers.handbrake-rtr.entrypoints=https
        - >-
          traefik.http.routers.handbrake-rtr.rule=Host(`handbrake.media.johnson.int`)
        - traefik.http.routers.handbrake-rtr.service=handbrake-svc
        - traefik.http.services.handbrake-svc.loadbalancer.server.port=5800
      networks:
        - traefik_public
      restart: unless-stopped
      security_opt:
        - no-new-privileges=true
      volumes:
        - '/home/media/docker/handbrake/config:/config:rw'
        - '/home/media/docker/handbrake/watch:/watch:rw'
        - '/export/media/downloads:/downloads:ro'
        - '/export/media/handbrake/output:/output:rw'
    heimdall:
      container_name: heimdall
      environment:
        PGID: '895'
        PUID: '1003'
        TZ: America/New_York
      image: 'lscr.io/linuxserver/heimdall:latest'
      labels:
        - traefik.enable=true
        - traefik.http.routers.heimdall.entrypoints=https
        - >-
          traefik.http.routers.heimdall.rule=Host(`heimdall.media.dettonville.cloud`)
          || Host(`media.dettonville.cloud`)
        - traefik.http.routers.heimdall.middlewares=chain-oauth@file
      networks:
        - traefik_public
      restart: unless-stopped
      volumes:
        - '/home/media/docker/heimdall:/config'
        - '/home/media/docker/shared:/shared'
    heimdall-internal:
      container_name: heimdall-internal
      environment:
        PGID: '895'
        PUID: '1003'
        TZ: America/New_York
      image: 'lscr.io/linuxserver/heimdall:latest'
      labels:
        - traefik.enable=true
        - traefik.http.routers.heimdall_int.entrypoints=https
        - >-
          traefik.http.routers.heimdall_int.rule=Host(`heimdall.media.johnson.int`)
        - traefik.http.routers.heimdall_int.middlewares=chain-no-auth@file
      networks:
        - traefik_public
      restart: unless-stopped
      volumes:
        - '/home/media/docker/heimdall-int:/config'
        - '/home/media/docker/shared:/shared'
    hydra:
      active: false
      container_name: hydra
      environment:
        PGID: '895'
        PUID: '1003'
        TZ: America/New_York
      image: 'lscr.io/linuxserver/nzbhydra2:latest'
      labels:
        - traefik.enable=true
        - traefik.http.routers.hydra.entrypoints=https
        - traefik.http.routers.hydra.rule=Host(`hydra.media.johnson.int`)
        - traefik.http.routers.hydra_insecure.entrypoints=http
        - >-
          traefik.http.routers.hydra_insecure.rule=Host(`hydra.media.johnson.int`)
        - traefik.http.routers.hydra_insecure.middlewares=https-only@file
        - traefik.http.services.hydra.loadbalancer.server.port=5076
      networks:
        - traefik_public
      restart: unless-stopped
      volumes:
        - '/home/media/docker/hydra:/config'
        - '/export/media/downloads:/downloads'
        - '/home/media/docker/shared:/shared'
    jackett:
      container_name: jackett
      depends_on:
        - openvpn
      environment:
        PGID: '895'
        PUID: '1003'
        TZ: America/New_York
      image: 'lscr.io/linuxserver/jackett:latest'
      labels:
        - traefik.enable=true
        - traefik.http.routers.jackett.entrypoints=https
        - traefik.http.routers.jackett.rule=Host(`jackett.media.johnson.int`)
        - traefik.http.routers.jackett_insecure.entrypoints=http
        - >-
          traefik.http.routers.jackett_insecure.rule=Host(`jackett.media.johnson.int`)
        - traefik.http.routers.jackett_insecure.middlewares=https-only@file
        - traefik.http.services.jackett.loadbalancer.server.port=9117
      network_mode: 'service:openvpn'
      restart: unless-stopped
      volumes:
        - '/etc/localtime:/etc/localtime:ro'
        - '/home/media/docker/jackett:/config'
        - '/export/media/downloads/watch:/downloads'
        - '/home/media/docker/shared:/shared'
    jellyfin:
      active: false
      container_name: jellyfin
      devices:
        - '/dev/dri:/dev/dri'
      environment:
        PGID: '895'
        PUID: '1003'
        TZ: America/New_York
        UMASK_SET: '022'
      image: 'jellyfin/jellyfin:latest'
      labels:
        - traefik.enable=true
        - traefik.http.routers.jellyfin-rtr.entrypoints=https
        - traefik.http.routers.jellyfin-rtr.rule=Host(`jf.media.johnson.int`)
        - traefik.http.routers.jellyfin-rtr.middlewares=chain-no-auth@file
        - traefik.http.routers.jellyfin-rtr.service=jellyfin-svc
        - traefik.http.services.jellyfin-svc.loadbalancer.server.port=8096
      networks:
        - traefik_public
      ports:
        - '8196:8096'
        - '8921:8920'
      restart: unless-stopped
      security_opt:
        - no-new-privileges=true
      volumes:
        - '/dev/shm:/ram_transcode'
        - '/home/media/docker/jellyfin:/config'
        - '/srv/media:/nas'
    lazylibrarian:
      container_name: lazylibrarian
      depends_on:
        - openvpn
      environment:
        PGID: '895'
        PUID: '1003'
        TZ: America/New_York
      image: 'lscr.io/linuxserver/lazylibrarian:latest'
      labels:
        - traefik.enable=true
        - traefik.http.routers.lazylibrarian.entrypoints=https
        - >-
          traefik.http.routers.lazylibrarian.rule=Host(`lazylibrarian.media.johnson.int`)
        - traefik.http.routers.lazylibrarian_insecure.entrypoints=http
        - >-
          traefik.http.routers.lazylibrarian_insecure.rule=Host(`lazylibrarian.media.johnson.int`)
        - >-
          traefik.http.routers.lazylibrarian_insecure.middlewares=https-only@file
        - traefik.http.services.lazylibrarian.loadbalancer.server.port=5299
      network_mode: 'service:openvpn'
      restart: unless-stopped
      volumes:
        - '/home/media/docker/lazylibrarian:/config'
        - '/export/media/downloads:/downloads'
        - '/srv/media/books/lazylibrarian:/books'
        - '/home/media/docker/shared:/shared'
        - >-
          /etc/ssl/certs/ca-certificates.crt:/etc/ssl/certs/ca-certificates.crt:ro
    lidarr:
      container_name: lidarr
      depends_on:
        - openvpn
      environment:
        PGID: '895'
        PUID: '1003'
        TZ: America/New_York
      image: 'lscr.io/linuxserver/lidarr:latest'
      labels:
        - traefik.enable=true
        - traefik.http.routers.lidarr.entrypoints=https
        - traefik.http.routers.lidarr.rule=Host(`lidarr.media.johnson.int`)
        - traefik.http.routers.lidarr_insecure.entrypoints=http
        - >-
          traefik.http.routers.lidarr_insecure.rule=Host(`lidarr.media.johnson.int`)
        - traefik.http.routers.lidarr_insecure.middlewares=https-only@file
        - traefik.http.services.lidarr.loadbalancer.server.port=8686
      network_mode: 'service:openvpn'
      restart: unless-stopped
      volumes:
        - '/home/media/docker/lidarr:/config'
        - '/export/media/downloads:/downloads'
        - '/srv/media/music/lidarr:/music'
        - '/home/media/docker/shared:/shared'
        - >-
          /etc/ssl/certs/ca-certificates.crt:/etc/ssl/certs/ca-certificates.crt:ro
    makemkv:
      active: false
      container_name: makemkv
      environment:
        GROUP_ID: '895'
        TZ: America/New_York
        USER_ID: '1003'
      hostname: makemkv
      image: 'jlesage/makemkv:latest'
      labels:
        - traefik.enable=true
        - traefik.http.routers.makemkv.entrypoints=https
        - traefik.http.routers.makemkv.rule=Host(`makemkv.media.johnson.int`)
        - traefik.http.services.makemkv.loadbalancer.server.port=5800
      networks:
        - traefik_public
      restart: unless-stopped
      volumes:
        - '/home/media/docker/makemkv:/config:rw'
        - '/export/media/downloads:/storage:ro'
        - '/export/media/makemkv/output:/output:rw'
    mkvtoolnix:
      active: false
      container_name: mkvtoolnix
      environment:
        CLEAN_TMP_DIR: 1
        DISPLAY_HEIGHT: 960
        DISPLAY_WIDTH: 1600
        GROUP_ID: '895'
        KEEP_APP_RUNNING: 1
        TZ: America/New_York
        UMASK: '002'
        USER_ID: '1003'
        VNC_PASSWORD: password
      image: 'jlesage/mkvtoolnix:latest'
      labels:
        - traefik.enable=true
        - traefik.http.routers.mkvtoolnix-rtr.entrypoints=https
        - >-
          traefik.http.routers.mkvtoolnix-rtr.rule=Host(`mkvtoolnix.media.johnson.int`)
        - traefik.http.routers.mkvtoolnix-rtr.service=mkvtoolnix-svc
        - traefik.http.services.mkvtoolnix-svc.loadbalancer.server.port=5800
      networks:
        - traefik_public
      restart: unless-stopped
      security_opt:
        - no-new-privileges=true
      volumes:
        - '/home/media/docker/mkvtoolnix/config:/config:rw'
        - '/export/media/downloads:/downloads:rw'
    photoprism:
      active: false
      image: photoprism/photoprism
    picard:
      container_name: picard
      environment:
        DISPLAY_HEIGHT: 960
        DISPLAY_WIDTH: 1600
        GROUP_ID: '895'
        TZ: America/New_York
        UMASK: '002'
        USER_ID: '1003'
      image: 'mikenye/picard:latest'
      labels:
        - traefik.enable=true
        - traefik.http.routers.picard-rtr.entrypoints=https
        - traefik.http.routers.picard-rtr.rule=Host(`picard.media.johnson.int`)
        - traefik.http.routers.picard-rtr.middlewares=chain-no-auth@file
        - traefik.http.routers.picard-rtr.service=picard-svc
        - traefik.http.services.picard-svc.loadbalancer.server.port=5800
      networks:
        - traefik_public
      restart: unless-stopped
      security_opt:
        - no-new-privileges=true
      volumes:
        - '/etc/localtime:/etc/localtime:ro'
        - '/dev/shm:/dev/shm'
        - '/home/media/docker/picard:/config'
        - '/export/media/downloads/wip_media:/wip_media'
        - '/srv/media/music/lidarr:/music'
        - '/srv/media/music/unmanaged:/music_various_artists'
        - '/home/media/docker/shared:/shared'
        - >-
          /etc/ssl/certs/ca-certificates.crt:/etc/ssl/certs/ca-certificates.crt:ro
    prowlarr:
      container_name: prowlarr
      depends_on:
        - openvpn
      environment:
        DOTNET_EnableIPv6: false
        DOTNET_SYSTEM_NET_DISABLEIPV6: true
        PGID: '895'
        PUID: '1003'
        TZ: America/New_York
      image: 'lscr.io/linuxserver/prowlarr:latest'
      labels:
        - traefik.enable=true
        - traefik.http.routers.prowlarr.entrypoints=https
        - traefik.http.routers.prowlarr.rule=Host(`prowlarr.media.johnson.int`)
        - traefik.http.routers.prowlarr_insecure.entrypoints=http
        - >-
          traefik.http.routers.prowlarr_insecure.rule=Host(`prowlarr.media.johnson.int`)
        - traefik.http.routers.prowlarr_insecure.middlewares=https-only@file
        - traefik.http.services.prowlarr.loadbalancer.server.port=9696
      network_mode: 'service:openvpn'
      restart: unless-stopped
      volumes:
        - '/etc/localtime:/etc/localtime:ro'
        - '/home/media/docker/prowlarr:/config'
        - '/export/media/downloads/watch:/downloads'
        - '/home/media/docker/shared:/shared'
        - >-
          /etc/ssl/certs/ca-certificates.crt:/etc/ssl/certs/ca-certificates.crt:ro
    qbittorrent:
      container_name: qbittorrent
      depends_on:
        - openvpn
      environment:
        PGID: '895'
        PUID: '1003'
        TZ: America/New_York
        WEBUI_PORT: 8168
      image: 'ghcr.io/linuxserver/qbittorrent:latest'
      labels:
        - traefik.enable=true
        - traefik.http.routers.qbittorrent.entrypoints=https
        - >-
          traefik.http.routers.qbittorrent.rule=Host(`qbittorrent.media.johnson.int`)
        - traefik.http.services.qbittorrent.loadbalancer.server.port=8168
      network_mode: 'service:openvpn'
      restart: always
      volumes:
        - '/home/media/docker/qbittorrent:/config'
        - '/export/media/downloads:/downloads'
    radarr:
      container_name: radarr
      depends_on:
        - openvpn
      environment:
        PGID: '895'
        PUID: '1003'
        TZ: America/New_York
      image: 'lscr.io/linuxserver/radarr:latest'
      labels:
        - traefik.enable=true
        - traefik.http.routers.radarr.entrypoints=https
        - traefik.http.routers.radarr.rule=Host(`radarr.media.johnson.int`)
        - traefik.http.routers.radarr_insecure.entrypoints=http
        - >-
          traefik.http.routers.radarr_insecure.rule=Host(`radarr.media.johnson.int`)
        - traefik.http.routers.radarr_insecure.middlewares=https-only@file
        - traefik.http.services.radarr.loadbalancer.server.port=7878
      network_mode: 'service:openvpn'
      restart: unless-stopped
      volumes:
        - '/home/media/docker/radarr:/config'
        - '/export/media/downloads:/downloads'
        - '/srv/media/movies:/movies'
        - '/home/media/docker/shared:/shared'
        - >-
          /etc/ssl/certs/ca-certificates.crt:/etc/ssl/certs/ca-certificates.crt:ro
    readarr:
      container_name: readarr
      depends_on:
        - openvpn
        - reading-glasses
      environment:
        DOTNET_EnableIPv6: false
        DOTNET_SYSTEM_NET_DISABLEIPV6: true
        PGID: '895'
        PUID: '1003'
        TZ: America/New_York
      image: 'ghcr.io/pennydreadful/bookshelf:hardcover'
      labels:
        - traefik.enable=true
        - traefik.http.routers.readarr.entrypoints=https
        - traefik.http.routers.readarr.rule=Host(`readarr.media.johnson.int`)
        - traefik.http.routers.readarr_insecure.entrypoints=http
        - >-
          traefik.http.routers.readarr_insecure.rule=Host(`readarr.media.johnson.int`)
        - traefik.http.routers.readarr_insecure.middlewares=https-only@file
        - traefik.http.services.readarr.loadbalancer.server.port=8787
      network_mode: 'service:openvpn'
      restart: unless-stopped
      volumes:
        - '/home/media/docker/readarr:/config'
        - '/export/media/downloads:/downloads'
        - '/srv/media/books:/books'
        - '/home/media/docker/shared:/shared'
        - >-
          /etc/ssl/certs/ca-certificates.crt:/etc/ssl/certs/ca-certificates.crt:ro
    reading-glasses:
      command:
        - '--verbose'
      container_name: reading-glasses
      depends_on:
        - openvpn
        - rreading-glasses-db
      entrypoint:
        - /main
        - serve
      env_file:
        - rreading-glasses/reading_glasses.env
      image: 'blampe/rreading-glasses:hardcover'
      labels:
        - traefik.enable=true
        - traefik.http.routers.rglasses.entrypoints=https
        - traefik.http.routers.rglasses.rule=Host(`rglasses.media.johnson.int`)
        - traefik.http.routers.rglasses_insecure.entrypoints=http
        - >-
          traefik.http.routers.rglasses_insecure.rule=Host(`rglasses.media.johnson.int`)
        - traefik.http.routers.rglasses_insecure.middlewares=https-only@file
        - traefik.http.services.rglasses.loadbalancer.server.port=8788
      mem_limit: 128m
      network_mode: 'service:openvpn'
      restart: unless-stopped
      volumes:
        - >-
          /etc/ssl/certs/ca-certificates.crt:/etc/ssl/certs/ca-certificates.crt:ro
    rreading-glasses-db:
      container_name: rreading-glasses-db
      env_file:
        - rreading-glasses-db/reading_glasses_db.env
      image: 'postgres:17'
      network_mode: 'service:openvpn'
      restart: unless-stopped
      user: '1003:895'
      volumes:
        - '/home/media/docker/rreading-glasses-db/data:/var/lib/postgresql/data'
    sabnzbd:
      active: false
      container_name: sabnzbd
      depends_on:
        - openvpn
      environment:
        PGID: '895'
        PUID: '1003'
        TZ: America/New_York
      healthcheck:
        interval: 60s
        retries: 3
        start_period: 120s
        test:
          - CMD
          - curl
          - '-f'
          - 'http://localhost:8080'
        timeout: 15s
      image: 'lscr.io/linuxserver/sabnzbd:latest'
      labels:
        - traefik.enable=true
        - traefik.http.routers.sabnzbd-rtr-bypass.entrypoints=https
        - >-
          traefik.http.routers.sabnzbd-rtr-bypass.rule=Host(`sabnzbd.media.johnson.int`)
          && Query(`apikey`, `1a17c00ebc2fc61d721242f6b821a02b`)
        - traefik.http.routers.sabnzbd-rtr-bypass.priority=100
        - traefik.http.routers.sabnzbd-rtr.entrypoints=https
        - >-
          traefik.http.routers.sabnzbd-rtr.rule=Host(`sabnzbd.media.johnson.int`)
        - traefik.http.routers.sabnzbd-rtr.priority=99
        - traefik.http.routers.sabnzbd-rtr-bypass.middlewares=chain-no-auth@file
        - traefik.http.routers.sabnzbd-rtr.service=sabnzbd-svc
        - traefik.http.routers.sabnzbd-rtr-bypass.service=sabnzbd-svc
        - traefik.http.services.sabnzbd-svc.loadbalancer.server.port=8080
      network_mode: 'service:openvpn'
      restart: always
      volumes:
        - '/home/media/docker/sabnzbd:/config'
        - '/export/media/downloads:/downloads'
        - '/export/media/downloads/incomplete:/incomplete-downloads'
        - '/home/media/docker/shared:/shared'
    sonarr:
      container_name: sonarr
      depends_on:
        - openvpn
      entrypoint: /entrypoint.sh
      environment:
        PGID: '895'
        PUID: '1003'
        TZ: America/New_York
      image: 'lscr.io/linuxserver/sonarr:latest'
      labels:
        - traefik.enable=true
        - traefik.http.routers.sonarr.entrypoints=https
        - traefik.http.routers.sonarr.rule=Host(`sonarr.media.johnson.int`)
        - traefik.http.routers.sonarr_insecure.entrypoints=http
        - >-
          traefik.http.routers.sonarr_insecure.rule=Host(`sonarr.media.johnson.int`)
        - traefik.http.routers.sonarr_insecure.middlewares=https-only@file
        - traefik.http.services.sonarr.loadbalancer.server.port=8989
      network_mode: 'service:openvpn'
      restart: unless-stopped
      volumes:
        - '/opt/scripts/mono-entrypoint.sh:/entrypoint.sh'
        - '/home/media/docker/sonarr:/config'
        - '/export/media/downloads:/downloads'
        - '/srv/media/tv_shows:/tv'
        - '/home/media/docker/shared:/shared'
        - '/home/media/docker/scripts:/scripts'
        - >-
          /etc/ssl/certs/ca-certificates.crt:/etc/ssl/certs/ca-certificates.crt:ro
    thelounge:
      active: false
      container_name: thelounge
      environment:
        PGID: '895'
        PUID: '1003'
        TZ: America/New_York
      image: ghcr.io/linuxserver/thelounge
      labels:
        - traefik.enable=true
        - traefik.http.routers.thelounge.entrypoints=https
        - >-
          traefik.http.routers.thelounge.rule=Host(`thelounge.media.johnson.int`)
        - traefik.http.services.thelounge.loadbalancer.server.port=9000
      networks:
        - traefik_public
      ports:
        - '9000:9000'
      restart: unless-stopped
      volumes:
        - '/home/media/docker/thelounge:/config'
    transmission:
      active: false
      container_name: transmission
      depends_on:
        - openvpn
      environment:
        GROUPID: '895'
        TRPASSWD: qqnm3LXD
        TRUSER: transmission
        TZ: America/New_York
        USERID: '1003'
      image: 'dperson/transmission:latest'
      labels:
        - traefik.enable=true
        - traefik.http.routers.transmission.entrypoints=https
        - >-
          traefik.http.routers.transmission.rule=Host(`transmission.media.johnson.int`)
        - traefik.http.services.transmission.loadbalancer.server.port=9091
      network_mode: 'service:openvpn'
      restart: always
      volumes:
        - '/export/media/downloads:/var/lib/transmission-daemon/downloads'
        - '/home/media/docker/transmission:/var/lib/transmission-daemon/info'
        - '/export/media/downloads:/downloads'
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
          traefik.http.routers.ldapadmin.rule=Host(`ldapadmin.media.johnson.int`)
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
        - '/home/media/docker/openldap/slapd/database:/var/lib/ldap'
        - '/home/media/docker/openldap/slapd/config:/etc/ldap/slapd.d'
        - >-
          /home/media/docker/openldap/slapd/certs:/container/service/slapd/assets/certs
        - >-
          /home/media/docker/openldap/ldif:/container/service/slapd/assets/config/bootstrap/ldif/custom
        - >-
          /home/media/docker/openldap/environment:/container/environment/01-custom
        - >-
          /home/media/docker/openldap/schema:/container/service/slapd/assets/config/bootstrap/schema
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
          traefik.http.routers.phpldapadmin.rule=Host(`phpldapadmin.media.johnson.int`)
        - traefik.http.services.phpldapadmin.loadbalancer.server.port=80
      networks:
        - traefik_public
        - net
      ports:
        - '18080:80'
      restart: unless-stopped
  photoprism:
    photoprism:
      container_name: photoprism
      env_file:
        - photoprism/photoprism.env
      environment:
        PGID: '895'
        PUID: '1003'
      healthcheck:
        disable: false
      image: 'photoprism/photoprism:latest'
      labels:
        - traefik.enable=true
        - traefik.http.routers.photoprism.entrypoints=https
        - >-
          traefik.http.routers.photoprism.rule=Host(`photoprism.media.dettonville.cloud`)
          || Host(`photoprism.media.johnson.int`)
        - traefik.http.services.photoprism.loadbalancer.server.port=2342
      networks:
        - traefik_public
      ports:
        - '2342:2342'
      restart: unless-stopped
      volumes:
        - '/etc/localtime:/etc/localtime:ro'
        - '/srv/media/photos:/photoprism/originals'
        - '/home/media/docker/photoprism/data:/photoprism/storage'
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
        PGID: '895'
        PUID: '1003'
        TZ: America/New_York
      image: 'redis:6.2.14'
      networks:
        - net
      restart: unless-stopped
      security_opt:
        - no-new-privileges=true
      volumes:
        - '/home/media/docker/redis:/data'
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
        - traefik.http.routers.rediscom.rule=Host(`rediscom.media.johnson.int`)
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
        - '/data/docker_registry_local:/var/lib/registry'
        - '/home/media/docker/docker-registry/config/certs:/certs'
        - '/home/media/docker/docker-registry/config/files/auth:/auth'
        - >-
          /home/media/docker/docker-registry/config/config.yml:/etc/docker/registry/config.yml:ro
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
          traefik.http.routers.registryfe-rtr.rule=Host(`registry.media.johnson.int`)
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
          /home/media/docker/docker-registry/config/certs/media.johnson.int.chain.pem:/etc/apache2/server.crt:ro
        - >-
          /home/media/docker/docker-registry/config/certs/media.johnson.int-key.pem:/etc/apache2/server.key:ro
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
        - '/home/media/docker/samba/libnss-ldap.conf:/etc/libnss-ldap.conf:ro'
        - '/home/media/docker/samba/smb.conf:/etc/samba/smb.conf:ro'
        - >-
          /home/media/docker/samba/smbldap.conf:/etc/smbldap-tools/smbldap.conf:ro
        - >-
          /home/media/docker/samba/smbldap_bind.conf:/etc/smbldap-tools/smbldap_bind.conf:ro
        - '/data:/data'

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
