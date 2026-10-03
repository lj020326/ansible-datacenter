---
harvested_date: '2023-10-07T18:07:09.222969+00:00'
original_path: roles/bootstrap_govc/README.md
source_type: markdown
title: bootstrap_govc
category: Ansible Roles
tags: [govc, VMware, vCenter]
---

# bootstrap_govc

Install and manage `govc`, a statically linked CLI tool for operations on VMware vCenter server. `govc` is a command-line tool that simplifies many VMware vSphere operations.

Source: [https://github.com/vmware-archive/bootstrap-govc](https://github.com/vmware-archive/bootstrap-govc)

## Requirements

- `gunzip`

## Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `govc_version` | Specifies the version of the binary to install | `"0.12.1"` |
| `govc_path` | Path to install the binary. Can be used to install to user local path or system-wide path | `/usr/bin` |
| `govc_url` | URL for govc binary download (optional, alternative to version) | `""` |

## Dependencies

While not a strict dependency, it is recommended to install [ansible-role-assets](../ansible-role-assets) to pull a set of OVAs.

## Example Playbook

### Basic Installation

```yaml
---
- hosts: adminServers
  roles:
    - role: bootstrap_govc
```

### Custom Installation with OVA Imports

```yaml
---
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

1. Update the `tests/group_vars` to suit your test environment.
2. Create your own set of `vault.yml` files or replace them with un-encrypted versions for your passwords.
3. Run the tests:

```bash
pip install molecule docker-py
./tests/test.sh
```

## Reference

- [https://github.com/vmware-archive/bootstrap-govc](https://github.com/vmware-archive/bootstrap-govc)
- [https://github.com/vmware-archive/ansible-role-govc](https://github.com/vmware-archive/ansible-role-govc)

## Additional Resources

- [govc documentation](https://github.com/vmware/govmomi/tree/main/govc)
- [VMware vSphere API documentation](https://code.vmware.com/apis/1021/vsphere-automation-sdk)