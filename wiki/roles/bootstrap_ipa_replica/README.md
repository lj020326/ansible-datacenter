```markdown
---
title: IPA Replica Role Documentation
original_path: roles/bootstrap_ipa_replica/README.md
category: Ansible Roles
tags: [ipa, replica, ansible, freeipa]
---

# IPA Replica Role

## Description

This role configures a new IPA server that acts as a replica of an existing IPA server. Once deployed, the replica is an exact copy of the original IPA server and functions as an equal controller. Changes made to any controller are automatically replicated to other controllers.

**Note**: The Ansible playbooks and role require a configured Ansible environment where nodes are reachable, have an IP address, and a working package manager.

## Features

- Replica deployment

## Supported FreeIPA Versions

FreeIPA versions 4.6 and above are supported by the replica role.

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

### Example Inventory File with Auto-discovery

```ini
[ipareplicas]
ipareplica1.example.com
ipareplica2.example.com

[ipareplicas:vars]
ipaadmin_principal=admin
```

### Example Playbook to Setup IPA Replicas

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

### Example Playbook to Setup IPA Replicas with Username/Password

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

**Note**: Additional options are needed if the removal of the replica results in a topology disconnect or if the replica is the last with a specific role.

- To continue with the removal with a topology disconnect:

```ini
ipareplica_ignore_topology_disconnect=true
ipareplica_remove_on_server=ipareplica2.example.com
```

- To continue with the removal for a replica that is the last with a role:

```ini
ipareplica_ignore_last_of_role=true
```

**Caution**: Enabling `ipareplica_ignore_topology_disconnect` and especially `ipareplica_ignore_last_of_role` can result in irreversible changes.

## Playbooks

The playbooks needed to deploy or undeploy a replica are part of the repository in the `playbooks` folder. There are also playbooks to deploy and undeploy clusters:

- `install-replica.yml`
- `uninstall-replica.yml`

Please remember to link or copy the playbooks to the base directory of `ansible-freeipa` if you want to use the roles within the source archive.

## How to Setup Replicas

```bash
ansible-playbook -v -i inventory/hosts install-replica.yml
```

This command deploys the replicas defined in the inventory file.

## Variables

### Base Variables

| Variable                      | Description                                                                                         | Required |
|-------------------------------|-----------------------------------------------------------------------------------------------------|----------|
| `ipaservers`                  | List of IPA controller fully qualified hostnames.                                                   | Mostly   |
| `ipareplicas`                 | Group of IPA replica hostnames.                                                                     | Yes      |
| `ipaadmin_password`           | Password for the IPA admin user.                                                                    | Mostly   |
| `ipareplica_ip_addresses`     | List of controller server IP addresses.                                                             | No       |
| `ipareplica_domain`           | Primary DNS domain of an existing IPA deployment.                                                   | No       |
| `ipaserver_realm`             | Kerberos realm of an existing IPA deployment.                                                       | No       |
| `ipaserver_hostname`          | Fully qualified name of the server.                                                                 | No       |
| `ipaadmin_principal`          | Authorized Kerberos principal used to join the IPA realm.                                           | No       |
| `ipareplica_no_host_dns`      | Do not use DNS for hostname lookup during installation.                                             | No       |
| `ipareplica_skip_conncheck`   | Skip connection check to remote controller.                                                         | No       |
| `ipareplica_pki_config_override` | Path to ini file with config overrides (usable with recent FreeIPA versions).                  | No       |
| `ipareplica_mem_check`        | Check for minimum required memory for deployment (ignored in FreeIPA versions before 4.8.10).       | No       |

### Server Variables

| Variable                      | Description                                                                                         | Required |
|-------------------------------|-----------------------------------------------------------------------------------------------------|----------|
| `ipadm_password`              | Password for the Directory Manager.                                                                 | Mostly   |
| `ipareplica_hidden_replica`   | Install as a hidden replica (not visible in DNS).                                                   | No       |

## Backlinks

- [Ansible Roles Documentation](/ansible-roles)
- [FreeIPA Documentation](https://www.freeipa.org/page/Main_Page)

```

This improved Markdown document adheres to clean, professional standards suitable for GitHub rendering while maintaining all original information and meaning.