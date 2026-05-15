```markdown
---
title: bootstrap_govc Role Documentation
original_path: roles/bootstrap_govc/README.md
category: Ansible Roles
tags: [vmware, govc, ansible]
---

# bootstrap_govc

## Overview

The `bootstrap_govc` role is designed to install and manage `govc`, a statically linked CLI tool for operations on VMware vCenter servers.

**Source:** [https://github.com/vmware-archive/bootstrap-govc](https://github.com/vmware-archive/bootstrap-govc)

## Requirements

- `gunzip`

## Role Variables

### Setting the Specific Version of the Binary to Install
- **`govc_version`**: Specifies the version of the binary to install.  
  *Example:* `govc_version: "0.12.1"`

### Path to Install the Binary
- **`govc_path`**: Defines where the binary should be installed, either in a user-local path or system-wide path.
  *Example:* `govc_path: /usr/bin`

## Dependencies

While not a true dependency, you might want to install [ansible-role-assets](../ansible-role-assets) to pull a set of OVAs.

## Example Playbook

### Basic Installation
```yaml
- hosts: adminServers
  roles:
    - role: bootstrap_govc
```

### Custom Installation and OVA Import
```yaml
- hosts: adminServers
  roles:
    - role: bootstrap_govc
      vars:
        govc_path: /tmp
        govc_version: "0.12.1"
        
        # ESX or vCenter host and credentials
        govc_host: esx-a.home.local
        govc_username: administrator@home.local
        govc_password: password

        # Alternatively, use govc_url
        # govc_url: https://user:pass@host/sdk

        govc_ova_imports:
          - name: photon01
            ova: /tmp/photon.ova
          - name: photon02
            ova: /tmp/photon.ova
          - name: vcsa
            spec: /tmp/vcsa.json
            ova: /tmp/vcsa.ova
```

## Testing

1. Update `tests/group_vars` to suit your test environment.
2. Create your own set of `vault.yml` files, or replace them with un-encrypted versions for your passwords.

Run the tests using:
```bash
pip install molecule docker-py
./tests/test.sh
```

## Reference

- [https://github.com/vmware-archive/ansible-role-govc](https://github.com/vmware-archive/ansible-role-govc)

## Backlinks

- [Ansible Roles Documentation](../ansible-roles-documentation)
```

This improved Markdown document adheres to clean, professional standards suitable for GitHub rendering while preserving all original information and meaning.