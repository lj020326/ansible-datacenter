---
title: Bootstrap vSphere Role Documentation
role: bootstrap_vsphere
category: Infrastructure Provisioning
type: Ansible Role
tags: vmware, vsphere, automation, deployment

---

## Summary

The `bootstrap_vsphere` role is designed to automate the deployment and configuration of VMware vCenter Server Appliance (VCSA) and ESXi hosts within a VMware environment. This role handles tasks such as deploying VCSA, configuring clusters, adding physical ESXi hosts to the vCenter, creating distributed virtual switches, and more. It ensures that the vSphere infrastructure is set up according to specified configurations.

## Variables

| Variable Name                                      | Default Value                                                                                         | Description                                                                                                                                                                                                 |
|----------------------------------------------------|-------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_vsphere__vcenter_repo_dir`              | `/opt/repo`                                                                                           | Directory where ISO files are stored.                                                                                                                                                                       |
| `bootstrap_vsphere__vcsa_iso`                      | `"VMware-VCSA-all-7.0.0-16189094.iso"`                                                                | Filename of the VCSA installer ISO.                                                                                                                                                                         |
| `bootstrap_vsphere__esx_iso`                       | `VMware-VMvisor-Installer-6.5.0-4564106.x86_64.iso`                                                   | Filename of the ESXi installer ISO.                                                                                                                                                                         |
| `bootstrap_vsphere__vsphere_deploy_iso_hash_seed`  | `sldkfjlkenwq4tm;24togk34t`                                                                            | Seed used for generating a hash for the ISO file.                                                                                                                                                           |
| `bootstrap_vsphere__vsphere_version`               | `"7.0"`                                                                                               | Version of vSphere to be deployed.                                                                                                                                                                          |
| `bootstrap_vsphere__esx_custom_iso`                | `custom-esxi-{{ bootstrap_vsphere__vsphere_version }}.iso`                                              | Filename for the custom ESXi installer ISO.                                                                                                                                                                 |
| `bootstrap_vsphere__vcenter_iso_dir`               | `/ISO-Repo/vmware/esxi`                                                                               | Directory containing the VCSA and ESXi ISO files.                                                                                                                                                           |
| `bootstrap_vsphere__vcenter_python_pip_depends`    | `[pyVmomi]`                                                                                             | List of Python packages to be installed for vCenter management.                                                                                                                                             |
| `bootstrap_vsphere__vcenter_install_tmp_dir`       | `/tmp`                                                                                                | Temporary directory used during the installation process.                                                                                                                                                   |
| `bootstrap_vsphere__vcenter_mount_dir`             | `/mnt/VCSA`                                                                                           | Directory where the VCSA ISO is mounted.                                                                                                                                                                    |
| `bootstrap_vsphere__ovftool`                       | `"{{ bootstrap_vsphere__vcenter_mount_dir }}/vcsa/ovftool/lin64/ovftool"`                             | Path to the OVF Tool executable.                                                                                                                                                                            |
| `bootstrap_vsphere__vcsa_ova`                      | `vcsa/VMware-vCenter-Server-Appliance-6.7.0.14000-9451876_OVF10.ova`                                    | Filename of the VCSA OVA file.                                                                                                                                                                              |
| `bootstrap_vsphere__vcenter_appliance_type`        | `embedded`                                                                                            | Type of vCenter appliance deployment (e.g., embedded).                                                                                                                                                    |
| `bootstrap_vsphere__vcenter_network_ip_scheme`     | `static`                                                                                              | IP scheme for the vCenter network configuration.                                                                                                                                                            |
| `bootstrap_vsphere__vcenter_disk_mode`             | `thin`                                                                                                | Disk mode for the vCenter deployment (e.g., thin).                                                                                                                                                          |
| `bootstrap_vsphere__vcenter_appliance_name`        | `vcenter`                                                                                             | Name of the vCenter appliance.                                                                                                                                                                              |
| `bootstrap_vsphere__vcenter_appliance_size`        | `small`                                                                                               | Size of the vCenter appliance (e.g., small).                                                                                                                                                                |
| `bootstrap_vsphere__vcenter_target_esxi_datastore` | `vsanDatastore`                                                                                         | Datastore on which to deploy the vCenter appliance.                                                                                                                                                       |
| `bootstrap_vsphere__vcenter_target_esxi_portgroup` | `Management`                                                                                          | Portgroup for the vCenter network interface.                                                                                                                                                                |
| `bootstrap_vsphere__vcenter_ssh_enable`            | `true`                                                                                                | Enable SSH access on the vCenter appliance.                                                                                                                                                                 |
| `bootstrap_vsphere__vcenter_time_tools_sync`       | `false`                                                                                               | Synchronize time with VMware Tools.                                                                                                                                                                         |
| `bootstrap_vsphere__vcenter_net_addr_family`       | `ipv4`                                                                                                | Network address family for the vCenter deployment (e.g., ipv4).                                                                                                                                             |
| `bootstrap_vsphere__vcenter_site_name`             | `Default-Site`                                                                                        | Site name for the vCenter deployment.                                                                                                                                                                       |
| `bootstrap_vsphere__vcenter_sso_domain`            | `vsphere.local`                                                                                       | Single Sign-On domain for the vCenter deployment.                                                                                                                                                           |
| `bootstrap_vsphere__vcenter_domain`                | `example.int`                                                                                         | Domain name for the vCenter deployment.                                                                                                                                                                     |
| `bootstrap_vsphere__vcenter_cluster`               | `Management`                                                                                          | Cluster where the vCenter appliance will be deployed.                                                                                                                                                     |
| `bootstrap_vsphere__vcenter_host`                  | `vcenter.example.int`                                                                                 | FQDN or IP address of the vCenter server.                                                                                                                                                                   |
| `bootstrap_vsphere__vcenter_username`              | `"administrator@{{ bootstrap_vsphere__vcenter_sso_domain }}"`                                          | Username for logging into the vCenter server.                                                                                                                                                               |
| `bootstrap_vsphere__vcenter_password`              | `"VMware1!"`                                                                                          | Password for the vCenter user account.                                                                                                                                                                      |
| `bootstrap_vsphere__vcenter_netmask`               | `255.255.0.0`                                                                                         | Network mask for the vCenter network interface.                                                                                                                                                             |
| `bootstrap_vsphere__vcenter_gateway`               | `192.168.0.1`                                                                                         | Gateway IP address for the vCenter network interface.                                                                                                                                                       |
| `bootstrap_vsphere__vcenter_net_prefix`            | `"16"`                                                                                                | Network prefix length for the vCenter network interface.                                                                                                                                                  |
| `bootstrap_vsphere__vcenter_datastore`             | `datastore1`                                                                                          | Default datastore for the vCenter deployment.                                                                                                                                                               |
| `bootstrap_vsphere__vcenter_datacenter`            | `dc-01`                                                                                               | Datacenter where the vCenter appliance will be deployed.                                                                                                                                                |
| `bootstrap_vsphere__vcenter_network`               | `VM Network`                                                                                          | Network for the vCenter deployment.                                                                                                                                                                         |
| `bootstrap_vsphere__vcenter_compute_vlan_id`       | `0`                                                                                                   | VLAN ID for the compute network interface.                                                                                                                                                                  |
| `bootstrap_vsphere__vcenter_mgt_portgroup_name`    | `"{{ bootstrap_vsphere__vcenter_network }}"`                                                           | Portgroup name for the management network interface.                                                                                                                                                      |
| `bootstrap_vsphere__vcenter_mgt_vlan_id`           | `0`                                                                                                   | VLAN ID for the management network interface.                                                                                                                                                               |
| `bootstrap_vsphere__vcenter_mgt_vswitch`           | `vSwitch0`                                                                                            | vSwitch name for the management network interface.                                                                                                                                                          |
| `bootstrap_vsphere__vcenter_mgt_network`           | `Management Network`                                                                                  | Management network name.                                                                                                                                                                                    |
| `bootstrap_vsphere__vcenter_nested_vss_portgroup_name` | `nested-trunk`                                                                                     | Portgroup name for the nested vSwitch trunk.                                                                                                                                                                |
| `bootstrap_vsphere__vcenter_nested_vss_vlan_id`    | `4095`                                                                                                | VLAN ID for the nested vSwitch trunk.                                                                                                                                                                       |
| `bootstrap_vsphere__vcenter_dns_servers`           | `[192.168.0.1]`                                                                                       | List of DNS servers for the vCenter deployment.                                                                                                                                                             |

## Usage

To use the `bootstrap_vsphere` role, include it in your playbook and provide the necessary variables as shown below:

```yaml
- name: Bootstrap VMware vSphere Environment
  hosts: localhost
  gather_facts: no
  roles:
    - role: bootstrap_vsphere
      vars:
        bootstrap_vsphere__vcenter_host: "vcenter.example.int"
        bootstrap_vsphere__vcenter_username: "administrator@vsphere.local"
        bootstrap_vsphere__vcenter_password: "VMware1!"
