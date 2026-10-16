```yaml
---
title: Deploy Windows VM with Ansible and VMware
original_path: playbooks/deploy-windows-vm.md
category: Automation
tags:
  - Ansible
  - VMware
  - Windows
  - Automation
harvested_date: '2026-08-07T18:07:09.113849+00:00'
source_type: legacy_markdown
---

# Deploy Windows VM with Ansible and VMware

This guide provides a detailed walkthrough of deploying a Windows VM using Ansible and VMware, addressing the limitations of VMware's Ansible modules and offering a workaround solution.

## Introduction

Deploying a Windows VM using Ansible and VMware should be straightforward. With an answer file for unattended installation, a virtual floppy image, and a Windows installation ISO, one would expect to use VMware’s Ansible modules like `vsphere_copy` to transfer the ISO and FLP files to a datastore, and `vsphere_guest` to create the VM. However, there are coverage gaps in VMware's modules that prevent this from working seamlessly.

## Challenges

1. **vsphere_copy Module**: This module does not work with standalone hosts. In a greenfield deployment scenario where the domain controller is built before vCenter, vCenter is not available yet.
2. **vmware_guest Module**: This module cannot create a virtual floppy drive, a feature that was present in the deprecated module it replaced.

## Solution

To overcome these limitations, a different approach is required. By using the `vsphere_host` module to enable SSH in ESXi, the host can be treated like a Linux host, utilizing shell commands to copy files and edit configurations.

## Playbook Highlights

The complete playbook can be found on [lj020326 GitHub](https://github.com/lj020326/ansible-datacenter/playbooks), but here are some key sections:

### ESXi Login Variables

```yaml
vars:
  esxi_login: &esxi_login
    hostname: '{{ esxi_address }}'
    username: '{{ esxi_username }}'
    password: '{{ esxi_password }}'
    validate_certs: no
```

### Enabling SSH and ESXi Shell

```yaml
- name: Enable ESX SSH (TSM-SSH)
  vmware_host_service_manager:
    <<: *esxi_login
    esxi_hostname: '{{ esxi_address }}'
    service_name: TSM-SSH
    state: present
  delegate_to: localhost

- name: Enable ESX Shell (TSM)
  vmware_host_service_manager:
    <<: *esxi_login
    esxi_hostname: '{{ esxi_address }}'
    service_name: TSM
    state: present
  delegate_to: localhost
```

### Downloading ISO and Floppy Image

```yaml
- name: Download the Windows Server ISO
  shell: 'wget -P /vmfs/volumes/{{ esxi_datastore }} {{ windows_iso_url }}'
  args:
    creates: '/vmfs/volumes/{{ esxi_datastore }}/{{ windows_iso }}'
  delegate_to: '{{ esxi_address }}'

- name: Download the autounattend floppy .flp
  shell: 'wget -P /vmfs/volumes/{{ esxi_datastore }} {{ windows_flp_url }}'
  args:
    creates: '/vmfs/volumes/{{ esxi_datastore }}/{{ windows_flp }}'
  delegate_to: '{{ esxi_address }}'
```

### Creating the VM

```yaml
- name: Create a new Server 2016 VM
  vmware_guest:
    <<: *esxi_login
    folder: /
    name: '{{ vm_name }}'
    state: present
    guest_id: windows9Server64Guest
    cdrom:
      type: iso
      iso_path: '[{{ esxi_datastore }}] {{ windows_iso }}'
    disk:
    - size_gb: '{{ vm_disk_gb }}'
      type: thin
      datastore: '{{ esxi_datastore }}'
    hardware:
      memory_mb: '{{ vm_memory_mb }}'
      num_cpus: '{{ vm_num_cpus }}'
      scsi: lsilogicsas
    networks:
    - name: '{{ vm_network }}'
      device_type: e1000
    wait_for_ip_address: no
  delegate_to: localhost
  register: deploy_vm
