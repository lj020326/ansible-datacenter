---
title: "Bootstrap Lxc Role"
role: roles/bootstrap_lxc
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_lxc]
---

# Bootstrap LXC Role Documentation

## Purpose

The `bootstrap_lxc` role is designed to set up and configure LXC (Linux Containers) environments for testing and development purposes. This role handles the installation of necessary packages, configuration of container settings, and setup of SSH keys for secure access to the containers.

## Variables

| Variable Name                   | Default Value                                                                 | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
|---------------------------------|-------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `container_config`              | `lxc.apparmor.profile = unconfined, lxc.mount.auto = proc:rw sys:rw cgroup-full:rw, lxc.cgroup.devices.allow = a *:* rmw` | List of configuration settings for LXC containers. These settings control various aspects of the container's behavior and security.                                                                                                                                                                                                                                                                                                                                                         |
| `additional_packages`           | `[]`                                                                         | List of additional packages to be installed in the LXC containers. This allows for customization of the container environment to include any necessary software.                                                                                                                                                                                                                                                                                                                                                   |
| `lxc_cache_directory`           | `/home/{{ ansible_user_id }}/lxc`                                             | Directory where cached container root filesystems are stored. This helps in speeding up the setup process by reusing previously downloaded and configured container images.                                                                                                                                                                                                                                                                                                                                             |
| `lxc_use_overlayfs`             | `true`                                                                       | Boolean flag to determine whether to use OverlayFS for the container's root filesystem. OverlayFS is a union filesystem that allows for efficient management of container layers.                                                                                                                                                                                                                                                                                                                                               |

## Usage

To use the `bootstrap_lxc` role, include it in your playbook and define any necessary variables. Here is an example playbook that uses this role:

```yaml
---
- hosts: localhost
  roles:
    - role: bootstrap_lxc
      vars:
        container_config:
          - lxc.apparmor.profile = unconfined
          - lxc.mount.auto = proc:rw sys:rw cgroup-full:rw
          - lxc.cgroup.devices.allow = a *:* rmw
        additional_packages:
          - vim
          - curl
        lxc_cache_directory: /home/{{ ansible_user_id }}/lxc
        lxc_use_overlayfs: true
```

## Dependencies

This role does not have any external dependencies. It uses the `community.general.lxc_container` module, which should be installed in your Ansible environment. If the module is not already installed, you can install it using:

```bash
ansible-galaxy collection install community.general
```

## Best Practices

- **Customization**: Customize the `container_config` and `additional_packages` variables to fit the specific needs of your LXC containers.
- **Caching**: Utilize the `lxc_cache_directory` to speed up the setup process by caching container root filesystems.
- **Security**: Ensure that the SSH keys generated are securely managed and stored.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_lxc/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_lxc/tasks/main.yml)
- [tasks/travis_packaging_setup.yml](../../roles/bootstrap_lxc/tasks/travis_packaging_setup.yml)
- [tasks/validate_variables.yml](../../roles/bootstrap_lxc/tasks/validate_variables.yml)