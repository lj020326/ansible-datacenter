# docker-stack

## Role Summary

This role will set up and configure a collection/group of docker containers. 
The group(s)/collection(s) are configured using variables prefixed with `docker_stack__service_groups__`. 

## Requirements

### 1: python interpreter dependencies

This role utilizes the `community.docker` modules.

The `community.docker` modules require that python libraries to be available (pyyaml, pyopenssl, cryptography, etc) as well as the docker python library on the target host. 

The python library dependencies are expected to be already prepared in a prior plays by the 'bootstrap_pip' and 'bootstrap_docker' roles which are available in this repo.

### 2: docker runtime dependency

The docker runtime environment is expected to be already prepared in a prior play by the 'bootstrap_docker' role which is available in this repo.

## Role Variables

| Variable                                     | Required | Default                                                                           | Comments                   |
|----------------------------------------------|----------|-----------------------------------------------------------------------------------|----------------------------|
| docker_stack__action                         | no       | 'setup'                                                                           |                            |
| docker_stack__swarm_mode                     | no       | no                                                                                |                            |
| docker_stack__swarm_manager                  | no       | false                                                                             |                            |
| docker_stack__swarm_leader_host              | no       | leader.example.int                                                                |                            |
| docker_stack__setup_external_site            | no       | no                                                                                |                            |
| docker_stack__enable_cert_resolver           | no       | no                                                                                |                            |
| docker_stack__service_groups                 | no       | []                                                                                |                            |
| docker_stack__traefik_routing_method         | no       | path                                                                              |                            |
| docker_stack__proxy_services                 | no       | []                                                                                |                            |
| docker_stack__traefik_version                | no       | v2                                                                                |                            |
| docker_stack__traefik_http                   | no       | 80                                                                                |                            |
| docker_stack__traefik_https                  | no       | 443                                                                               |                            |
| docker_stack__traefik_ssh                    | no       | 2022                                                                              |                            |
| docker_stack__acme_http_challenge_proxy_port | no       | 8980                                                                              |                            |
| docker_stack__enable_cacerts                 | no       | no                                                                                |                            |
| docker_stack__enable_selfsigned_certs        | no       | yes                                                                               |                            |
| docker_stack__setup_registry                 | no       | no                                                                                |                            |
| docker_stack__setup_admin_scripts            | no       | yes                                                                               |                            |
| docker_stack__setup_systemd_service          | no       | yes                                                                               |                            |
| docker_stack__compose_stack_name             | no       | docker_stack                                                                      |                            |
| docker_stack__compose_stack_compose_file     | no       | "{{ docker_stack__dir }}/docker-compose.yml"                                      |                            |
| docker_stack__compose_stack_prune            | no       | yes                                                                               |                            |
| docker_stack__compose_stack_resolve_image    | no       | changed                                                                           |                            |
| docker_stack__compose_http_timeout           | no       | 120                                                                               |                            |
| docker_stack__run_services                   | no       | yes                                                                               |                            |
| docker_stack__restart_service                | no       | yes                                                                               |                            |
| docker_stack__traefik_proxy_network          | no       | "traefik_public"                                                                  |                            |
| docker_stack__networks                       | no       | {}                                                                                |                            |
| docker_stack__volumes                        | no       | {}                                                                                |                            |
| docker_stack__configs                        | no       | {}                                                                                |                            |
| docker_stack__user_username                  | no       | container-user                                                                    |                            |
| docker_stack__user_password                  | no       | container-user                                                                    |                            |
| docker_stack__user_group                     | no       | container-user                                                                    |                            |
| docker_stack__docker_group_gid               | no       | 991                                                                               |                            |
| docker_stack__container_user_home            | no       | /var/internaluser                                                                 |                            |
| docker_stack__user_home                      | no       | "/home/{{ docker_stack__user_username }}"                                         |                            |
| docker_stack__config_users_passwd            | no       |                                                                                   |                            |
| docker_stack__config_users_group             | no       |                                                                                   |                            |
| docker_stack__dir                            | no       | "{{ docker_stack__user_home }}/docker"                                            |                            |
| docker_stack__compose_file                   | no       | "{{ docker_stack__dir }}/docker-compose.yml"                                      |                            |
| docker_stack__remove_orphans                 | no       | yes                                                                               |                            |
| docker_stack__ca_root_cn                     | no       | "ca-root"                                                                         |                            |
| docker_stack__acme_email                     | no       | "admin@example.int"                                                               |                            |
| docker_stack__internal_root_domain           | no       | "example.int"                                                                     |                            |
| docker_stack__external_root_domain           | no       | "example.com"                                                                     |                            |
| docker_stack__service_route_name             | no       | "{{ inventory_hostname_short }}"                                                  |                            |
| docker_stack__internal_domain                | no       | "{{ docker_stack__service_route_name }}.{{ docker_stack__internal_root_domain }}" |                            |
| docker_stack__external_domain                | no       | "{{ docker_stack__service_route_name }}.{{ docker_stack__external_root_domain }}" |                            |
| docker_stack__enable_external_route          | no       | no                                                                                |                            |
| docker_stack__internal_ssl_cert_dir          | no       | /usr/local/ssl/certs                                                              |                            |
| docker_stack__internal_ssl_certkey_dir       | no       | /usr/local/ssl/private                                                            |                            |
| docker_stack__ssl_internal_root_cacert_file  | no       | "ca.{{ docker_stack__internal_root_domain }}.pem"                                 |                            |
| docker_stack__ssl_internal_cacert_file       | no       | "ca.{{ docker_stack__internal_domain }}.pem"                                      |                            |
| docker_stack__ssl_internal_cert_file         | no       | "{{ docker_stack__internal_domain }}.pem"                                         |                            |
| docker_stack__ssl_internal_csr_file          | no       | "{{ docker_stack__internal_domain }}.csr"                                         |                            |
| docker_stack__ssl_internal_privatekey_file   | no       | "{{ docker_stack__internal_domain }}-key.pem"                                     |                            |
| docker_stack__external_ssl_cert_dir          | no       | "{{ docker_stack__dir }}/shared/certs"                                            |                            |
| docker_stack__external_ssl_certkey_dir       | no       | "{{ docker_stack__dir }}/shared/certs"                                            |                            |
| docker_stack__ssl_external_cert_file         | no       | "{{ docker_stack__external_domain }}.pem"                                         |                            |
| docker_stack__ssl_external_privatekey_file   | no       | "{{ docker_stack__external_domain }}-key.pem"                                     |                            |
| docker_stack__script_dir                     | no       | "/opt/scripts"                                                                    |                            |
| docker_stack__jenkins__vmware_data_dir        | no       | /export/data/vmware                                                               |                            |
| docker_stack__api_port                       | no       | "2375"                                                                            |                            |
| docker_stack__app_config_dirs                | no       | {}                                                                                |                            |
| docker_stack__config_dirs                    | no       | []                                                                                |                            |
| docker_stack__app_config_tpls                | no       | {}                                                                                |                            |
| docker_stack__app_config_files               | no       | {}                                                                                |                            |
| docker_stack__config_files                   | no       | []                                                                                |                            |
| docker_stack__script_dirs                    | no       | see defaults/main.yml                                                             |                            |
| docker_stack__scripts                        | no       | see defaults/main.yml                                                             |                            |
| docker_stack__service_templates              | no       | defaults/main.yml                                                                 |                            |
| docker_stack__proxy_service_templates        | no       | defaults/main.yml                                                                 |                            |
| docker_stack__script_config_tpls             | no       | defaults/main.yml                                                                 |                            |
| docker_stack__email_from                     | no       | "admin@example.com"                                                               |                            |
| docker_stack__email_to                       | no       | "admin@example.com"                                                               |                            |
| docker_stack__email_default_suffix           | no       | "@example.com"                                                                    |                            |
| docker_stack__email_admin_address            | no       | "admin@example.com"                                                               |                            |
| docker_stack__smtp                           | no       | "mail.example.int"                                                                |                            |
| docker_stack__firewalld_enabled              | no       | yes                                                                               |                            |
| docker_stack__firewalld_services             | no       | []                                                                                |                            |
| docker_stack__firewalld_app_services         | no       | {}                                                                                |                            |
| docker_stack__firewalld_app_ports            | no       | {}                                                                                |                            |
| docker_stack__registry_service_domain        | no       | "{{ docker_stack__internal_domain }}"                                             |                            |
| docker_stack__registry_endpoint              | no       | "lj020326"                                                                        | private registry namespace |
| docker_stack__registry_login                 | no       | no                                                                                |                            |
| docker_stack__registry_username              | no       | user                                                                              |                            |
| docker_stack__registry_password              | no       | password                                                                          |                            |
| docker_stack__service_group_configs_tpl      | no       | {}                                                                                |                            |
| docker_stack__config_tpls                    | no       | []                                                                                |                            |
| docker_stack__container_configs              | no       | {}                                                                                |                            |
| docker_stack__timezone                       | no       | "America/New_York"                                                                |                            |


