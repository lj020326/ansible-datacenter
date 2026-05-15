```markdown
---
title: Deploy VM Role Documentation
original_path: roles/deploy_vm/README.md
category: Ansible Roles
tags: [vmware, proxmox, automation, ansible]
---

# Deploy VM Role Documentation

## Summary

The `deploy_vm` role is designed to automate the deployment of virtual machines (VMs) and appliances on VMware vSphere and Proxmox environments. This role handles the creation, configuration, and management of VMs, including setting boot order, power state, network configurations, and deploying OVF templates for appliances.

## Variables

| Variable Name                           | Default Value                                                                                          | Description                                                                                                                                                                                                 |
|-----------------------------------------|--------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `deploy_vm__python_pip_depends`         | `['pyVmomi']`                                                                                          | List of Python packages to be installed via pip.                                                                                                                                                            |
| `deploy_vm__vcenter_hostname`           | `vcenter.example.int`                                                                                  | The hostname or IP address of the vCenter server.                                                                                                                                                           |
| `deploy_vm__vcenter_username`           | `administrator`                                                                                        | Username for authenticating with the vCenter server.                                                                                                                                                        |
| `deploy_vm__vcenter_password`           | `password`                                                                                             | Password for authenticating with the vCenter server. **(Sensitive)**                                                                                                                                        |
| `deploy_vm__vcenter_validate_certs`     | `false`                                                                                                | Whether to validate SSL certificates when connecting to the vCenter server.                                                                                                                                   |
| `deploy_vm__tags_init_all`              | List of tags (e.g., `vm_pre_bootstrap`, `vm_new`)                                                      | Initial list of tags to be created in vSphere for categorizing VMs.                                                                                                                                         |
| `deploy_vm__vmware_appliance_list`      | `[]`                                                                                                   | List of VMware appliances to deploy using OVF templates.                                                                                                                                                  |
| `deploy_vm__vmware_vm_list`             | `[]`                                                                                                   | List of VMs to be deployed on vSphere.                                                                                                                                                                      |
| `deploy_vm__govc_version`               | `0.23.0`                                                                                               | Version of the govc tool to be used for VMware operations.                                                                                                                                                |
| `deploy_vm__govc_path`                  | `/usr/local/bin`                                                                                       | Path where the govc binary will be installed.                                                                                                                                                               |
| `deploy_vm__govc_file`                  | `"{{ deploy_vm__govc_path }}/govc"`                                                                     | Full path to the govc binary.                                                                                                                                                                               |
| `deploy_vm__govc_host`                  | `"{{ deploy_vm__vcenter_hostname }}"`                                                                    | Hostname or IP address of the vCenter server for govc operations.                                                                                                                                           |
| `deploy_vm__govc_username`              | `"{{ deploy_vm__vcenter_username }}"`                                                                    | Username for authenticating with the vCenter server using govc.                                                                                                                                             |
| `deploy_vm__govc_password`              | `"{{ deploy_vm__vcenter_password }}"`                                                                    | Password for authenticating with the vCenter server using govc. **(Sensitive)**                                                                                                                             |

## Backlinks

- [Ansible Roles Documentation](/docs/ansible-roles)
- [VMware Automation Guide](/guides/vmware-automation)
```

This improved Markdown document includes a standardized YAML frontmatter, clear structure with proper headings, and a "Backlinks" section for additional context.