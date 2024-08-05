# bootstrap_docker

## Role Summary

This role provides the following:
* Installation of Docker following Docker-Engine install procedures as documented by Docker.
* It will manage kernel versions as well, verifying the that the correct kernel for Docker support is installed.

Supports the following Operating Systems:
* CentOS 7
* CentOS 8
* RedHat 7
* RedHat 8
* Ubuntu 18.04
* Ubuntu 20.04
* Ubuntu 22.04

---

## Quick start

The philosophy for all of my roles is to make it easy to get going, but provide a way to customize nearly everything to maximize DRY flexibility/usability/re-usability.

## Requirements

This role requires Ansible 2.4 or higher. Requirements are listed in the metadata file.

If you rely on privilege escalation (e.g. `become: true`) with this role, you will need Ansible 2.2.1 or higher to take advantage of this issue being fixed: https://github.com/ansible/ansible/issues/17490


### What's configured by default?

The latest Docker-ce will be installed, Docker disk clean up
will happen once a week and Docker container logs will be sent to `journald`.

### Example playbook

```yml
---

# site.yml

- name: "Bootstrap docker nodes"
  hosts: docker,!node_offline
  tags:
    - bootstrap-docker
  become: True
  roles:
  - role: bootstrap_docker
```

## Role Variables
For more information about the variables many can be found https://docs.docker.com/engine/reference/commandline/dockerd/