### Service specific variables

In addition to the general stack variables, there are also service specific variables used to specify service-specific options.

For service-specific variables, see the variables contained in the var files in each of the respective service-specific directories in `./vars/app-services/common/`.

## Playbook Usage

bootstrap-docker-stack.yml:
```yaml
- name: "Bootstrap docker stack"
  hosts: docker_stack
  become: True
  vars:
    ansible_python_docker_interpreter: "/usr/local/bin/python-docker"

  roles:
    - role: bootstrap-pip
      bootstrap_pip__env_list__docker:
        - pip_executable: pip3
          version: latest
          libraries:
            - jsondiff
            - docker
            - docker-compose
    - role: bootstrap-docker
    - role: docker-stack

```

## Playbook Usage with inventory group_vars

An improved implementation of the last play would set the variables in respective docker `group_var` files such that any plays targeting `docker_stack` hosts defined in the `docker_stack` group would correctly derive the necessary role input variables without having/requiring to respecify them on each play that uses the role(s).

inventory/hosts.yml:
```yaml
---
all:
  children:
    docker:
      children:
        docker_stack:
          children:
            docker_stack_jenkins_jcac:
              hosts:
                testd1s4.example.int: {}

```

inventory/group_vars/docker.yml:
```yaml
---

ansible_python_docker_interpreter: "/usr/local/bin/python-docker"
## used to set up the symlink to the virtualenv python with all necessary docker library dependencies
bootstrap_docker_python_docker_interpreter: "{{ ansible_python_docker_interpreter }}"

```

