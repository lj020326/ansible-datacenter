```markdown
---
title: IPA Client Role Documentation
original_path: roles/bootstrap_ipa_client/README.md
category: Ansible Roles
tags: [ipaclient, ansible, freeipa, client-deployment]
---

# IPA Client Role

This [Ansible](https://www.ansible.com/) role allows hosts to join an IPA domain as clients. This can be done using auto-discovery of servers, domains, and other settings or by specifying them manually.

**Note**: The Ansible playbooks and role require a configured Ansible environment where the nodes are reachable and properly set up with an IP address and working package manager.

## Features

- Client deployment
- One-time-password (OTP) support
- Repair mode
- DNS resolver configuration support

## Supported FreeIPA Versions

FreeIPA versions 4.5 and above are supported by this client role. There is also limited support for version 4.4.

## Supported Distributions

- RHEL/CentOS 7.4+
- CentOS Stream 8+
- Fedora 26+
- Ubuntu
- Debian

## Requirements

### Controller

- Ansible version: 2.13+

### Node

- Supported FreeIPA version (see above)
- Supported distribution (required for package installation only, see above)

## Usage

### Example Inventory File with Auto-discovery

```ini
[ipaclients]
ipaclient1.example.com
ipaclient2.example.com

[ipaclients:vars]
ipaadmin_principal=admin
```

### Example Playbook to Setup IPA Clients with Username/Password

```yaml
- name: Configure IPA clients with username/password
  hosts: ipaclients
  become: true
  vars_files:
    - playbook_sensitive_data.yml

  roles:
    - role: ipaclient
      state: present
```

### Example Playbook to Unconfigure IPA Clients

```yaml
- name: Unconfigure IPA clients
  hosts: ipaclients
  become: true

  roles:
    - role: ipaclient
      state: absent
```

### Example Inventory File with Fixed Servers, Principal, Password, and Domain

```ini
[ipaclients]
ipaclient1.example.com
ipaclient2.example.com

[ipaservers]
ipaserver.example.com

[ipaclients:vars]
ipaclient_domain=example.com
ipaadmin_principal=admin
ipaadmin_password=MySecretPassword123
```

### Example Inventory File with DNS Resolver Configuration

```ini
[ipaclients]
ipaclient1.example.com
ipaclient2.example.com

[ipaservers]
ipaserver.example.com

[ipaclients:vars]
ipaadmin_principal=admin
ipaadmin_password=MySecretPassword123
ipaclient_domain=example.com
ipaclient_configure_dns_resolver=yes
ipaclient_dns_servers=192.168.100.1
```

### Example Inventory File with DNS Resolver Cleanup

```ini
[ipaclients]
ipaclient1.example.com
ipaclient2.example.com

[ipaservers]
ipaserver.example.com

[ipaclients:vars]
ipaadmin_principal=admin
ipaadmin_password=MySecretPassword123
ipaclient_domain=example.com
ipaclient_cleanup_dns_resolver=yes
```

## Playbooks

The playbooks needed to deploy or undeploy a client are part of the repository in the `playbooks` folder. There are also playbooks to deploy and undeploy clusters.

- `install-client.yml`
- `uninstall-client.yml`

Please remember to link or copy these playbooks to the base directory of `ansible-freeipa` if you want to use the roles within the source archive.

## How to Setup a Client

```bash
ansible-playbook -v -i inventory/hosts install-client.yml
```

This command will deploy the clients defined in the inventory file.

## Variables

### Base Variables

| Variable                      | Description                                                                                             | Required |
|-------------------------------|---------------------------------------------------------------------------------------------------------|----------|
| `ipaclients`                  | List of IPA client names in FQDN form. All these clients will be installed or configured using the playbook. | yes      |
| `ipaclient_domain`            | DNS domain used for client installation. Usually, it is a lower-cased name of the Kerberos realm.         | no       |
| `ipaclient_realm`             | Kerberos realm used for client installation. Usually, it is an upper-cased name of the DNS domain.        | no       |
| `ipaclient_mkhomedir`         | Configures PAM to create a user's home directory if it does not exist. Defaults to `no`.                 | no       |
| `ipaclient_force_join`        | Allows already enrolled hosts to join again. Defaults to `no`.                                            | no       |
| `ipaclient_kinit_attempts`    | Number of retries for failed host Kerberos ticket requests. Defaults to 5.                              | no       |
| `ipaclient_ntp_servers`       | List of NTP servers to be used.                                                                         | no       |
| `ipaclient_ntp_pool`          | NTP server pool to be used.                                                                             | no       |
| `ipaclient_no_ntp`            | Disables NTP configuration and enabling. Defaults to `no`.                                              | no       |
| `ipaclient_ssh_trust_dns`     | Configures OpenSSH client to trust DNS SSHFP records. Defaults to `no`.                                 | no       |
| `ipaclient_no_ssh`            | Disables OpenSSH client configuration. Defaults to `no`.                                                | no       |
| `ipaclient_no_sshd`           | Disables OpenSSH server configuration. Defaults to `no`.                                                | no       |
| `ipaclient_no_sudo`           | Disables SSSD sudo configuration.                                                                       | no       |

## Backlinks

- [Ansible Roles](../ansible_roles.md)
```

This improved Markdown document is structured clearly, uses proper headings, and includes a YAML frontmatter with additional metadata for better organization and rendering on GitHub.