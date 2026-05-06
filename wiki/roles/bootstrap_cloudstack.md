---
title: "Bootstrap Cloudstack Role"
role: roles/bootstrap_cloudstack
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_cloudstack]
---

# Role: `bootstrap_cloudstack`

## Overview

The `bootstrap_cloudstack` role is designed to set up a CloudStack node by installing necessary packages, configuring virtualization components (such as libvirt and QEMU), setting up SSL certificates, mounting NFS secondary storage, and configuring the firewall. This role supports both Debian-based and RedHat-based distributions.

## Role Variables

### Default Variables

The default variables for this role are defined in `defaults/main.yml`. These variables can be overridden by group_vars, host_vars, or directly in your playbook.

| Variable Name                          | Description                                                                 | Default Value                                     |
|----------------------------------------|-----------------------------------------------------------------------------|---------------------------------------------------|
| `bootstrap_cloudstack__libvirt_port`   | Port used by libvirt for communication.                                   | `16509`                                           |
| `bootstrap_cloudstack__ssl_cert_dir`   | Directory where SSL certificates are stored.                              | `/etc/ssl/certs`                                  |
| `bootstrap_cloudstack__ssl_key_dir`    | Directory where SSL keys are stored.                                      | `/etc/ssl/private`                                |
| `bootstrap_cloudstack__libvirt_cert_dir` | Directory for libvirt PKI certificates.                                 | `/etc/pki/libvirt`                                |
| `bootstrap_cloudstack__pki_ca_certs_dir` | Directory for CA certificates.                                          | `/etc/pki/CA`                                     |
| `bootstrap_cloudstack__mysql_packages` | List of MySQL packages to install.                                        | `['mysql-common', 'mysql-server']`                |
| `bootstrap_cloudstack__client_version` | CloudStack client version.                                                | `4.10`                                            |
| `bootstrap_cloudstack__firewalld_enabled` | Whether to enable firewall configuration.                               | `true`                                            |
| `bootstrap_cloudstack__firewalld_ports` | List of ports to open in the firewall for CloudStack.                   | `['16509/tcp', '16514/tcp']`                      |

### Internal Variables

- **Double-underscore variables** are intended for internal use within the role and should not be overridden by users.

## Tasks

The tasks are organized into several steps to ensure a comprehensive setup of the CloudStack node. Here is a detailed breakdown:

### 1. Set OS Specific Variables
```yaml
- name: Set OS specific variables
  ansible.builtin.include_vars: "{{ item }}"
  with_first_found:
    - "{{ ansible_facts['distribution'] }}.yml"
    - "{{ ansible_facts['os_family'] }}.yml"
    - "default.yml"
```
This task includes OS-specific variable files based on the distribution and OS family.

### 2. Run OS-Specific Setup Tasks
```yaml
- name: Run "setup-{{ ansible_facts['os_family'] }}.yml"
  ansible.builtin.include_tasks: "setup-{{ ansible_facts['os_family'] }}.yml"
```
This task includes the appropriate setup file for the detected OS family.

### 3. Install Common CloudStack Virtualization Packages
```yaml
- name: Installing Common Cloudstack Virtualization Packages
  tags:
    - package
    - cloudstack
  ansible.builtin.package:
    name: '{{ bootstrap_cloudstack__packages }}'
    state: present
```
Installs the necessary packages for CloudStack virtualization.

### 4. Update KVM Configuration Files
```yaml
- name: "Update parts of KVM to configure: libvirt and QEMU"
  tags:
    - nfs
    - secstorage
  ansible.builtin.template:
    src: "{{ item.src }}"
    dest: "{{ item.dest }}"
    mode: "{{ item.mode | d(omit) }}"
  loop:
    - { src: 'qemu.conf.j2', dest: "/etc/libvirt/qemu.conf" }
    - { src: 'libvirtd.conf.j2', dest: "/etc/libvirt/libvirtd.conf" }
    - { src: 'sysconfig-libvirtd.conf.j2', dest: "/etc/sysconfig/libvirtd" }
```
Updates configuration files for libvirt and QEMU using templates.

