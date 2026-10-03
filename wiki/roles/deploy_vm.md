---
title: "Deploy Vm Role"
role: roles/deploy_vm
category: Roles
type: ansible-role
tags: [ansible, role, deploy_vm]
---

# Deploy VM Role Documentation

## Purpose

The `deploy_vm` role is designed to automate the deployment and configuration of virtual machines (VMs) on VMware vSphere and Proxmox platforms. This role provides a comprehensive set of tasks to create, configure, and manage VMs, ensuring consistent and repeatable deployments.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `deploy_vm__python_pip_depends` | `['pyVmomi']` | List of Python pip dependencies required for the role. |
| `deploy_vm__vcenter_hostname` | `vcenter.example.int` | The hostname of the vCenter server. |
| `deploy_vm__vcenter_username` | `administrator` | The username for vCenter authentication. |
| `deploy_vm__vcenter_password` | `password` | The password for vCenter authentication. |
| `deploy_vm__vcenter_validate_certs` | `false` | Whether to validate SSL certificates when connecting to vCenter. |
| `deploy_vm__tags_init_all` | `[{'tag_name': 'vm_pre_bootstrap', 'tag_description': 'New VM prior to OS bootstrap play'}, {'tag_name': 'vm_new', 'tag_description': 'New VM'}, {'tag_name': 'vm_new_linux', 'tag_description': 'New Linux VM'}, {'tag_name': 'vm_new_windows', 'tag_description': 'New Windows VM'}]` | List of tags to initialize for new VMs. |
| `deploy_vm__vmware_appliance_list` | `[]` | List of VMware appliances to deploy. |
| `deploy_vm__vmware_vm_list` | `[]` | List of VMware VMs to deploy. |
| `deploy_vm__govc_version` | `0.23.0` | The version of govc to use. |
| `deploy_vm__govc_path` | `/usr/local/bin` | The path where govc will be installed. |
| `deploy_vm__govc_file` | `{{deploy_vm__govc_path}}/govc` | The full path to the govc binary. |
| `deploy_vm__govc_host` | `{{ deploy_vm__vcenter_hostname }}` | The hostname of the govc server. |
| `deploy_vm__govc_username` | `{{ deploy_vm__vcenter_username }}` | The username for govc authentication. |
| `deploy_vm__govc_password` | `{{ deploy_vm__vcenter_password }}` | The password for govc authentication. |
| `deploy_vm__govc_insecure` | `1` | Whether to use insecure connections with govc. |
| `deploy_vm__govc_environment` | `{'GOVC_HOST': '{{ deploy_vm__govc_host }}', 'GOVC_URL': 'https://{{ deploy_vm__govc_host }}/sdk', 'GOVC_USERNAME': '{{ deploy_vm__govc_username }}', 'GOVC_PASSWORD': '{{ deploy_vm__govc_password }}', 'GOVC_INSECURE': '{{ deploy_vm__govc_insecure }}'}` | Environment variables for govc. |
| `deploy_vm__create_async_delay` | `30` | Delay in seconds for asynchronous VM creation. |
| `deploy_vm__create_async_retries` | `1000` | Number of retries for asynchronous VM creation. |
| `deploy_vm__template_info` | `{'ubuntu24': {'name': 'vm-template-ubuntu24.04-medium-prod', 'network_service': 'systemd-networkd'}, 'ubuntu24-small': {'name': 'vm-template-ubuntu24.04-small-prod', 'network_service': 'systemd-networkd'}, 'ubuntu24-medium': {'name': 'vm-template-ubuntu24.04-medium-prod', 'network_service': 'systemd-networkd'}, 'ubuntu24-large': {'name': 'vm-template-ubuntu24.04-large-prod', 'network_service': 'systemd-networkd'}, 'centos9': {'name': 'vm-template-centos9-medium-prod', 'network_service': 'NetworkManager'}, 'centos9-small': {'name': 'vm-template-centos9-small-prod', 'network_service': 'NetworkManager'}, 'centos9-medium': {'name': 'vm-template-centos9-medium-prod', 'network_service': 'NetworkManager'}, 'centos9-large': {'name': 'vm-template-centos9-large-prod', 'network_service': 'NetworkManager'}, 'debian12': {'name': 'vm-template-debian12-medium-prod', 'network_service': 'NetworkManager'}, 'debian12-small': {'name': 'vm-template-debian12-small-prod', 'network_service': 'NetworkManager'}, 'debian12-medium': {'name': 'vm-template-debian12-medium-prod', 'network_service': 'NetworkManager'}, 'debian12-large': {'name': 'vm-template-debian12-large-prod', 'network_service': 'NetworkManager'}, 'redhat9': {'name': 'vm-template-rhel9-medium-prod', 'network_service': 'NetworkManager'}}` | Information about VM templates. |
| `deploy_vm__proxmox_api_url` | `https://proxmox.example.int:8006/api2/json` | The API URL for Proxmox. |
| `deploy_vm__proxmox_username` | `root` | The username for Proxmox authentication. |
| `deploy_vm__proxmox_password` | `password` | The password for Proxmox authentication. |
| `deploy_vm__proxmox_node` | `pve1` | The Proxmox node to deploy VMs on. |
| `deploy_vm__proxmox_storage` | `local-lvm` | The storage to use for Proxmox VMs. |
| `deploy_vm__proxmox_network` | `vmbr0` | The network bridge to use for Proxmox VMs. |
| `deploy_vm__proxmox_vm_list` | `[]` | List of Proxmox VMs to deploy. |

