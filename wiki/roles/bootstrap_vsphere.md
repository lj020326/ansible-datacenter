---
title: "Bootstrap Vsphere Role"
role: "bootstrap_vsphere"
category: "Virtualization"
type: "Role"
tags: [ansible, bootstrap_vsphere, role]
---

```yaml
---
# Documentation for the bootstrap_vsphere Ansible Role

title: "Bootstrap Vsphere Role"
role: "bootstrap_vsphere"
category: "Virtualization"
type: "Role"

summary: |
  The `bootstrap_vsphere` role is designed to automate the deployment and configuration of VMware vSphere environments. This includes setting up vCenter Server, configuring ESXi hosts, creating clusters, and managing distributed switches. The role provides a comprehensive set of tasks to ensure a fully functional vSphere environment tailored to specific requirements.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `bootstrap_vsphere__vcenter_repo_dir` | `/opt/repo` | Directory where the vCenter repository is located. |
| `bootstrap_vsphere__vcsa_iso` | `VMware-VCSA-all-7.0.0-16189094.iso` | The ISO file for the vCenter Server Appliance. |
| `bootstrap_vsphere__esx_iso` | `VMware-VMvisor-Installer-6.5.0-4564106.x86_64.iso` | The ISO file for ESXi installation. |
| `bootstrap_vsphere__vsphere_deploy_iso_hash_seed` | `sldkfjlkenwq4tm;24togk34t` | Seed for the ISO hash used during deployment. |
| `bootstrap_vsphere__vsphere_version` | `7.0` | Version of vSphere to deploy. |
| `bootstrap_vsphere__esx_custom_iso` | `custom-esxi-{{ bootstrap_vsphere__vsphere_version }}.iso` | Custom ESXi ISO file. |
| `bootstrap_vsphere__vcenter_iso_dir` | `/ISO-Repo/vmware/esxi` | Directory where the ESXi ISO files are stored. |
| `bootstrap_vsphere__vcenter_python_pip_depends` | `['pyVmomi']` | Python dependencies required for vCenter configuration. |
| `bootstrap_vsphere__vcenter_install_tmp_dir` | `/tmp` | Temporary directory for vCenter installation files. |
| `bootstrap_vsphere__vcenter_mount_dir` | `/mnt/VCSA` | Directory to mount the vCenter ISO. |
| `bootstrap_vsphere__ovftool` | `{{ bootstrap_vsphere__vcenter_mount_dir }}/vcsa/ovftool/lin64/ovftool` | Path to the OVF tool. |
| `bootstrap_vsphere__vcsa_ova` | `vcsa/VMware-vCenter-Server-Appliance-6.7.0.14000-9451876_OVF10.ova` | OVF file for the vCenter Server Appliance. |
| `bootstrap_vsphere__vcenter_appliance_type` | `embedded` | Type of vCenter appliance to deploy. |
| `bootstrap_vsphere__vcenter_network_ip_scheme` | `static` | IP addressing scheme for the vCenter appliance. |
| `bootstrap_vsphere__vcenter_disk_mode` | `thin` | Disk provisioning mode for the vCenter appliance. |
| `bootstrap_vsphere__vcenter_appliance_name` | `vcenter` | Name of the vCenter appliance. |
| `bootstrap_vsphere__vcenter_appliance_size` | `small` | Size of the vCenter appliance. |
| `bootstrap_vsphere__vcenter_target_esxi_datastore` | `vsanDatastore` | Datastore to use for the vCenter appliance. |
| `bootstrap_vsphere__vcenter_target_esxi_portgroup` | `Management` | Portgroup to use for the vCenter appliance. |
| `bootstrap_vsphere__vcenter_ssh_enable` | `true` | Enable SSH on the vCenter appliance. |
| `bootstrap_vsphere__vcenter_time_tools_sync` | `false` | Enable time synchronization tools. |
| `bootstrap_vsphere__vcenter_net_addr_family` | `ipv4` | Network address family for the vCenter appliance. |
| `bootstrap_vsphere__vcenter_site_name` | `Default-Site` | Site name for the vCenter appliance. |
| `bootstrap_vsphere__vcenter_sso_domain` | `vsphere.local` | Single Sign-On domain for the vCenter appliance. |
| `bootstrap_vsphere__vcenter_domain` | `example.int` | Domain for the vCenter appliance. |
| `bootstrap_vsphere__vcenter_cluster` | `Management` | Cluster for the vCenter appliance. |
| `bootstrap_vsphere__vcenter_host` | `vcenter.example.int` | Hostname for the vCenter appliance. |
| `bootstrap_vsphere__vcenter_username` | `administrator@{{ bootstrap_vsphere__vcenter_sso_domain }}` | Username for the vCenter appliance. |
| `bootstrap_vsphere__vcenter_password` | `VMware1!` | Password for the vCenter appliance. |
| `bootstrap_vsphere__vcenter_netmask` | `255.255.0.0` | Netmask for the vCenter appliance. |
| `bootstrap_vsphere__vcenter_gateway` | `192.168.0.1` | Gateway for the vCenter appliance. |
| `bootstrap_vsphere__vcenter_net_prefix` | `16` | Network prefix for the vCenter appliance. |
| `bootstrap_vsphere__vcenter_datastore` | `datastore1` | Datastore for the vCenter appliance. |
| `bootstrap_vsphere__vcenter_datacenter` | `dc-01` | Datacenter for the vCenter appliance. |
| `bootstrap_vsphere__vcenter_network` | `VM Network` | Network for the vCenter appliance. |
| `bootstrap_vsphere__vcenter_compute_vlan_id` | `0` | VLAN ID for the vCenter appliance. |
| `bootstrap_vsphere__vcenter_mgt_portgroup_name` | `{{ bootstrap_vsphere__vcenter_network }}` | Management portgroup name for the vCenter appliance. |
| `bootstrap_vsphere__vcenter_mgt_vlan_id` | `0` | Management VLAN ID for the vCenter appliance. |
| `bootstrap_vsphere__vcenter_mgt_vswitch` | `vSwitch0` | Management vSwitch for the vCenter appliance. |
| `bootstrap_vsphere__vcenter_mgt_network` | `Management Network` | Management network for the vCenter appliance. |
| `bootstrap_vsphere__vcenter_mgt_device` | `vmk0` | Management device for the vCenter appliance. |
| `bootstrap_vsphere__vcenter_nested_vss_portgroup_name` | `nested-trunk` | Nested vSwitch portgroup name for the vCenter appliance. |
| `bootstrap_vsphere__vcenter_nested_vss_vlan_id` | `4095` | Nested vSwitch VLAN ID for the vCenter appliance. |

## Usage

To use the `bootstrap_vsphere` role, include it in your playbook and define the necessary variables. Here is an example playbook:

```yaml
---
- name: Deploy and configure vSphere environment
  hosts: localhost
  roles:
    - role: bootstrap_vsphere
      vars:
        bootstrap_vsphere__vcenter_repo_dir: /opt/repo
        bootstrap_vsphere__vcsa_iso: VMware-VCSA-all-7.0.0-16189094.iso
        bootstrap_vsphere__esx_iso: VMware-VMvisor-Installer-6.5.0-4564106.x86_64.iso
        bootstrap_vsphere__vsphere_version: "7.0"
        bootstrap_vsphere__vcenter_host: vcenter.example.int
        bootstrap_vsphere__vcenter_username: administrator@vsphere.local
        bootstrap_vsphere__vcenter_password: VMware1!