### 5. Create Libvirt PKI Certificate Directories
```yaml
- name: "Create libvirt pki cert directories"
  ansible.builtin.file:
    path: "{{ item.path }}"
    state: directory
    mode: "0755"
  loop:
    - { path: "{{ bootstrap_cloudstack__libvirt_cert_dir }}" }
    - { path: "{{ bootstrap_cloudstack__libvirt_cert_dir }}/private" }
```
Creates necessary directories for libvirt PKI certificates.

### 6. Copy Certificates
```yaml
- name: "Copy certs to {{ pki_cert_dir }} for importing"
  ansible.builtin.copy:
    remote_src: true
    group: "qemu"
    mode: "{{ item.mode | d('0440') }}"
    src: "{{ item.src }}"
    dest: "{{ item.dest }}"
    force: "{{ item.force | d('true') }}"
  loop:
    - { src: "{{ bootstrap_cloudstack__ssl_cert_dir }}/ca.pem", dest: "{{ bootstrap_cloudstack__pki_ca_certs_dir }}/cacert.pem" }
    - { src: "{{ bootstrap_cloudstack__ssl_cert_dir }}/{{ hostname_name_full }}.pem", dest: "{{ bootstrap_cloudstack__libvirt_cert_dir }}/servercert.pem" }
    - { src: "{{ bootstrap_cloudstack__ssl_key_dir }}/{{ hostname_name_full }}-key.pem", dest: "{{ bootstrap_cloudstack__libvirt_cert_dir }}/private/serverkey.pem" }
  register: trust_ca_cacertinstalled
```
Copies SSL certificates and keys to the appropriate directories.

### 7. Mount NFS Secondary Storage
```yaml
- name: Mount NFS secondary storage
  ansible.posix.mount:
    name: "{{ CMConfig.SecondaryMount }}"
    src: "{{ CMConfig.NFSHost }}:{{ CMConfig.NFSSecondaryShare}}"
    fstype: nfs
    state: mounted
  tags:
    - secstorage
    - nfs
```
Mounts NFS secondary storage.

### 8. Restart libvirtd Service
```yaml
- name: Restart libvirtd
  ansible.builtin.service:
    state: restarted
    enabled: true
    name: libvirtd
```
Restarts the `libvirtd` service to apply changes.

### 9. Configure Firewall for CloudStack Node
```yaml
- name: configure firewall for cloudstack node
  when: bootstrap_cloudstack__firewalld_enabled | d(true) | bool
  tags: [ firewall-config-cloudstack ]
  ansible.builtin.include_role:
    name: bootstrap_linux_firewalld
  vars:
    firewalld_action: configure
    firewalld_services: "{{ cloudstack_common_firewalld_services | d([], true) }}"
    firewalld_ports: "{{ bootstrap_cloudstack__firewalld_ports | d([], true) }}"
```
Configures the firewall using the `bootstrap_linux_firewalld` role if enabled.

## OS-Specific Setup

### Debian
No specific tasks are defined in `tasks/setup-Debian.yml`. This file is currently empty and can be extended as needed for Debian-based systems.

### RedHat
```yaml
---
- name: Setting SELINUX to permissive
  ansible.posix.selinux:
    conf: '/etc/selinux/config'
    policy: 'targeted'
    state: 'permissive'
  when: ansible_facts['distribution'] == 'CentOS' or ansible_facts['distribution'] == 'Red Hat Enterprise Linux'
```
Sets SELinux to permissive mode on CentOS and Red Hat Enterprise Linux.

## Handlers

No handlers are defined in `handlers/main.yml`. This file can be extended as needed for tasks that require notifications (e.g., restarting services after configuration changes).

## Usage Example

Here is an example playbook using the `bootstrap_cloudstack` role:

```yaml
---
- name: Bootstrap CloudStack Node
  hosts: cloudstack_nodes
  become: yes
  roles:
    - role: bootstrap_cloudstack
      vars:
        CMConfig:
          NFSHost: "nfs.example.com"
          NFSSecondaryShare: "/exports/secondary"
          SecondaryMount: "/mnt/secondary"
```

This playbook applies the `bootstrap_cloudstack` role to hosts in the `cloudstack_nodes` group, specifying NFS configuration variables.

## Conclusion

The `bootstrap_cloudstack` role provides a comprehensive setup for CloudStack nodes, ensuring that all necessary components are installed and configured correctly. By leveraging OS-specific tasks and conditional logic, this role can be adapted to various environments while maintaining consistency across different distributions.