```

## Dependencies

- `community.vmware` collection
- `ansible.posix` collection
- `xorriso` package for ISO manipulation

Ensure that the required collections are installed:

```bash
ansible-galaxy collection install community.vmware ansible.posix
```

## Best Practices

- **Security**: Ensure that sensitive information such as passwords is stored securely, preferably using Ansible Vault.
- **Validation**: Validate all configurations before deploying to production environments.
- **Backup**: Regularly back up vCenter and ESXi configurations.

## Molecule Tests

This role does not currently include Molecule tests. Consider adding them for automated testing of the role's functionality.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_vsphere/defaults/main.yml)
- [tasks/configure_nested_vcenter.yml](../../roles/bootstrap_vsphere/tasks/configure_nested_vcenter.yml)
- [tasks/configure_vcenter.yml](../../roles/bootstrap_vsphere/tasks/configure_vcenter.yml)
- [tasks/connect_physical_esx_to_vc.yml](../../roles/bootstrap_vsphere/tasks/connect_physical_esx_to_vc.yml)
- [tasks/create_vds.yml](../../roles/bootstrap_vsphere/tasks/create_vds.yml)
- [tasks/deploy_nested_esxi.yml](../../roles/bootstrap_vsphere/tasks/deploy_nested_esxi.yml)
- [tasks/deploy_nested_vc.yml](../../roles/bootstrap_vsphere/tasks/deploy_nested_vc.yml)
- [tasks/deploy_nested_vc_and_hosts.yml](../../roles/bootstrap_vsphere/tasks/deploy_nested_vc_and_hosts.yml)
- [tasks/deploy_vcenter.yml](../../roles/bootstrap_vsphere/tasks/deploy_vcenter.yml)
- [tasks/main.yml](../../roles/bootstrap_vsphere/tasks/main.yml)
- [tasks/prepare_esxi.yml](../../roles/bootstrap_vsphere/tasks/prepare_esxi.yml)
- [tasks/prepare_esxi_installer_iso.yml](../../roles/bootstrap_vsphere/tasks/prepare_esxi_installer_iso.yml)
- [handlers/main.yml](../../roles/bootstrap_vsphere/handlers/main.yml)