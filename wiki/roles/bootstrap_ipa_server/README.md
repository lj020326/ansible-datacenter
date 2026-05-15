```markdown
---
title: ipaserver Role Documentation
original_path: roles/bootstrap_ipa_server/README.md
category: Ansible Roles
tags: [ipa-server, ansible, freeipa, configuration]
---

# ipaserver Role

## Description

This role allows the configuration and deployment of an IPA server.

**Note**: The Ansible playbooks and role require a configured Ansible environment where the Ansible nodes are reachable and properly set up with an IP address and a working package manager.

## Features

- Server deployment

## Supported FreeIPA Versions

FreeIPA versions 4.5 and above are supported by this role.

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

## Limitations

**External Signed CA**
External signed CAs are now supported; however, the current two-step process is an issue for handling CSRs in a simple playbook.

Work is planned to introduce a new method to handle CSR generation and signing for external CAs before starting the server installation.

# Usage

## Example Inventory File

### Fixed Domain and Realm with DNS Setup
```ini
[ipaserver]
ipaserver2.example.com

[ipaserver:vars]
ipaserver_domain=example.com
ipaserver_realm=EXAMPLE.COM
ipaserver_setup_dns=yes
ipaserver_auto_forwarders=yes
```

## Example Playbooks

### Configure IPA Server with Passwords from Ansible Vault
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

### Unconfigure IPA Server with Principal and Password from Inventory File
```yaml
---
- name: Playbook to unconfigure IPA server
  hosts: ipaserver
  become: true

  roles:
    - role: ipaserver
      state: absent
```

### Configure IPA Server with Passwords from Inventory File
```yaml
---
- name: Playbook to configure IPA server
  hosts: ipaserver
  become: true

  roles:
    - role: ipaserver
      state: present
```

### Setup IPA Primary with External Signed CA (Step 1)
Generate CSR, copy to controller as `<ipaserver hostname>-ipa.csr`
```yaml
---
- name: Playbook to configure IPA server step1
  hosts: ipaserver
  become: true
  vars:
    ipaserver_external_ca: yes

  roles:
    - role: ipaserver
      state: present

  post_tasks:
    - name: Copy CSR /root/ipa.csr from node to "{{ groups.ipaserver[0] + '-ipa.csr' }}"
      fetch:
        src: /root/ipa.csr
        dest: "{{ groups.ipaserver[0] + '-ipa.csr' }}"
        flat: yes
```

### Setup IPA Primary with External Signed CA (Step 2)
Copy `<ipaserver hostname>-chain.crt` to the IPA server and continue installation.
```yaml
---
- name: Playbook to configure IPA server step3
  hosts: ipaserver
  become: true
  vars:
    ipaserver_external_cert_files: "/root/chain.crt"

  pre_tasks:
    - name: Copy "{{ groups.ipaserver[0] + '-chain.crt' }}" to /root/chain.crt on node
      ansible.builtin.copy:
        src: "{{ groups.ipaserver[0] + '-chain.crt' }}"
        dest: "/root/chain.crt"
        force: yes

  roles:
    - role: ipaserver
      state: present
```

### Deploy Server with Random Serial Numbers Enabled
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

### Remove IPA Server from Domain
```ini
[ipaserver]
ipaserver.example.com

[ipaserver:vars]
ipaadmin_password=MySecretPassword123
ipaserver_remove_from_domain=true
```

#### Additional Options for Removal
- **Ignore Topology Disconnect**
  ```ini
  ipaserver_ignore_topology_disconnect=true
  ipaserver_remove_on_server=ipaserver2.example.com
  ```

- **Ignore Last of Role**
  ```ini
  ipaserver_ignore_last_of_role=true
  ```

**Caution**: Enabling `ipaserver_ignore_topology_disconnect` and especially `ipaserver_ignore_last_of_role` can result in irreversible changes.

# Playbooks

The playbooks needed to deploy or undeploy a server are part of the repository in the `playbooks` folder. Additional playbooks for specific tasks are also available.

# Backlinks
- [Ansible Roles Documentation](../ansible_roles.md)
```

This improved documentation is structured clearly, uses proper Markdown formatting, and includes additional metadata in the YAML frontmatter for better organization and categorization on GitHub.