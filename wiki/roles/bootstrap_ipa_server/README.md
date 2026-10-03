---
harvested_date: '2026-08-07T18:07:09.245397+00:00'
original_path: roles/bootstrap_ipa_server/README.md
source_type: legacy_markdown
title: IPA Server Role Documentation
category: Ansible Role
tags:
  - FreeIPA
  - IPA Server
  - Ansible
  - RHEL
  - CentOS
  - Fedora
  - Ubuntu
  - Ansible Role: IPA Server
---

# IPA Server Role Documentation

## Table of Contents
- [Description](#description)
- [Features](#features)
- [Supported FreeIPA Versions](#supported-freeipa-versions)
- [Supported Distributions](#supported-distributions)
- [Requirements](#requirements)
- [Limitations](#limitations)
- [Usage](#usage)
- [Example Inventory Files](#example-inventory-files)
- [Example Playbooks](#example-playbooks)
- [Parameters for Special Cases](#parameters-for-special-cases)
- [Playbooks](#playbooks)
- [Default Variables](#default-variables)
- [Return Values](#return-values)
- [Dependencies](#dependencies)
- [License](#license)
- [Author Information](#author-information)
- [Troubleshooting](#troubleshooting)
- [Related Documentation](#related-documentation)
- [Changelog](#changelog)

## Description

This role configures and manages an IPA server.

**Note:** The Ansible playbooks and role require a configured Ansible environment where the Ansible nodes are reachable and properly set up with an IP address and a working package manager.

## Features

- Server deployment

## Supported FreeIPA Versions

FreeIPA versions 4.5 and above are supported by this role. There is no known maximum supported version at this time.

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
- Supported distribution (required for package installation, see above)

## Limitations

### External Signed CA

External signed CA is supported, but the current two-step process is cumbersome for simple playbooks. Work is planned to introduce a new method to handle CSR for external signed CAs in a separate step before starting the server installation. No specific timeline is available for this enhancement.

## Usage

This section provides an overview of how to use the IPA Server role. For specific examples, see the sections below.

## Example Inventory Files

### Example Inventory File with Fixed Domain and Realm

```ini
[ipaserver]
ipaserver2.example.com

[ipaserver:vars]
ipaserver_domain=example.com
ipaserver_realm=EXAMPLE.COM
ipaserver_setup_dns=yes
ipaserver_auto_forwarders=yes
```

### Example Inventory File with Fixed Domain, Realm, Admin, and Dirman Passwords

```ini
[ipaserver]
ipaserver.example.com

[ipaserver:vars]
ipaserver_domain=example.com
ipaserver_realm=EXAMPLE.COM
ipaadmin_password=MySecretPassword123
ipadm_password=MySecretPassword234
```

### Example Inventory File to Deploy a Server with Random Serial Numbers Enabled

```ini
[ipaserver]
ipaserver.example.com

[ipaserver:vars]
ipaserver_domain=example.com
ipaserver_realm=EXAMPLE.COM
ipaadmin_password=MySecretPassword123
ipadm_password=MySecretPassword234
ipaserver_random_serial_numbers=true
```

### Example Inventory File to Remove a Server from the Domain

```ini
[ipaserver]
ipaserver.example.com

[ipaserver:vars]
ipaadmin_password=MySecretPassword123
ipaserver_remove_from_domain=true
```

## Example Playbooks

### Example Playbook to Configure IPA Server Using Admin and Dirman Passwords from Ansible Vault

```yaml
---
- name: Playbook to configure IPA server
  hosts: ipaserver
  become: true
  vars_files:
  - playbook_sensitive_data.yml

  roles:
  - role: ipaserver
    state: present
```

### Example Playbook to Unconfigure IPA Server Using Principal and Password from Inventory File

```yaml
---
- name: Playbook to unconfigure IPA server
  hosts: ipaserver
  become: true

  roles:
  - role: ipaserver
    state: absent
```

### Example Playbook to Configure IPA Server Using Admin and Dirman Passwords from Inventory File

```yaml
---
- name: Playbook to configure IPA server
  hosts: ipaserver
  become: true

  roles:
  - role: ipaserver
    state: present
```

### Example Playbook to Remove an IPA Server Using Admin Passwords from the Domain

```yaml
---
- name: Playbook to remove IPA server
  hosts: ipaserver
  become: true

  roles:
  - role: ipaserver
    state: absent
```

## Parameters for Special Cases

### Parameters for Topology Disconnect

```ini
ipaserver_ignore_topology_disconnect=true
ipaserver_remove_on_server=ipaserver2.example.com
```

**Note:** Be careful with enabling `ipaserver_ignore_topology_disconnect` as these changes cannot be easily reverted.

### Parameters for Last Role Server

```ini
ipaserver_ignore_last_of_role=true
```

**Note:** Be especially careful with enabling `ipaserver_ignore_last_of_role` as these changes cannot be easily reverted.

## Playbooks

The playbooks needed to deploy or undeploy a server are part of the repository in the playbooks folder. There are also playbooks to deploy and undeploy replicas. For specific examples, see the sections above.

## Default Variables

[Document default variables here]

## Return Values

[Document return values here]

## Dependencies

[Document any dependencies here]

## License

[Provide license information here]

## Author Information

[Provide author information here]

## Troubleshooting

[Provide troubleshooting tips here]

## Related Documentation

[Add links to related documentation pages if applicable]

## Changelog

[Document changes to the role here]