inventory/group_vars/docker_stack.yml:
```yaml
bootstrap_pip__env_list__docker:
  - pip_executable: pip3
    version: latest
    libraries:
      - jsondiff
      - docker
      - docker-compose

```

inventory/group_vars/docker_stack_jenkins.yml:
```yaml
---
###########
## JENKINS_JCAC
###########
docker_stack__service_groups__jenkins_jcac:
  - jenkins_jcac

```

Then the first play could be refactored as follows:

bootstrap-docker-stack.yml:
```yaml
- name: "Bootstrap docker stack nodes"
  hosts: docker_stack,!node_offline
  tags:
    - bootstrap-docker-stack
    - docker-stack
  become: True
  vars:
    ansible_python_interpreter: "{{ bootstrap_docker_python_docker_interpreter }}"
  roles:
    - role: bootstrap-pip
    - role: bootstrap-docker
    - role: docker-stack

```

Then the docker input role variables are set as defined/specified in the inventory.

```shell
ansible-playbook -i inventory/Dev -v bootstrap-docker-stack.yml -l testgroup_docker
```

## Debugging

### Docker stacks

```shell
docker service logs -f docker_stack__traefik
docker rmi $(docker images | grep jenkins-jcac | tr -s ' ' | cut -d' ' -f3)
docker stack deploy --compose-file docker-compose.yml docker_stack
docker stack destroy --compose-file docker-compose.yml docker_stack
docker stack rm --compose-file docker-compose.yml docker_stack
docker stack rm docker_stack

docker login -u username -p password registry.example.int:5000
docker stack deploy --compose-file docker-compose.yml docker_stack --with-registry-auth

docker service logs -f docker_stack__traefik
docker service ls
docker service rm docker_stack__whoami

docker service rm docker_stack__jenkins-jcac
docker service create --dns 10.0.0.1 docker_stack__jenkins-jcac

docker network rm socket_proxy
docker network rm traefik_public
docker network rm net
#docker network create -d overlay --scope local --attachable socket_proxy
#docker network create -d overlay --scope swarm --attachable socket_proxy
docker network create -d overlay --attachable socket_proxy
docker network create -d overlay --attachable traefik_public
docker network create --scope swarm --driver overlay socket_proxy
docker network create --scope swarm --driver overlay traefik_public
docker network inspect socket_proxy
docker network inspect traefik_public
#docker network create -d overlay --attachable net

docker network create -d overlay --scope local --attachable socket_proxy
#docker network create --driver overlay --dns=10.0.0.1 --gateway=10.0.0.1 traefik_public
#docker network create --driver overlay --gateway=10.0.0.1 traefik_public
#docker network create --driver overlay --ingress --subnet=10.0.0.0/16 --gateway=10.0.0.1 ingress
#docker network create --driver overlay --subnet=10.0.0.0/16 --gateway=10.0.0.1 traefik_public
#docker network create --driver overlay --subnet=10.0.0.0/16 --ip-range=10.0.5.0/24 --gateway=10.0.0.1 traefik_public
#docker network create --driver overlay --subnet=10.0.0.0/8 --gateway=10.0.0.1 traefik_public
#docker network create --driver overlay --subnet=10.0.0.0/8 --ip-range=10.0.5.0/24 --gateway=10.0.0.1 traefik_public
#docker network create --driver overlay --subnet=10.11.0.0/16 --gateway=10.0.0.1 traefik_public
docker network create --driver overlay traefik_public
docker network create --help
docker network create --scope swarm -d overlay traefik_public
docker network create --scope swarm traefik_public
#docker network create --subnet 10.11.0.0/16 --opt com.docker.network.bridge.name=docker_gwbridge --opt com.docker.network.bridge.enable_icc=false --opt com.docker.network.bridge.enable_ip_masquerade=true docker_gwbridge
docker network create traefik_public
docker network create \
  --driver overlay \
  --ingress \
  --subnet=10.11.0.0/16 \
  --gateway=10.11.0.2 \
  --opt com.docker.network.driver.mtu=1200 \
  my-ingress

## ref: https://docs.docker.com/engine/swarm/networking/
docker network rm ingress
docker network create \
  --driver overlay \
  --ingress \
  --subnet=10.0.0.0/24 \
  --gateway=10.0.0.1 \  
  --opt com.docker.network.driver.mtu=1200 \
  ingress
  
docker network rm traefik_public
docker network create \
  --driver overlay \
  --subnet=10.0.0.0/16 \
  --gateway=10.0.0.1 \
  traefik_public

```

