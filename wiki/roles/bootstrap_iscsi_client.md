---
title: "Bootstrap iSCSI Client Role"
role: roles/bootstrap_iscsi_client
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_iscsi_client]
---

# Bootstrap iSCSI Client Role Documentation

## Overview

The `bootstrap_iscsi_client` role is designed to manage iSCSI initiator configuration on Debian and RedHat-based systems. It installs necessary packages, configures iSCSI settings, manages iSCSI targets, and handles LVM for logical volumes. This role ensures that iSCSI clients are properly set up and configured to connect to iSCSI targets, with support for authentication and various configuration options.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `bootstrap_iscsi_client__target_port` | "3260" | The default port for iSCSI targets. |
| `bootstrap_iscsi_client__system_info` | See defaults/main.yml | System-specific information for Debian and RedHat-based systems. |
| `bootstrap_iscsi_client__interfaces` | [] | List of network interfaces to be used for iSCSI. |
| `bootstrap_iscsi_client__portals` | [] | List of iSCSI portals to discover targets from. |
| `bootstrap_iscsi_client__targets` | [] | List of iSCSI targets to log in to. |
| `bootstrap_iscsi_client__logical_volumes` | [] | List of logical volumes to manage. |
| `bootstrap_iscsi_client__iqn_date` | "{{ ansible_facts['date_time']['year'] }}-{{ ansible_facts['date_time']['month'] }}" | The date part of the iSCSI IQN. |
| `bootstrap_iscsi_client__iqn_authority` | "{{ ansible_domain }}" | The authority part of the iSCSI IQN. |
| `bootstrap_iscsi_client__iqn` | '{{ (ansible_local.iscsi.iqn if (ansible_local | d() and ansible_local.iscsi | d() and ansible_local.iscsi.iqn | d()) else ("iqn." + bootstrap_iscsi_client__iqn_date + "." + bootstrap_iscsi_client__iqn_authority.split(".")[::-1] | join("."))) }}' | The iSCSI Initiator IQN. |
| `bootstrap_iscsi_client__hostname` | "{{ ansible_facts['hostname'] }}" | The hostname of the system. |
| `bootstrap_iscsi_client__initiator_name` | "{{ bootstrap_iscsi_client__iqn }}:{{ bootstrap_iscsi_client__hostname }}" | The iSCSI Initiator Name. |
| `bootstrap_iscsi_client__enabled` | true | Whether the iSCSI service should be enabled. |
| `bootstrap_iscsi_client__node_startup` | automatic | The startup mode for iSCSI nodes. |
| `bootstrap_iscsi_client__discovery_auth` | true | Whether to use authentication for iSCSI discovery. |
| `bootstrap_iscsi_client__discovery_auth_username` | '{{ lookup("password", secret + "/iscsi/credentials/discovery/username") }}' | The username for iSCSI discovery authentication. |
| `bootstrap_iscsi_client__discovery_auth_password` | '{{ lookup("password", secret + "/iscsi/credentials/discovery/password") }}' | The password for iSCSI discovery authentication. |
| `bootstrap_iscsi_client__session_auth` | true | Whether to use authentication for iSCSI sessions. |
| `bootstrap_iscsi_client__session_auth_username` | '{{ lookup("password", secret + "/iscsi/credentials/session/username") }}' | The username for iSCSI session authentication. |
| `bootstrap_iscsi_client__session_auth_password` | '{{ lookup("password", secret + "/iscsi/credentials/session/password") }}' | The password for iSCSI session authentication. |
| `bootstrap_iscsi_client__default_options` | See defaults/main.yml | Default options for iSCSI configuration. |
| `bootstrap_iscsi_client__default_fs_type` | ext4 | The default filesystem type for logical volumes. |
| `bootstrap_iscsi_client__default_mount_options` | defaults,_netdev | The default mount options for logical volumes. |
| `bootstrap_iscsi_client__unattended_upgrades__dependent_blocklist` | ['open-iscsi'] | List of packages to block from unattended upgrades. |

## Usage

To use the `bootstrap_iscsi_client` role, include it in your playbook and define the necessary variables. Here is an example playbook:

```yaml
---
- hosts: iscsi_clients
  roles:
    - role: bootstrap_iscsi_client
      vars:
        bootstrap_iscsi_client__portals:
          - "192.168.1.1"
          - "192.168.1.2"
        bootstrap_iscsi_client__targets:
          - target: "iqn.2001-04.com.example:storage.target1"
            login: true
            auth: true
            auth_username: "user"
            auth_password: "password"
            auto: true
        bootstrap_iscsi_client__logical_volumes:
          - vg: "vg0"
            lv: "lv0"
            size: "10G"
            mount: "/mnt/data"
            fs_type: "ext4"
```

## Dependencies

This role depends on the `community.general` collection for certain modules. Ensure that the collection is installed before using this role:

```bash
ansible-galaxy collection install community.general
```

## Best Practices

- Ensure that the iSCSI service is enabled and running on the target systems.
- Use secure methods for storing and retrieving authentication credentials.
- Regularly update the iSCSI packages to benefit from the latest features and security patches.
- Test the configuration in a development environment before deploying it to production.

## Related Files

- [defaults/main.yml](../../roles/bootstrap_iscsi_client/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_iscsi_client/tasks/main.yml)
- [tasks/manage_iscsi_targets.yml](../../roles/bootstrap_iscsi_client/tasks/manage_iscsi_targets.yml)
- [tasks/manage_lvm.yml](../../roles/bootstrap_iscsi_client/tasks/manage_lvm.yml)
- [meta/main.yml](../../roles/bootstrap_iscsi_client/meta/main.yml)
- [handlers/main.yml](../../roles/bootstrap_iscsi_client/handlers/main.yml)