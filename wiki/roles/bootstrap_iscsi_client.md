---
title: "Ansible Role Documentation"
role: bootstrap_iscsi_client
category: Storage Management
type: Configuration
tags: iscsi, storage, networking
---

## Summary

The `bootstrap_iscsi_client` Ansible role manages the configuration of an iSCSI initiator on a target system. It handles the installation and setup of necessary packages, configures iSCSI initiator settings, discovers and logs into specified iSCSI targets, and manages LVM (Logical Volume Manager) to create and mount filesystems on discovered devices.

## Variables

| Variable Name                                      | Default Value                                                                                           | Description                                                                                                                                                                                                 |
|----------------------------------------------------|---------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_iscsi_client__target_port`              | `"3260"`                                                                                                | The default port used for iSCSI communication.                                                                                                                                                              |
| `bootstrap_iscsi_client__system_info`              | See `defaults/main.yml`                                                                                 | System-specific information including service names and packages required for Debian and RedHat-based systems.                                                                                                  |
| `bootstrap_iscsi_client__interfaces`               | `[]`                                                                                                    | List of network interfaces to be used by the iSCSI initiator.                                                                                                                                                 |
| `bootstrap_iscsi_client__portals`                  | `[]`                                                                                                    | List of iSCSI target portals (IP addresses) to discover and connect to.                                                                                                                                       |
| `bootstrap_iscsi_client__targets`                  | `[]`                                                                                                    | List of iSCSI targets to log into, including authentication details if required.                                                                                                                              |
| `bootstrap_iscsi_client__logical_volumes`          | `[]`                                                                                                    | Configuration for LVM logical volumes, filesystems, and mount points.                                                                                                                                         |
| `bootstrap_iscsi_client__iqn_date`                 | `"{{ ansible_facts['date_time']['year'] }}-{{ ansible_facts['date_time']['month'] }}"`                     | Date component of the iSCSI initiator IQN (iSCSI Qualified Name).                                                                                                                                           |
| `bootstrap_iscsi_client__iqn_authority`            | `"{{ ansible_domain }}"`                                                                                | Authority component of the iSCSI initiator IQN, typically derived from the domain name.                                                                                                                       |
| `bootstrap_iscsi_client__iqn`                      | Calculated based on `ansible_local.iscsi.iqn`, `bootstrap_iscsi_client__iqn_date`, and `bootstrap_iscsi_client__iqn_authority` | The iSCSI initiator IQN, used to uniquely identify the initiator.                                                                                                                                             |
| `bootstrap_iscsi_client__hostname`                 | `"{{ ansible_facts['hostname'] }}"`                                                                      | The hostname of the system, used as part of the iSCSI initiator name.                                                                                                                                         |
| `bootstrap_iscsi_client__initiator_name`           | Calculated based on `bootstrap_iscsi_client__iqn` and `bootstrap_iscsi_client__hostname`                  | The full iSCSI initiator name, combining IQN and hostname.                                                                                                                                                  |
| `bootstrap_iscsi_client__enabled`                  | `true`                                                                                                  | Whether the iSCSI service should be enabled and started automatically.                                                                                                                                        |
| `bootstrap_iscsi_client__node_startup`             | `"automatic"`                                                                                           | The startup mode for iSCSI nodes (e.g., automatic, manual).                                                                                                                                                   |
| `bootstrap_iscsi_client__discovery_auth`           | `true`                                                                                                  | Whether to use CHAP authentication for discovery.                                                                                                                                                             |
| `bootstrap_iscsi_client__discovery_auth_username`  | Looked up from a password file                                                                          | Username for iSCSI discovery authentication using CHAP.                                                                                                                                                       |
| `bootstrap_iscsi_client__discovery_auth_password`  | Looked up from a password file                                                                          | Password for iSCSI discovery authentication using CHAP.                                                                                                                                                       |
| `bootstrap_iscsi_client__session_auth`             | `true`                                                                                                  | Whether to use CHAP authentication for sessions.                                                                                                                                                              |
| `bootstrap_iscsi_client__session_auth_username`    | Looked up from a password file                                                                          | Username for iSCSI session authentication using CHAP.                                                                                                                                                         |
| `bootstrap_iscsi_client__session_auth_password`    | Looked up from a password file                                                                          | Password for iSCSI session authentication using CHAP.                                                                                                                                                         |
| `bootstrap_iscsi_client__default_options`          | See `defaults/main.yml`                                                                                 | Default options for iSCSI initiator configuration, including discovery and session authentication settings.                                                                                                     |
| `bootstrap_iscsi_client__default_fs_type`          | `"ext4"`                                                                                                | The default filesystem type to be used when creating new filesystems on LVM logical volumes.                                                                                                                   |
| `bootstrap_iscsi_client__default_mount_options`    | `"defaults,_netdev"`                                                                                    | Default mount options for filesystems created by this role.                                                                                                                                                   |
| `bootstrap_iscsi_client__unattended_upgrades__dependent_blocklist` | `["open-iscsi"]`                                                                                      | List of packages to be blocked from unattended upgrades, in this case, the iSCSI package.                                                                                                                    |

## Usage

To use the `bootstrap_iscsi_client` role, include it in your playbook and provide necessary variables as per your environment configuration.

### Example Playbook

```yaml
- name: Configure iSCSI Initiator
  hosts: iscsi_clients
  become: yes
  roles:
    - role: bootstrap_iscsi_client
      vars:
        bootstrap_iscsi_client__portals:
          - "192.168.1.100"
          - "192.168.1.101"
        bootstrap_iscsi_client__targets:
          - target: "iqn.2023-04.example.com:target1"
            login: true
            auth: true
            auth_username: "chap_user"
            auth_password: "chap_pass"
        bootstrap_iscsi_client__logical_volumes:
          - vg: "vg_data"
            lv: "lv_data"
            size: "10G"
            mount: "/mnt/data"
```

## Dependencies

- `community.general` collection (for `open_iscsi`, `lvol`, and `lvg` modules)

Ensure that the required collections are installed:

```bash
ansible-galaxy collection install community.general
```

## Tags

The following tags can be used to control which parts of the role are executed:

- `iscsi_packages`: Manage iSCSI packages installation.
- `iscsi_initiator`: Configure iSCSI initiator settings.
- `iscsi_discovery`: Discover and log into iSCSI targets.
- `lvm_management`: Manage LVM volume groups, logical volumes, filesystems, and mount points.

## Best Practices

- Ensure that the iSCSI target portals and credentials are correctly configured to avoid connectivity issues.
- Use secure methods for storing and accessing sensitive information such as CHAP usernames and passwords.
- Regularly update the role and its dependencies to benefit from security patches and improvements.

## Molecule Tests

This role does not include Molecule tests. However, it is recommended to create test scenarios using Molecule to ensure the role functions correctly across different environments.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_iscsi_client/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_iscsi_client/tasks/main.yml)
- [tasks/manage_iscsi_targets.yml](../../roles/bootstrap_iscsi_client/tasks/manage_iscsi_targets.yml)
- [tasks/manage_lvm.yml](../../roles/bootstrap_iscsi_client/tasks/manage_lvm.yml)
- [meta/main.yml](../../roles/bootstrap_iscsi_client/meta/main.yml)
- [handlers/main.yml](../../roles/bootstrap_iscsi_client/handlers/main.yml)