## Restart stack service by Scale down/up

If updating any of the config - remove and re-deploy service to pick up new configs
```shell
$ docker service rm docker_stack_jenkins-jcac
$ docker service create docker_stack_jenkins-jcac
## OR
$ ./deploy-stack.sh
$ docker service logs -f docker_stack_jenkins-jcac
## How to view complete error message from 'docker stack ps'
$ docker stack ps --no-trunc docker_stack_jenkins-jcac
```

Scale down/up == restart
```shell
$ docker service scale docker_stack_jenkins-jcac=0
$ docker service scale docker_stack_jenkins-jcac=1
## OR simply
$ docker service rm docker_stack_jenkins-jcac
$ ./deploy-stack.sh ## utility script found in the /home/container-user/docker directory
```

## References

- https://github.com/jenkinsci/configuration-as-code-plugin/tree/master/demos/docker
- https://github.com/jenkinsci/matrix-auth-plugin/blob/master/src/test/resources/org/jenkinsci/plugins/matrixauth/integrations/casc/configuration-as-code-v3.yml
- https://docs.docker.com/engine/swarm/ingress/
- https://www.amapac.io/blog/2023/vds_jenkins_with_docker_desktop_jcasc.html
- https://vmware.github.io/photon/assets/files/html/1.0-2.0/Install-and-Configure-a-Swarm-Cluster-with-DNS-Service-on-PhotonOS.html
- https://dev.to/roylarsen/jenkins-build-agents-as-docker-swarm-services-9b4
- https://github.com/IronicBadger/ansible-role-docker-compose-generator/blob/master/templates/docker-compose.yml.j2
- https://stackoverflow.com/questions/44362258/swarm-node-status-down-but-node-should-be-ready
- https://docker-tutorial.schoolofdevops.com/swarm-networking-deepdive/
- https://www.suse.com/c/docker-swarm-container-networking/
- https://github.com/jfrog/artifactory-docker-examples/blob/master/swarm/artifactory-pro.yml
- https://github.com/jfrog/artifactory-docker-examples
- https://stackoverflow.com/questions/64685593/how-to-mirror-dockerhub-with-artifactory
- https://codeblog.dotsandbrackets.com/private-registry-swarm/
- https://www.happycoders.eu/devops/jenkins-tutorial-implementing-seed-job/
- https://github.com/riteshsoni10/jenkins_seed_job
- https://marcesher.com/2016/06/21/jenkins-as-code-registering-jobs-for-automatic-seed-job-creation/
- https://souravatta.medium.com/automatic-trigger-of-generated-jobs-created-from-jenkins-seedjob-b517ed88b6f8
- https://docs.cloudbees.com/docs/cloudbees-jenkins-platform/latest/casc-oc/rbac
- 