| Variable | Required | Default | Comments |
|----------|----------|---------|----------|
| `bootstrap_docker__actions` | No | `['install']` | Actions for role to perform.  Allowed/Supported choices are ['install', 'setup-swarm'] |
| `bootstrap_docker__edition` | No | `ce` | Specifies either ce, or ee version of Docker. |
| `bootstrap_docker__ee_url` | No | `Undefined` | Docker EE URL from the Docker Store |
| `bootstrap_docker__repo` | No | `docker` | Defines how Ansible manages the repository. Options are "other" and "docker" |
| `bootstrap_docker__channel` | No | `stable` | What release channel of Docker to install. |
| `bootstrap_docker__ee_version` | No | `24.09` | Docker EE version for EE repository |
| `bootstrap_docker__storage_driver` | No | `Undefined` | Storage driver to use |
| `bootstrap_docker__block_device` | No | `Undefined` | The device name used for the storage driver. |
| `bootstrap_docker__mount_opts` | No | `Undefined` | The mount options when mounting filesystems |
| `bootstrap_docker__storage_opts` | No | `Undefined` | Storage driver options |
| `bootstrap_docker__api_cors_header` | No | `Undefined` | Set CORS headers in the remote API |
| `bootstrap_docker__authorization_plugins` | No | `Undefined` | Authorization plugins to load |
| `bootstrap_docker__bip` | No | `Undefined` | Specify network bridge IP |
| `bootstrap_docker__bridge` | No | `Undefined` | Attach containers to a network bridge |
| `bootstrap_docker__cgroup_parent` | No | `Undefined` | Set parent cgroup for all containers |
| `bootstrap_docker__cluster_store` | No | `Undefined` | Set cluster store options |
| `bootstrap_docker__cluster_store_opts` | No | `Undefined` | Please see dockerd manual for info |
| `bootstrap_docker__cluster_advertise` | No | `Undefined` | Address or interface name to advertise |
| `bootstrap_docker__debug` | No | `Undefined` | Enable debug mode |
| `bootstrap_docker__default_gateway` | No | `Undefined` | Container default gateway IPv4 address |
| `bootstrap_docker__default_gateway_v6` | No | `Undefined` | Container default gateway IPv6 address |
| `bootstrap_docker__default_runtime` | No | `Undefined` | Default OCI runtime for containers |
| `bootstrap_docker__default_ulimits` | No | `Undefined` | Default ulimits for containers |
| `bootstrap_docker__disable_legacy_registry` | No | `Undefined` | Disable contacting legacy registries |
| `bootstrap_docker__dns` | No | `Undefined` | DNS server to use |
| `bootstrap_docker__dns_opts` | No | `Undefined` | DNS options to use |
| `bootstrap_docker__dns_search` | No | `Undefined` | DNS search domains to use |
| `bootstrap_docker__exec_opts` | No | `Undefined` | Runtime execution options |
| `bootstrap_docker__exec_root` | No | `Undefined` | Root directory for execution state files |
| `bootstrap_docker__fixed_cidr` | No | `Undefined` | IPv4 subnet for fixed IPs |
| `bootstrap_docker__fixed_cidr_v6` | No | `Undefined` | IPv6 subnet for fixed IPs |
| `bootstrap_docker__graph` | No | `Undefined` | Root of the Docker runtime |
| `bootstrap_docker__group` | No | `Undefined` | Group for the unix socket |
| `bootstrap_docker__hosts` | No | `Undefined` | Daemon socket(s) to connect to |
| `bootstrap_docker__icc` | No | `Undefined` | Enable inter-container communication |
| `bootstrap_docker__insecure_registries` | No | `Undefined` | Enable insecure registry communication |
| `bootstrap_docker__ip` | No | `Undefined` | Default IP when binding container ports |
| `bootstrap_docker__iptables` | No | `Undefined` | Enable addition of iptables rules |
| `bootstrap_docker__ipv6` | No | `Undefined` | Enable IPv6 networking |
| `bootstrap_docker__ip_forward` | No | `Undefined` | Enable net.ipv4.ip_forward |
| `bootstrap_docker__ip_masq` | No | `Undefined` | Enable IP masquerading |
| `bootstrap_docker__labels` | No | `Undefined` | 	Set key=value labels to the daemon |
| `bootstrap_docker__live_restore` | No | `Undefined` | Enables keeping containers alive during daemon downtime |
| `bootstrap_docker__log_driver` | No | `Undefined` | Default driver for container logs |
| `bootstrap_docker__log_level` | No | `Undefined` | Set the logging level |
| `bootstrap_docker__log_opts` | No | `Undefined` | Default log driver options for containers |
| `bootstrap_docker__max_concurrent_downloads` | No | `Undefined` | Set the max concurrent downloads for each pull |
| `bootstrap_docker__max_concurrent_uploads` | No | `Undefined` | Set the max concurrent uploads for each push |
| `bootstrap_docker__mtu` | No | `Undefined` | Set the containers network MTU |
| `bootstrap_docker__oom_score_adjust` | No | `Undefined` | Set the oom_score_adj for the daemon |
| `bootstrap_docker__pidfile` | No | `Undefined` | Path to use for daemon PID file |
| `bootstrap_docker__raw_logs` | No | `Undefined` | Full timestamps without ANSI coloring |
| `bootstrap_docker__registry_mirrors` | No | `Undefined` | Preferred Docker registry mirror |
| `bootstrap_docker__runtimes` | No | `Undefined` | Register an additional OCI compatible runtime |
| `bootstrap_docker__selinux_enabled` | No | `Undefined` | Enable selinux support |
| `bootstrap_docker__swarm_default_advertise_addr` | No | `Undefined` | Set default address or interface for swarm advertised address |
| `bootstrap_docker__tls` | No | `Undefined` | Use TLS; implied by –tlsverify |
| `bootstrap_docker__tlscacert` | No | `Undefined` | Trust certs signed only by this CA |
| `bootstrap_docker__tlscert` | No | `Undefined` | Path to TLS certificate file |
| `bootstrap_docker__tlskey` | No | `Undefined` | Path to TLS key file |
| `bootstrap_docker__tlsverify` | No | `Undefined` | Use TLS and verify the remote |
| `bootstrap_docker__userland_proxy` | No | `Undefined` | Use userland proxy for loopback traffic |
| `bootstrap_docker__userns_remap` | No | `Undefined` | User/Group setting for user namespaces |
| `bootstrap_docker__users` | No | `Undefined` | A list of system users to be added to the docker group (so they can use Docker on the server) |
| `bootstrap_docker__http_proxy` | No | `Undefined` | Set the Docker service to use HTTP_PROXY |
| `bootstrap_docker__https_proxy` | No | `Undefined` | Set the Docker service to use HTTPS_PROXY |
| `bootstrap_docker__no_proxy_params` | No | `Undefined` | Do not proxy for Docker service params |
| `bootstrap_docker__setup_lvm` | No | `false` | Setup LVM for docker devicemapper to use. |
| `bootstrap_docker__pvname` | No* | `Undefined` | If setup_lvm is true, the PV name to use for lvm configuration is required. |
| `bootstrap_docker__vgname` | No | `docker` | The VG name used in LVM setup. |
| `bootstrap_docker__lvname` | No | `thinpool` | The LV name used in LVM setup. |
| `bootstrap_docker__lvname_meta` | No | `{{docker_vgname}}meta` | The LV meta used in LVM setup. |
| `bootstrap_docker__swarm_manager` | No | `false` | Setup as swarm manager. |
| `bootstrap_docker__swarm_leader` | No | `false` | Setup as swarm leader. |
| `bootstrap_docker__swarm_worker` | No | `false` | Setup as swarm worker. |
| `bootstrap_docker__swarm_leave` | No | `false` | Leave swarm. |
| `bootstrap_docker__swarm_adv_addr` | No | `ansible_hostname` | The listening address for the swarm node.  In the case where there are multiple network addresses this should be overridden. |
| `bootstrap_docker__swarm_remote_addrs` | No | `{{ leader_host }}:2377` | List of cluster addresses for swarm leader/manager node(s) used to join to the cluster. |

