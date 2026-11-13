---
title: "Deploy Vm Role"
role: roles/deploy_vm
category: Roles
type: ansible-role
tags: [ansible, role, deploy_vm]
---

# Deploy VM Role Documentation

## Overview

The `deploy_vm` role is designed to automate the deployment of virtual machines (VMs) on both VMware and Proxmox platforms. It provides a flexible and powerful way to create and configure VMs using Ansible, leveraging the community VMware and Proxmox modules. This role supports various operating systems and configurations, making it suitable for a wide range of use cases.

## Variables

The following table lists the key variables used in this role, along with their default values and descriptions:

### VMware Variables

| Variable Name | Default Value | Description |
| --- | --- | --- |
| `deploy_vm__python_pip_depends` | `['pyVmomi']` | List of Python pip dependencies required for the role. |
| `deploy_vm__vcenter_hostname` | `vcenter.example.int` | The hostname of the vCenter server. |
| `deploy_vm__vcenter_username` | `administrator` | The username for vCenter authentication. |
| `deploy_vm__vcenter_password` | `password` | The password for vCenter authentication. |
| `deploy_vm__vcenter_validate_certs` | `false` | Whether to validate SSL certificates when connecting to vCenter. |
| `deploy_vm__tags_init_all` | List of tag definitions | List of tags to initialize for new VMs. |
| `deploy_vm__vmware_appliance_list` | `[]` | List of VMware appliances to deploy. |
| `deploy_vm__vmware_vm_list` | `[]` | List of VMware VMs to deploy. |
| `deploy_vm__govc_version` | `0.23.0` | The version of govc to install. |
| `deploy_vm__govc_path` | `/usr/local/bin` | The path where govc will be installed. |
| `deploy_vm__govc_file` | `{{deploy_vm__govc_path}}/govc` | The full path to the govc binary. |
| `deploy_vm__govc_host` | `{{ deploy_vm__vcenter_hostname }}` | The hostname for govc to connect to. |
| `deploy_vm__govc_username` | `{{ deploy_vm__vcenter_username }}` | The username for govc authentication. |
| `deploy_vm__govc_password` | `{{ deploy_vm__vcenter_password }}` | The password for govc authentication. |
| `deploy_vm__govc_insecure` | `1` | Whether to use insecure connections with govc. |
| `deploy_vm__govc_environment` | Dictionary of environment variables | Environment variables for govc. |
| `deploy_vm__create_async_delay` | `30` | Delay between async retries when creating VMs. |
| `deploy_vm__create_async_retries` | `1000` | Number of retries for async VM creation. |
| `deploy_vm__template_info` | Dictionary of template information | Information about available VM templates. |

### Proxmox Variables

| Variable Name | Default Value | Description |
| --- | --- | --- |
| `deploy_vm__proxmox_api_url` | `https://proxmox.example.int:8006/api2/json` | The API URL for the Proxmox server. |
| `deploy_vm__proxmox_username` | `root` | The username for Proxmox authentication. |
| `deploy_vm__proxmox_password` | `password` | The password for Proxmox authentication. |
| `deploy_vm__proxmox_node` | `pve` | The Proxmox node to deploy VMs on. |
| `deploy_vm__proxmox_storage` | `local-lvm` | The storage to use for VM disks. |
| `deploy_vm__proxmox_network` | `vmbr0` | The network bridge to use for VMs. |
| `deploy_vm__proxmox_vm_list` | `[]` | List of Proxmox VMs to deploy. |

## Usage

### VMware Example

```yaml
---
- hosts: localhost
  roles:
    - role: deploy_vm
      vars:
        deploy_vm__vmware_vm_list:
          - name: my-vm
            template: ubuntu24
            datacenter: my-datacenter
            cluster: my-cluster
            resource_pool: my-resource-pool
            datastore: my-datastore
            networks:
              - name: my-network
                ip: 192.168.1.100
                netmask: 255.255.255.0
                gateway: 192.168.1.1
                dns_servers:
                  - 8.8.8.8
                  - 8.8.4.4
```

### Proxmox Example

```yaml
---
- hosts: localhost
  roles:
    - role: deploy_vm
      vars:
        deploy_vm__proxmox_vm_list:
          - name: my-proxmox-vm
            template: ubuntu24
            storage: local-lvm
            network: vmbr0
            ip_config:
              ip: 192.168.1.101
              gateway: 192.168.1.1
              netmask: 255.255.255.0
              dns:
                - 8.8.8.8
                - 8.8.4.4
```

## Dependencies

This role requires the following Ansible collections:

- `community.vmware`
- `community.general`
- `community.proxmox`

You can install these collections using the following commands:

```bash
ansible-galaxy collection install community.vmware
ansible-galaxy collection install community.general
ansible-galaxy collection install community.proxmox
```

## Best Practices

1. **Use Inventory Variables**: Define VM-specific variables in your inventory to keep your playbooks clean and maintainable.
2. **Leverage Tags**: Use Ansible tags to control which parts of the role are executed.
3. **Secure Credentials**: Use Ansible Vault to secure sensitive information like passwords.
4. **Test Thoroughly**: Test your playbooks in a development environment before applying them to production.
5. **Document Your Configurations**: Keep clear documentation of your VM configurations and deployment processes.

## Additional Resources

- [VMware Ansible Modules Documentation](https://docs.ansible.com/ansible/latest/collections/community/vmware/index.html)
- [Proxmox Ansible Modules Documentation](https://docs.ansible.com/ansible/latest/collections/community/proxmox/index.html)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/best_practices.html)

## License

This role is licensed under the MIT License. See the [LICENSE](https://opensource.org/licenses/MIT) file for details.

## Author Information

This role was created by [Your Name or Organization].