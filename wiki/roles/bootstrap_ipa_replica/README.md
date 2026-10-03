---
title: ipareplica Role
original_path: roles/bootstrap_ipa_replica/README.md
category: Ansible
tags: [IPA, Replica, FreeIPA, Ansible]
---

# ipareplica Role

## Description

This role allows configuring a new IPA server as a replica of an existing server. Once created, the replica is an exact copy of the original IPA server and functions as an equal controller. Changes made to any controller are automatically replicated to other controllers.

This can be done in different ways using auto-discovery of the servers, domain, and other settings, or by specifying them explicitly.

**Note:** The Ansible playbooks and role require a configured Ansible environment where the Ansible nodes are reachable and properly set up with an IP address and a working package manager.

## Features

- Replica deployment

## Supported FreeIPA Versions

FreeIPA versions 4.6 and up are supported by the replica role.

## Supported Distributions

- RHEL/CentOS 7.6+
- CentOS Stream 8+
- Fedora 26+
- Ubuntu 16.04 and 18.04

## Requirements

### Controller

- Ansible version: 2.13+

### Node

- Supported FreeIPA version (see above)
- Supported distribution (needed for package installation only, see above)

## Usage

### Example Inventory File with Auto-Discovery Using DNS Records

```ini
[ipareplicas]
ipareplica1.example.com
ipareplica2.example.com

[ipareplicas:vars]
ipaadmin_principal=admin
```

### Example Playbook to Configure IPA Replicas

```yaml
---
- name: Playbook to configure IPA replicas
  hosts: ipareplicas
  become: true
  vars_files:
  - playbook_sensitive_data.yml

  roles:
  - role: ipareplica
    state: present
```

### Example Playbook to Unconfigure IPA Replicas

```yaml
---
- name: Playbook to unconfigure IPA replicas
  hosts: ipareplicas
  become: true

  roles:
  - role: ipareplica
    state: absent
```

### Example Inventory File with Fixed Server, Principal, Password, and Domain

```ini
[ipaserver]
ipaserver.example.com

[ipareplicas]
ipareplica1.example.com
ipareplica2.example.com

[ipareplicas:vars]
ipareplica_domain=example.com
ipaadmin_principal=admin
ipaadmin_password=MySecretPassword123
ipadm_password=MySecretPassword456
```

### Example Playbook to Configure IPA Replicas with Username/Password

```yaml
---
- name: Playbook to configure IPA replicas with username/password
  hosts: ipareplicas
  become: true

  roles:
  - role: ipareplica
    state: present
```

### Example Inventory File to Remove a Replica from the Domain

```ini
[ipareplicas]
ipareplica1.example.com

[ipareplicas:vars]
ipaadmin_password=MySecretPassword123
ipareplica_remove_from_domain=true
```

### Example Playbook to Remove an IPA Replica

```yaml
---
- name: Playbook to remove IPA replica
  hosts: ipareplica
  become: true

  roles:
  - role: ipareplica
    state: absent
```

### Handling Topology Disconnects or Last Role Replicas

To continue with the removal with a topology disconnect, set these parameters:

```ini
ipareplica_ignore_topology_disconnect=true
ipareplica_remove_on_server=ipareplica2.example.com
```

To continue with the removal for a replica that is the last that has a role:

```ini
ipareplica_ignore_last_of_role=true
```

**Caution:** Enabling `ipareplica_ignore_topology_disconnect` and especially `ipareplica_ignore_last_of_role` can have significant consequences and cannot be easily reverted. The parameters `ipaserver_ignore_topology_disconnect`, `ipaserver_ignore_last_of_role`, `ipaserver_remove_on_server`, and `ipaserver_remove_from_domain` can be used instead.

## Playbooks

The playbooks needed to deploy or undeploy a replica are part of the repository in the playbooks folder. There are also playbooks to deploy and undeploy clusters.

```
install-replica.yml
uninstall-replica.yml
```

Please remember to link or copy the playbooks to the base directory of ansible-freeipa if you want to use the roles within the source archive.

## How to Setup Replicas

```bash
ansible-playbook -v -i inventory/hosts install-replica.yml
```

This will deploy the replicas defined in the inventory file.

## Variables

### Base Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `ipaservers` | This group with the IPA controller fully qualified hostnames. (list of strings) | mostly |
| `ipareplicas` | Group of IPA replica hostnames. (list of strings) | yes |
| `ipaadmin_password` | The password for the IPA admin user (string) | mostly |
| `ipareplica_ip_addresses` | The list of controller server IP addresses. (list of strings) | no |
| `ipareplica_domain` | The primary DNS domain of an existing IPA deployment. (string) | no |
| `ipaserver_realm` | The Kerberos realm of an existing IPA deployment. (string) | no |
| `ipaserver_hostname` | Fully qualified name of the server. (string) | no |
| `ipaadmin_principal` | The authorized Kerberos principal used to join the IPA realm. (string) | no |
| `ipareplica_no_host_dns` | Do not use DNS for hostname lookup during installation. (bool, default: false) | no |
| `ipareplica_skip_conncheck` | Skip connection check to remote controller. (bool, default: false) | no |
| `ipareplica_pki_config_override` | Path to ini file with config overrides. This is only usable with recent FreeIPA versions. (string) | no |
| `ipareplica_mem_check` | Checking for minimum required memory for the deployment. This is only usable with recent FreeIPA versions (4.8.10+) else ignored. (bool, default: yes) | no |

### Server Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `ipadm_password` | The password for the Directory Manager. (string) | mostly |

## Backlinks

[Link to related documentation or pages if applicable]