---
title: Bootstrap NFS Service Role Documentation
role: bootstrap_nfs_service
category: Ansible Roles
type: Configuration Management
tags: nfs, firewalld, veeam
---

## Summary

The `bootstrap_nfs_service` role is designed to configure and manage the Network File System (NFS) service on a Linux system. It installs necessary packages, sets up NFS, and configures firewall rules to allow NFS traffic. Additionally, it can be configured to open specific ports required for Veeam backup servers.

## Variables

| Variable Name                 | Default Value                                                                                           | Description                                                                                                                                 |
|-------------------------------|---------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------|
| `is_veeam_backup_server`      | `false`                                                                                                 | A boolean flag indicating whether the server is a Veeam backup server. If true, additional firewall rules for Veeam ports are configured.     |
| `nfs_firewalld_services`      | `[ { name: nfs }, { name: mountd }, { name: rpc-bind } ]`                                                | List of firewalld services to be enabled for NFS.                                                                                          |
| `nfs_firewalld_ports`         | `[ '2049/tcp', '40073/tcp', '40073/udp', '445/tcp', '139/tcp', '2500-50000/udp', '2500-50000/tcp' ]`       | List of firewalld ports to be opened for NFS traffic.                                                                                      |
| `nfs_veeam_firewalld_ports`   | `[ '2500-5000/tcp', '25000-50000/tcp' ]`                                                                | List of additional firewalld ports to be opened if the server is a Veeam backup server.                                                      |

## Usage
To use this role, include it in your playbook and optionally set any of the variables as needed:

```yaml
- hosts: nfs_servers
  roles:
    - role: bootstrap_nfs_service
      vars:
        is_veeam_backup_server: true
```

## Dependencies
This role depends on the following roles:
- `bootstrap_linux_firewalld` (used for configuring firewalld rules)

## Tags
The following tags are available to control which parts of this role are executed:
- `firewall-config-nfs`: Controls the execution of tasks related to firewall configuration.

## Best Practices
- Ensure that the `firewalld_enabled` variable is set correctly in your inventory or playbook to enable or disable firewalld configurations.
- Review and adjust the `nfs_firewalld_ports` and `nfs_veeam_firewalld_ports` variables if your environment requires different port configurations.

## Molecule Tests
This role does not include any Molecule tests at this time. Consider adding tests to ensure the role functions as expected in various environments.

## Backlinks
- [defaults/main.yml](../../roles/bootstrap_nfs_service/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_nfs_service/tasks/main.yml)
- [handlers/main.yml](../../roles/bootstrap_nfs_service/handlers/main.yml)

---