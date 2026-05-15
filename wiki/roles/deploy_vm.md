---
title: "Deploy VM Role Documentation"
role: deploy_vm
category: Ansible Roles
type: Infrastructure Automation
tags: vmware, proxmox, deployment, automation
---

## Summary

The `deploy_vm` role is designed to automate the deployment of virtual machines (VMs) and appliances on VMware vSphere and Proxmox environments. It handles tasks such as deploying VMs from templates, configuring boot settings, powering on VMs, and managing tags and categories in vSphere. The role also supports deploying OVA files for VMware appliances.

## Variables

| Variable Name                             | Default Value                                                                                   | Description                                                                                                                                                                                                 |
|-------------------------------------------|-------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `deploy_vm__python_pip_depends`           | `['pyVmomi']`                                                                                   | List of Python packages to be installed using pip.                                                                                                                                                            |
| `deploy_vm__vcenter_hostname`             | `vcenter.example.int`                                                                           | The hostname or IP address of the vCenter server.                                                                                                                                                             |
| `deploy_vm__vcenter_username`             | `administrator`                                                                                 | The username for authenticating with the vCenter server.                                                                                                                                                    |
| `deploy_vm__vcenter_password`             | `password`                                                                                      | The password for authenticating with the vCenter server.                                                                                                                                                    |
| `deploy_vm__vcenter_validate_certs`       | `false`                                                                                         | Whether to validate SSL certificates when connecting to the vCenter server.                                                                                                                               |
| `deploy_vm__tags_init_all`                | List of tag definitions                                                                         | A list of tags to be initialized in vSphere, each with a name and description.                                                                                                                              |
| `deploy_vm__vmware_appliance_list`        | `[]`                                                                                            | A list of VMware appliances to deploy using OVA files.                                                                                                                                                      |
| `deploy_vm__vmware_vm_list`               | `[]`                                                                                            | A list of VMs to be deployed from templates on vSphere.                                                                                                                                                    |
| `deploy_vm__govc_version`                 | `0.23.0`                                                                                        | The version of govc (Go client for VMware vSphere) to be used.                                                                                                                                              |
| `deploy_vm__govc_path`                    | `/usr/local/bin`                                                                                | The installation path for the govc binary.                                                                                                                                                                  |
| `deploy_vm__govc_file`                    | `"{{ deploy_vm__govc_path }}/govc"`                                                              | The full path to the govc binary.                                                                                                                                                                           |
| `deploy_vm__govc_host`                    | `"{{ deploy_vm__vcenter_hostname }}"`                                                             | The hostname or IP address of the vCenter server for govc configuration.                                                                                                                                    |
| `deploy_vm__govc_username`                | `"{{ deploy_vm__vcenter_username }}"`                                                             | The username for authenticating with the vCenter server using govc.                                                                                                                                         |
| `deploy_vm__govc_password`                | `"{{ deploy_vm__vcenter_password }}"`                                                             | The password for authenticating with the vCenter server using govc.                                                                                                                                         |
| `deploy_vm__govc_insecure`                | `1`                                                                                             | Whether to allow insecure connections when using govc.                                                                                                                                                      |
| `deploy_vm__govc_environment`             | Environment variables for govc                                                                  | A dictionary of environment variables used by govc for authentication and configuration.                                                                                                                      |
| `deploy_vm__create_async_delay`           | `30`                                                                                            | The delay in seconds between asynchronous operations during VM creation.                                                                                                                                    |
| `deploy_vm__create_async_retries`         | `1000`                                                                                          | The number of retries for asynchronous operations during VM creation.                                                                                                                                       |
| `deploy_vm__template_info`                | Dictionary of template information                                                              | A dictionary containing details about different VM templates, including their names and network services.                                                                                                   |

## Usage

To use the `deploy_vm` role, you need to define the necessary variables in your playbook or inventory files. Here is an example of how to deploy a VMware VM from a template:

```yaml
- name: Deploy VMs on vSphere
  hosts: localhost
  gather_facts: false
  roles:
    - role: deploy_vm
      vars:
        deploy_vm__vmware_vm_list:
          - name: my-ubuntu24-vm
            template_name: vm-template-ubuntu24.04-medium-prod
            datacenter: DC1
            cluster: CLUSTER1
            datastore: DS1
            folder: /DC1/vm/VMs/
            resource_pool: RP1
            network:
              name: VM Network
              ip: 192.168.1.100
              netmask: 255.255.255.0
              gateway: 192.168.1.1
              dns_servers:
                - 8.8.8.8
                - 8.8.4.4
            cpu: 2
            memory: 4096
```

## Dependencies

- `community.vmware` collection for VMware-related modules.
- `community.general.proxmox` module for Proxmox-related tasks.
- Python packages listed in `deploy_vm__python_pip_depends`.

## Best Practices

1. **Secure Credentials**: Ensure that sensitive information such as passwords and API keys are stored securely using Ansible Vault or environment variables.
2. **Template Management**: Maintain a well-documented list of VM templates with consistent naming conventions to simplify deployment tasks.
3. **Error Handling**: Implement robust error handling and logging to troubleshoot issues during the deployment process.

## Molecule Tests

This role does not currently include Molecule tests. Consider adding Molecule scenarios to validate the role's functionality in different environments.

## Backlinks

- [defaults/main.yml](../../roles/deploy_vm/defaults/main.yml)
- [tasks/config-vmware-vm-linux.yml](../../roles/deploy_vm/tasks/config-vmware-vm-linux.yml)
- [tasks/deploy-proxmox-vm.yml](../../roles/deploy_vm/tasks/deploy-proxmox-vm.yml)
- [tasks/deploy-vmware-appliance.yml](../../roles/deploy_vm/tasks/deploy-vmware-appliance.yml)
- [tasks/deploy-vmware-vm.yml](../../roles/deploy_vm/tasks/deploy-vmware-vm.yml)
- [tasks/main.yml](../../roles/deploy_vm/tasks/main.yml)
- [handlers/main.yml](../../roles/deploy_vm/handlers/main.yml)