---
title: Bootstrap LXC Role Documentation
role: bootstrap_lxc
category: System Configuration
type: Ansible Role
tags: lxc, containerization, automation
---

## Summary

The `bootstrap_lxc` role is designed to automate the setup and configuration of LXC (Linux Containers) on a system. It handles tasks such as setting up SSH keys, extracting cached root filesystems, preparing base containers, and installing necessary packages for different profiles. This role ensures that the environment is ready for running LXC containers with minimal manual intervention.

## Variables

| Variable Name              | Default Value                                                                                           | Description                                                                                                                                                                                                 |
|----------------------------|---------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `container_config`         | <pre>\- lxc.apparmor.profile = unconfined<br>\- lxc.mount.auto = proc:rw sys:rw cgroup-full:rw<br>\- lxc.cgroup.devices.allow = a \*:\* rmw</pre> | A list of LXC container configuration settings.                                                                                                                                                               |
| `additional_packages`      | `[]`                                                                                                    | A list of additional packages to be installed in the LXC containers.                                                                                                                                        |
| `lxc_cache_directory`      | `/home/{{ ansible_user_id }}/lxc`                                                                       | The directory where cached root filesystems for LXC containers are stored.                                                                                                                                    |
| `lxc_use_overlayfs`        | `true`                                                                                                  | A boolean indicating whether to use OverlayFS for the LXC containers.                                                                                                                                         |

## Usage

To use the `bootstrap_lxc` role, include it in your playbook and define any necessary variables as needed. Here is an example of how you might include this role in a playbook:

```yaml
---
- name: Bootstrap LXC Containers
  hosts: all
  roles:
    - role: bootstrap_lxc
      vars:
        container_config:
          - lxc.apparmor.profile = unconfined
          - lxc.mount.auto = proc:rw sys:rw cgroup-full:rw
          - lxc.cgroup.devices.allow = a \*:\* rmw
        additional_packages:
          - vim
          - curl
```

## Dependencies

- `community.general` collection for the `lxc_container` module.
- `ansible.posix.patch` module for applying patches to LXC templates.

Ensure that these dependencies are installed in your Ansible environment:

```bash
ansible-galaxy collection install community.general
```

## Tags

This role does not define any specific tags. However, you can use the default tags provided by Ansible such as `always`, `never`, etc., to control task execution.

## Best Practices

- Ensure that the LXC cache directory exists and is writable by the user running the playbook.
- Define the `test_profiles` variable with appropriate profiles for your environment.
- Use the `additional_packages` variable to specify any extra packages required in your containers.

## Molecule Tests

This role does not include Molecule tests. However, it is recommended to create test scenarios using Molecule to ensure the role functions as expected across different environments.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_lxc/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_lxc/tasks/main.yml)
- [tasks/travis_packaging_setup.yml](../../roles/bootstrap_lxc/tasks/travis_packaging_setup.yml)
- [tasks/validate_variables.yml](../../roles/bootstrap_lxc/tasks/validate_variables.yml)

---

This documentation provides a comprehensive overview of the `bootstrap_lxc` role, including its purpose, variables, usage, dependencies, and best practices. For more detailed information, refer to the linked source files.