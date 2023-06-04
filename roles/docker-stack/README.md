
# docker-stack

This role will set up and configure a collection of docker containers.

## Dependencies

### 1: python interpreter dependencies

This role utilizes the `community.docker` modules.

The `community.docker` modules require that python libraries to be available (pyyaml, pyopenssl, cryptography, etc) as well as the docker python library on the target host. 

The python library dependencies are expected to be already prepared in a prior plays by the 'bootstrap-pip' and 'bootstrap-docker' roles which are available in this repo.

### 2: docker runtime dependency

The docker runtime environment is expected to be already prepared in a prior play by the 'bootstrap-docker' role which is available in this repo.

## Playbook Usage

bootstrap-docker-stack.yml:
```yaml

- name: "Bootstrap docker stack"
  hosts: docker-stack
  become: True
  vars:
    ansible_python_docker_interpreter: "/usr/local/bin/python-docker"

  roles:
    - role: bootstrap-pip

    - role: bootstrap-docker
      ## coerce the 'ansible_python_docker_interpreter' global variable into role input/scope variables
      ## the `bootstrap-docker` sets up the docker python virtualenv along with docker library dependency and symlinks the venv python to the specified value 
      bootstrap_docker_python_docker_interpreter: "{{ ansible_python_docker_interpreter }}"

    - role: docker-stack
      ## the `docker-stack` role uses the specified docker python virtualenv interpreter to run the `community.docker` tasks 
      docker_stack__python_docker_interpreter: "{{ ansible_python_docker_interpreter }}"

```

## Playbook Usage with inventory group_vars

An improved implementation of the last play would set the variables in respective docker `group_var` files such that any plays targeting `docker_stack` hosts defined in the `docker_stack` group would correctly derive the necessary role input variables without having/requiring to respecify them on each play that uses the role(s).

inventory/group_vars/docker.yml:
```yaml
---

ansible_python_docker_interpreter: "/usr/local/bin/python-docker"
## used to set up the symlink to the virtualenv python with all necessary docker library dependencies
bootstrap_docker_python_docker_interpreter: "{{ ansible_python_docker_interpreter }}"

```

inventory/group_vars/docker_stack.yml:
```yaml
---

## used to run the virtualenv python for all plays using the 'community.docker' modules
docker_stack__python_docker_interpreter: "{{ ansible_python_docker_interpreter }}"

```

Then the first play could be refactored as follows:

bootstrap-docker-stack.yml:
```yaml

- name: "Bootstrap docker stack"
  hosts: docker_stack
  become: True
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
docker stack deploy --compose-file docker-compose.yml docker-stack
docker stack deploy --compose-file docker-compose.yml docker_stack
docker stack destroy --compose-file docker-compose.yml docker-stack
docker stack rm --compose-file docker-compose.yml docker-stack
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

## References

- https://github.com/IronicBadger/ansible-role-docker-compose-generator/blob/master/templates/docker-compose.yml.j2