```

### Editing VMX File for Floppy Drive

```yaml
- name: Adding VMX Entry - floppy0.fileType
  lineinfile:
    path: '/vmfs/volumes/{{ esxi_datastore }}/{{ vm_name }}/{{ vm_name }}.vmx'
    line: 'floppy0.fileType = "file"'
  delegate_to: '{{ esxi_address }}'

- name: Adding VMX Entry - floppy0.fileName
  lineinfile:
    path: '/vmfs/volumes/{{ esxi_datastore }}/{{ vm_name }}/{{ vm_name }}.vmx'
    line: 'floppy0.fileName = "/vmfs/volumes/{{ esxi_datastore }}/{{ windows_flp }}"'
  delegate_to: '{{ esxi_address }}'

- name: Removing VMX Entry - floppy0.present = "FALSE"
  lineinfile:
    path: '/vmfs/volumes/{{ esxi_datastore }}/{{ vm_name }}/{{ vm_name }}.vmx'
    line: 'floppy0.present = "FALSE"'
    state: absent
  delegate_to: '{{ esxi_address }}'
```

### Setting Boot Order

```yaml
- name: Change virtual machine's boot order and related parameters
  vmware_guest_boot_manager:
    <<: *esxi_login
    name: '{{ vm_name }}'
    boot_delay: 1000
    enter_bios_setup: False
    boot_retry_enabled: True
    boot_retry_delay: 20000
    boot_firmware: bios
    secure_boot_enabled: False
    boot_order:
      - cdrom
      - disk
      - ethernet
      - floppy
  delegate_to: localhost
  register: vm_boot_order
```

### Customizing the Guest OS

```yaml
- name: Set password via vmware_vm_shell
  local_action:
    module: vmware_vm_shell
    <<: *esxi_login
    vm_username: Administrator
    vm_password: '{{ vm_password_old }}'
    vm_id: '{{ vm_name }}'
    vm_shell: 'c:\windows\system32\windowspowershell\v1.0\powershell.exe'
    vm_shell_args: '-command "(net user Administrator {{ vm_password_new }})"'
    wait_for_process: true
  ignore_errors: yes

- name: Configure IP address via vmware_vm_shell
  local_action:
    module: vmware_vm_shell
    <<: *esxi_login
    vm_username: Administrator
    vm_password: '{{ vm_password_new }}'
    vm_id: '{{ vm_name }}'
    vm_shell: 'c:\windows\system32\windowspowershell\v1.0\powershell.exe'
    vm_shell_args: '-command "(new-netipaddress -InterfaceAlias Ethernet0 -IPAddress {{ vm_address }} -prefixlength {{vm_netmask_cidr}} -defaultgateway {{ vm_gateway }})"'
    wait_for_process: true

- name: Configure DNS via vmware_vm_shell
  local_action:
    module: vmware_vm_shell
    <<: *esxi_login
    vm_username: Administrator
    vm_password: '{{ vm_password_new }}'
    vm_id: '{{ vm_name }}'
    vm_shell: 'c:\windows\system32\windowspowershell\v1.0\powershell.exe'
    vm_shell_args: '-command "(Set-DnsClientServerAddress -InterfaceAlias Ethernet0 -ServerAddresses {{ vm_dns_server }})"'
    wait_for_process: true

- name: Rename Computer via vmware_vm_shell
  local_action:
    module: vmware_vm_shell
    <<: *esxi_login
    vm_username: Administrator
    vm_password: '{{ vm_password_new }}'
    vm_id: '{{ vm_name }}'
    vm_shell: 'c:\windows\system32\windowspowershell\v1.0\powershell.exe'
    vm_shell_args: '-command "(Rename-Computer -NewName {{ vm_name }})"'
    wait_for_process: true
```

## Conclusion

After one more reboot, the VM is ready for advanced configuration by another playbook. The complete playbook and example variables file can be found on [lj020326 GitHub](https://github.com/lj020326/ansible-datacenter/playbooks/blob/main/deploy-windows-vm.yml) and [example vars file](https://github.com/lj020326/ansible-datacenter/playbooks/vars/blob/main/deploy-windows-vm.yml).

## Backlinks

<!-- Backlinks will be added here automatically -->
```