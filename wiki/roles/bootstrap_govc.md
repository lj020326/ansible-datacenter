---
title: "Bootstrap Govc Role"
role: bootstrap_govc
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_govc]
---

# Bootstrap govc Role

The `bootstrap_govc` role is designed to automate the installation and configuration of `govc`, a vSphere CLI built on top of the govmomi SDK. This role facilitates the deployment of virtual machines, management of vSphere resources, and integration with cloud-init for automated VM configuration.

## Variables

| Variable Name                          | Default Value             | Description                                                                 |
|----------------------------------------|---------------------------|-----------------------------------------------------------------------------|
| `bootstrap_govc__version`              | `0.20.0`                  | The version of govc to install.                                              |
| `bootstrap_govc__path`                 | `/usr/bin`                | The installation path for the govc binary.                                   |
| `bootstrap_govc__tmp`                  | `/tmp`                    | Temporary directory for downloading and extracting govc.                     |
| `bootstrap_govc__file`                 | `{{bootstrap_govc__path}}/govc` | The full path to the govc binary.                                            |
| `bootstrap_govc__download_url`         | `https://github.com/vmware/govmomi/releases/download/v{{bootstrap_govc__version}}` | The base URL for downloading govc.                                           |
| `bootstrap_govc__host`                 | `esx-a.home.local`        | The hostname of the vCenter server.                                          |
| `bootstrap_govc__username`             | `administrator@home.local`| The username for vCenter authentication.                                      |
| `bootstrap_govc__password`             | `password`                | The password for vCenter authentication.                                     |
| `bootstrap_govc__ova_imports`          | `[]`                      | A list of OVA files to import into vCenter.                                 |
| `bootstrap_govc__deploy_cloud_init`    | `false`                   | A boolean to enable/disable cloud-init deployment.                           |
| `bootstrap_govc__insecure`             | `1`                       | Enable/disable insecure connections to vCenter.                              |
| `bootstrap_govc__datacenter`           | `Datacenter`              | The name of the datacenter in vCenter.                                       |
| `bootstrap_govc__datastore`            | `Datastore`               | The name of the datastore in vCenter.                                        |
| `bootstrap_govc__network`              | `VM Network`              | The network name in vCenter.                                                 |
| `bootstrap_govc__resource_pool`        | `Pool`                    | The resource pool name in vCenter.                                           |

## Usage

To use the `bootstrap_govc` role, include it in your playbook and configure the variables as needed:

```yaml
- hosts: all
  roles:
    - role: bootstrap_govc
      vars:
        bootstrap_govc__version: "0.21.0"
        bootstrap_govc__host: "vcenter.example.com"
        bootstrap_govc__username: "admin@example.com"
        bootstrap_govc__password: "securepassword"
        bootstrap_govc__ova_imports:
          - name: "my-vm"
            ova: "/path/to/my-vm.ova"
        bootstrap_govc__deploy_cloud_init: true
        bootstrap_govc__datacenter: "MyDatacenter"
        bootstrap_govc__datastore: "MyDatastore"
        bootstrap_govc__network: "MyNetwork"
        bootstrap_govc__resource_pool: "MyResourcePool"
```

## Dependencies

This role does not have any external dependencies. It relies on the `govc` binary, which is downloaded and installed as part of the role's tasks.

## Best Practices

1. **Security**: Ensure that the `bootstrap_govc__username` and `bootstrap_govc__password` variables are securely managed, possibly using Ansible Vault or another secret management tool.
2. **Version Management**: Regularly update the `bootstrap_govc__version` variable to ensure you are using the latest stable version of `govc`.
3. **Error Handling**: The role includes error handling for OVA imports and cloud-init deployment, ensuring that the system is left in a consistent state even if tasks fail.

## Backlinks

- [[../../roles/bootstrap_govc/defaults/main.yml]]
- [[../../roles/bootstrap_govc/tasks/cloud_init_boot.yml]]
- [[../../roles/bootstrap_govc/tasks/deploy_ova.yml]]
- [[../../roles/bootstrap_govc/tasks/install.yml]]
- [[../../roles/bootstrap_govc/tasks/main.yml]]