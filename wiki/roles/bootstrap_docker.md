---
title: "bootstrap_docker Role Documentation"
role: bootstrap_docker
category: Ansible Roles
type: Configuration Management

## Summary
The `bootstrap_docker` role is designed to automate the installation and configuration of Docker on various Linux distributions, including support for Docker Enterprise Edition (EE) and Community Edition (CE). It handles tasks such as installing Docker packages, configuring Docker daemon options, setting up Docker Swarm, deploying registry certificates, managing users, and more. The role is highly customizable through a variety of variables to suit different deployment environments.

## Variables
The following table lists the configurable variables along with their default values and descriptions:

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `bootstrap_docker__actions_allowed` | `['install', 'setup-swarm']` | List of allowed actions for this role. |
| `bootstrap_docker__actions` | `['install', 'setup-swarm']` | List of actions to perform during the playbook run. |
| `bootstrap_docker__config` | `{}` | Custom Docker configuration options. |
| `bootstrap_docker__options_prefix` | `"{{ role_name }}__options__"` | Prefix for custom Docker options variables. |
| `bootstrap_docker__options_regex` | `"^{{ bootstrap_docker__options_prefix }}"` | Regex pattern to match custom Docker options variables. |
| `bootstrap_docker__arch` | `"{{ 'arm64' if ansible_facts.machine == 'aarch64' else 'amd64' }}"` | Architecture of the system (automatically detected). |
| `bootstrap_docker__edition` | `ce` | Docker edition to install (`ce` for Community Edition, `ee` for Enterprise Edition). |
| `bootstrap_docker__repo` | `docker` | Repository source for Docker installation (`docker`, `rhsm`, or `other`). |
| `bootstrap_docker__channel` | `stable` | Channel for Docker installation (e.g., `stable`, `test`, `nightly`). |
| `bootstrap_docker__ee_version` | `24.09` | Version of Docker EE to install. |
| `bootstrap_docker__k8s_mode` | `false` | Enable Kubernetes mode if true. |
| `bootstrap_docker__rhsm_channel` | `"Example_Docker_Community_Edition_CE_Docker_CE_Stable_RHEL{{ ansible_facts['distribution_major_version'] }}"` | RHSM channel for Docker EE installation. |
| `bootstrap_docker__deploy_registry_certs` | `true` | Deploy registry certificates if true. |
| `bootstrap_docker__service_manage` | `true` | Manage the Docker service (start, stop, restart). |
| `bootstrap_docker__service_state` | `started` | Desired state of the Docker service (`started`, `stopped`). |
| `bootstrap_docker__service_enabled` | `true` | Enable Docker service on boot. |
| `bootstrap_docker__service_started` | `true` | Start Docker service immediately after installation. |
| `bootstrap_docker__service_restarted` | `true` | Restart Docker service if configuration changes are detected. |
| `bootstrap_docker__multiarch_builder_enabled` | `true` | Enable multi-architecture builder support. |
| `bootstrap_docker__multiarch_builder_driver` | `"service"` | Driver for multi-architecture builder (`service`, `container`). |
| `bootstrap_docker__buildkit_version` | `"v0.19.0"` | Version of BuildKit to install. |
| `bootstrap_docker__buildkit_arch` | `"linux-amd64"` | Architecture for BuildKit binary. |
| `bootstrap_docker__buildkit_url` | `"https://github.com/moby/buildkit/releases/download/{{ bootstrap_docker__buildkit_version }}/buildkit-{{ bootstrap_docker__buildkit_version }}.{{ bootstrap_docker__buildkit_arch }}.tar.gz"` | URL for BuildKit binary download. |
| `bootstrap_docker__daemon_flags` | `['-H unix:///var/run/docker.sock']` | Flags to pass to the Docker daemon. |
| `bootstrap_docker__swarm_leader_host` | `test123` | Hostname of the swarm leader node. |
| `bootstrap_docker__swarm_manager` | `false` | Designate this node as a swarm manager. |
| `bootstrap_docker__swarm_leader` | `false` | Designate this node as the swarm leader. |
| `bootstrap_docker__swarm_worker` | `false` | Designate this node as a swarm worker. |
| `bootstrap_docker__swarm_leave` | `false` | Remove this node from the swarm if true. |
| `bootstrap_docker__swarm_adv_addr` | `"{{ ansible_facts['default_ipv4']['address'] }}"` | Advertise address for the Docker Swarm node. |

## Usage
To use the `bootstrap_docker` role, include it in your playbook and specify any desired variables:

```yaml
- hosts: all
  roles:
    - role: bootstrap_docker
      vars:
        bootstrap_docker__edition: ee
        bootstrap_docker__ee_version: 24.09
        bootstrap_docker__swarm_manager: true
```

## Dependencies
The `bootstrap_docker` role depends on the following Ansible collections and modules:

- `community.docker`
- `ansible.builtin`
- `community.general`
- `ansible.posix`

