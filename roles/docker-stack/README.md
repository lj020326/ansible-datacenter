
# docker-stack

This role will set up and configure a collection of docker containers.

## Dependencies

### 1: python interpreter dependencies

This role utilizes the `community.docker` modules.

The `community.docker` modules require that python libraries to be available (pyyaml, pyopenssl, cryptography, etc) as well as the docker python library on the target host. 

The python library dependencies are expected to be already prepared in a prior plays by the 'bootstrap-pip' and 'bootstrap-linux-docker' roles which are available in this repo.

### 2: docker runtime dependency

The docker runtime environment is expected to be already prepared in a prior play by the 'bootstrap-linux-docker' role which is available in this repo.

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

    - role: bootstrap-linux-docker
      ## coerce the 'ansible_python_docker_interpreter' global variable into role input/scope variables
      ## the `bootstrap-linux-docker` sets up the docker python virtualenv along with docker library dependency and symlinks the venv python to the specified value 
      bootstrap_docker_python_docker_interpreter: "{{ ansible_python_docker_interpreter }}"

    - role: docker-stack
      ## the `docker-stack` role uses the specified docker python virtualenv interpreter to run the `community.docker` tasks 
      docker_stack_python_docker_interpreter: "{{ ansible_python_docker_interpreter }}"

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
docker_stack_python_docker_interpreter: "{{ ansible_python_docker_interpreter }}"

```

Then the first play could be refactored as follows:

bootstrap-docker-stack.yml:
```yaml

- name: "Bootstrap docker stack"
  hosts: docker_stack
  become: True
  roles:
    - role: bootstrap-pip
    - role: bootstrap-linux-docker
    - role: docker-stack

```

Then the docker input role variables are set as defined/specified in the inventory.

```shell
ansible-playbook -i inventory/Dev -v bootstrap-docker-stack.yml -l testgroup_docker
```