## Usage

### VMware Example

To use the `deploy_vm` role with VMware, include it in your playbook and define the necessary variables:

```yaml
---
- name: Deploy VMware VMs
  hosts: localhost
  roles:
    - role: deploy_vm
      vars:
        deploy_vm__vmware_vm_list:
          - name: example-vm
            template: ubuntu24
            datacenter: example-datacenter
            cluster: example-cluster
            resource_pool: example-resource-pool
            datastore: example-datastore
            networks:
              - name: example-network
                ip: 192.168.1.100
                netmask: 255.255.255.0
                gateway: 192.168.1.1
                dns:
                  - 8.8.8.8
                  - 8.8.4.4
```

### Proxmox Example

To use the `deploy_vm` role with Proxmox, include it in your playbook and define the necessary variables:

```yaml
---
- name: Deploy Proxmox VMs
  hosts: localhost
  roles:
    - role: deploy_vm
      vars:
        deploy_vm__proxmox_vm_list:
          - name: example-vm
            template: ubuntu24
            storage: local-lvm
            network: vmbr0
            ip: 192.168.1.100
            gateway: 192.168.1.1
            dns:
              - 8.8.8.8
              - 8.8.4.4
```

## Dependencies

The `deploy_vm` role requires the following dependencies:

- `community.vmware` collection (version 2.0.0 or later) for VMware tasks.
- `community.general` collection (version 3.0.0 or later) for Proxmox tasks.
- Python pip packages specified in `deploy_vm__python_pip_depends`.

## Best Practices

- Use Ansible Vault or another secret management tool to securely manage vCenter and Proxmox credentials.
- Regularly update the `deploy_vm__python_pip_depends` list to include any new dependencies required by the role.
- Test the role in a development environment before deploying it to production.
- Use appropriate tags and categories when creating VMs to facilitate management and automation.
- Monitor the performance and resource usage of deployed VMs to ensure they meet requirements.

## Idempotency

The `deploy_vm` role is designed to be idempotent, meaning it can be run multiple times without causing unintended side effects. The role checks for the existence of VMs before attempting to create them, and it only makes changes when necessary.

## License

This role is licensed under the MIT License.

## Author Information

This role was created by [Your Name or Organization].