## Example Playbooks

Install docker to the hosts with basic defaults. This does not install devicemapper, or configure the server for production. This just simply installs docker and gets it running. Compare this to `apt install docker-ce` or `yum install docker-ce`.

```yaml
- hosts: servers
  roles:
  - role: bootstrap_docker
```

Install docker with devicemapper. Please note, this will create a new LVM on /dev/sda3, please do not use a block device already in use. This is the recommended production deployment on RHEL/CentOS/Fedora systems.

```yaml
- hosts: servers
  roles:
  - role: bootstrap_docker
    bootstrap_docker__storage_driver: devicemapper
    bootstrap_docker__block_device: /dev/sda3
```

Install docker with AUFS. This is recommended for production deployment on Ubuntu systems.

```yaml
- hosts: servers
  roles:
  - role: bootstrap_docker
    bootstrap_docker__storage_driver: aufs
```

Install with configured options.

```yaml
- hosts: servers
  roles:
  - role: bootstrap_docker
    bootstrap_docker__users: ["test"]
    bootstrap_docker__daemon_json: |
      "dns": ["8.8.8.8"]
    bootstrap_docker__daemon_environment:
      - "HTTP_PROXY=http://proxy.a.com:80"
      - "HTTPS_PROXY=https://proxy.a.com:443"
    bootstrap_docker__daemon_flags:
      - "-H fd://"
      - "--debug"
    bootstrap_docker__systemd_override: |
      [Unit]
      Invalid=Directive

      [Service]
      ThisIsJust=ATest

```

Configure devicemapper on lvm as storage backend using /dev/sdb as physical volume.

```yaml
- hosts: servers
  roles:
  - role: bootstrap_docker
    bootstrap_docker__setup_lvm: yes
    bootstrap_docker__docker_pvname: /dev/sdb

```

In order to configure docker engines in swarm mode, use the `bootstrap_docker_actions:['setup-swarm']` of the role.

```yaml
- hosts: servers
  roles:
  - role: bootstrap_docker
    bootstrap_docker__actions: ['setup-swarm']

```

To join new swarm worker nodes to a cluster already up & running, add new entries to the hosts.yml file:

hosts.yml:
```yaml
swarm:
  vars:
    bootstrap_docker__swarm_managers: "{{ groups['swarm_manager'] }}"
  children:
    swarm_leader: {}
    swarm_manager: {}
    swarm_worker: {}

# There can only be 1 `swarm_leader` per cluster
swarm_leader:
  vars:
    bootstrap_docker__swarm_leader: true
  hosts:
    vmlinux10: {}

swarm_manager:
  vars:
    bootstrap_docker__swarm_manager: true
  hosts:
    vmlinux20: {}
    vmlinux30: {}

swarm_worker:
  vars:
    bootstrap_docker__swarm_worker: true
  hosts:
    vmlinux[11:19]: {}
    vmlinux[21:29]: {}
    vmlinux[31:39]: {}

```

And invoke the role to perform the swarm configuration:

```yaml
- hosts: swarm
  roles:
  - role: bootstrap_docker
    bootstrap_docker__actions: ['setup-swarm']
    bootstrap_docker__swarm_managers:
      - group['swarm_manager']
```

Set Node Labels

```yaml
- hosts: swarm
  roles:
  - role: bootstrap_docker
    bootstrap_docker__actions: ['setup-swarm']
    bootstrap_docker__swarm_node_labels:
      label0: value0
      label1: value1
      label2: value2
```

Create secrets

```yaml
- hosts: swarm
  roles:
  - role: bootstrap_docker
    bootstrap_docker__actions: ['setup-swarm']
    bootstrap_docker__swarm_secrets:    
      - name: secret-name-0
        value: secret-value-0
        state: present
      - name: secret-name-1
        value: secret-value-1
        state: absent
```


Please see [examples/](examples/) folder for more examples.

## Reference

- [ansible-role-docker](https://github.com/avinetworks/ansible-role-docker)
- https://github.com/rremizov/ansible-docker-swarm
- [one-click-deploy-docker-swarm-with-ansible](https://medium.com/@mbovo/one-click-deploy-docker-swarm-with-ansible-9a1f7e7d0e75)
- https://github.com/mbovo/ansible_stuffs
- https://github.com/nmarus/docker-swarm-ansible
- [deploying-docker-swarm-with-ansible](https://medium.com/@cantrobot/deploying-docker-swarm-with-ansible-a991c1028427)
- https://github.com/nextrevision/ansible-swarm-playbook
- 
