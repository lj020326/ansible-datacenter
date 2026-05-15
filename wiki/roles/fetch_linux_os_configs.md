---
title: "Fetch Linux OS Configs Role"
role: fetch_linux_os_configs
category: Ansible Roles
type: Documentation
tags: ansible, role, linux, os-configs, documentation
---

## Summary

The `fetch_linux_os_configs` role is designed to gather and display the content of specified configuration files from a Linux system. It checks for the existence of each file, reads its contents if it exists, and then outputs these contents in a structured format.

## Variables

| Variable Name                         | Default Value                                      | Description                                                                 |
|---------------------------------------|----------------------------------------------------|-----------------------------------------------------------------------------|
| `role_fetch_linux_os_configs__configs` | `/etc/resolv.conf`, `/etc/docker/daemon.json`      | List of configuration files to fetch from the target Linux system.          |

## Usage

To use this role, include it in your playbook and specify the list of configuration files you want to fetch. The default configuration files are `/etc/resolv.conf` and `/etc/docker/daemon.json`.

Example Playbook:

```yaml
---
- name: Fetch OS Configurations
  hosts: all
  roles:
    - role: fetch_linux_os_configs
      vars:
        role_fetch_linux_os_configs__configs:
          - /etc/resolv.conf
          - /etc/docker/daemon.json
```

## Dependencies

This role does not have any external dependencies.

## Best Practices

- Ensure that the target hosts are reachable and have the necessary permissions to read the specified configuration files.
- Customize the `role_fetch_linux_os_configs__configs` variable to include only the files relevant to your environment.
- Use this role in playbooks where you need to audit or backup configuration files from multiple systems.

## Molecule Tests

This role does not currently include any Molecule tests. Consider adding tests to ensure the role behaves as expected across different environments and configurations.

## Backlinks

- [defaults/main.yml](../../roles/fetch_linux_os_configs/defaults/main.yml)
- [tasks/main.yml](../../roles/fetch_linux_os_configs/tasks/main.yml)