```

## Dependencies

This role requires the following dependencies:

- `community.vmware` Ansible collection
- `vmware.vmware` Ansible collection
- `nestedESXi` Ansible module

Ensure these dependencies are installed before running the playbook:

```bash
ansible-galaxy collection install community.vmware
ansible-galaxy collection install vmware.vmware
ansible-galaxy install nestedESXi
```

## Best Practices

### General Guidelines
- Ensure that the vCenter and ESXi ISO files are accessible and correctly specified.
- Verify network configurations and ensure that the necessary ports are open.
- Regularly back up the vCenter and ESXi configurations.
- Monitor the deployment process and address any errors or warnings promptly.

### Security
- Use strong, unique passwords for all vSphere components.
- Enable and configure firewalls to restrict access to vSphere components.
- Regularly update and patch vSphere components to address security vulnerabilities.

### Performance
- Optimize resource allocation for vCenter and ESXi hosts based on workload requirements.
- Implement proper monitoring and alerting for performance metrics.
- Regularly review and optimize storage configurations.

## Troubleshooting

### Common Issues
- **ISO File Not Found**: Ensure the ISO files are correctly specified and accessible.
- **Network Connectivity Issues**: Verify network configurations and ensure all necessary ports are open.
- **Authentication Failures**: Double-check credentials and ensure they have the necessary permissions.

### Debugging Tips
- Enable verbose mode in Ansible to get detailed output: `ansible-playbook -vvv playbook.yml`
- Check vCenter and ESXi logs for error messages.
- Review Ansible task output for specific error messages.

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
- [tasks/post_check_esxi_host_portgroups.yml](../../roles/bootstrap_vsphere/tasks/post_check_esxi_host_portgroups.yml)
- [tasks/pre_check_esxi_host_portgroups.yml](../../roles/bootstrap_vsphere/tasks/pre_check_esxi_host_portgroups.yml)
- [tasks/prepare_esxi.yml](../../roles/bootstrap_vsphere/tasks/prepare_esxi.yml)
- [tasks/prepare_esxi_installer_iso.yml](../../roles/bootstrap_vsphere/tasks/prepare_esxi_installer_iso.yml)
- [handlers/main.yml](../../roles/bootstrap_vsphere/handlers/main.yml)