Ensure these are installed in your environment before running the playbook.

```bash
ansible-galaxy collection install community.docker community.general ansible.posix
```

## Best Practices
1. **Use Specific Versions**: Always specify a specific version of Docker to avoid unexpected changes.
2. **Manage Swarm Nodes Carefully**: Ensure that swarm leader and manager nodes are correctly configured and managed.
3. **Secure Registry Certificates**: Properly manage and secure registry certificates to prevent unauthorized access.
4. **Monitor Service State**: Regularly monitor the state of the Docker service to ensure it is running as expected.

## Backlinks
- [defaults/main.yml](../../roles/bootstrap_docker/defaults/main.yml)
- [tasks/deploy_registry_cert.yml](../../roles/bootstrap_docker/tasks/deploy_registry_cert.yml)
- [tasks/docker_compose.yml](../../roles/bootstrap_docker/tasks/docker_compose.yml)
- [tasks/apt.yml](../../roles/bootstrap_docker/tasks/apt.yml)
- [tasks/dnf-rhsm.yml](../../roles/bootstrap_docker/tasks/dnf-rhsm.yml)
- [tasks/dnf.yml](../../roles/bootstrap_docker/tasks/dnf.yml)
- [tasks/debian-9.yml](../../roles/bootstrap_docker/tasks/debian-9.yml)
- [tasks/debian.yml](../../roles/bootstrap_docker/tasks/debian.yml)
- [tasks/yum-rhsm.yml](../../roles/bootstrap_docker/tasks/yum-rhsm.yml)
- [tasks/yum.yml](../../roles/bootstrap_docker/tasks/yum.yml)
- [tasks/deploy_config.yml](../../roles/bootstrap_docker/tasks/deploy_config.yml)
- [tasks/docker_users.yml](../../roles/bootstrap_docker/tasks/docker_users.yml)
- [tasks/centos.yml](../../roles/bootstrap_docker/tasks/centos.yml)
- [tasks/fedora.yml](../../roles/bootstrap_docker/tasks/fedora.yml)
- [tasks/oraclelinux.yml](../../roles/bootstrap_docker/tasks/oraclelinux.yml)
- [tasks/redhat.yml](../../roles/bootstrap_docker/tasks/redhat.yml)
- [tasks/ubuntu.yml](../../roles/bootstrap_docker/tasks/ubuntu.yml)
- [tasks/ensure_multiarch_builder.yml](../../roles/bootstrap_docker/tasks/ensure_multiarch_builder.yml)
- [tasks/init-vars.yml](../../roles/bootstrap_docker/tasks/init-vars.yml)
- [tasks/install.yml](../../roles/bootstrap_docker/tasks/install.yml)
- [tasks/lvm_cleanup.yml](../../roles/bootstrap_docker/tasks/lvm_cleanup.yml)
- [tasks/lvm_setup.yml](../../roles/bootstrap_docker/tasks/lvm_setup.yml)
- [tasks/main.yml](../../roles/bootstrap_docker/tasks/main.yml)
- [tasks/other_repo.yml](../../roles/bootstrap_docker/tasks/other_repo.yml)
- [tasks/proxy.yml](../../roles/bootstrap_docker/tasks/proxy.yml)
- [tasks/aufs.yml](../../roles/bootstrap_docker/tasks/aufs.yml)
- [tasks/btrfs.yml](../../roles/bootstrap_docker/tasks/btrfs.yml)
- [tasks/devicemapper.yml](../../roles/bootstrap_docker/tasks/devicemapper.yml)
- [tasks/overlay.yml](../../roles/bootstrap_docker/tasks/overlay.yml)
- [tasks/overlay2.yml](../../roles/bootstrap_docker/tasks/overlay2.yml)
- [tasks/zfs.yml](../../roles/bootstrap_docker/tasks/zfs.yml)
- [tasks/swarm_ingress_network.yml](../../roles/bootstrap_docker/tasks/swarm_ingress_network.yml)
- [tasks/swarm_leader.yml](../../roles/bootstrap_docker/tasks/swarm_leader.yml)
- [tasks/swarm_leave.yml](../../roles/bootstrap_docker/tasks/swarm_leave.yml)
- [tasks/swarm_manager.yml](../../roles/bootstrap_docker/tasks/swarm_manager.yml)
- [tasks/swarm_node.yml](../../roles/bootstrap_docker/tasks/swarm_node.yml)
- [tasks/swarm_node_rejoin.yml](../../roles/bootstrap_docker/tasks/swarm_node_rejoin.yml)
- [tasks/swarm_setup.yml](../../roles/bootstrap_docker/tasks/swarm_setup.yml)
- [tasks/swarm_worker.yml](../../roles/bootstrap_docker/tasks/swarm_worker.yml)
- [handlers/main.yml](../../roles/bootstrap_docker/handlers/main.yml)