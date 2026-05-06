---
title: "Bootstrap Cobbler Role"
role: roles/bootstrap_cobbler
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_cobbler]
---

# Role Documentation: `bootstrap_cobbler`

## Overview

The `bootstrap_cobbler` Ansible role is designed to automate the installation and configuration of Cobbler, a Linux provisioning system that allows for rapid deployment of systems. This role supports both Debian-based and RedHat-based distributions.

## Role Variables

### Default Variables (`defaults/main.yml`)

| Variable                           | Description                                                                                       | Default Value                                                                                                                                                                                                 |
|------------------------------------|---------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `cobbler_default_password_crypted` | The crypted password for the Cobbler user.                                                        | `$1$asdf3421$dEw9zCFxyo9KG3Y2xsd/n0`                                                                                                                                                                      |
| `cobbler_web_password_crypted`     | The crypted password for the Cobbler web interface.                                               | `a2d6bae81669d707b72c0bd9806e01f3`                                                                                                                                                                        |
| `cobbler_pxe_just_once`            | If set to true, PXE boot will only occur once for each system.                                      | `true`                                                                                                                                                                                                        |
| `cobbler_manage_dhcp`              | Whether Cobbler should manage DHCP.                                                               | `false`                                                                                                                                                                                                       |
| `cobbler_manage_dns`               | Whether Cobbler should manage DNS.                                                                | `false`                                                                                                                                                                                                       |
| `cobbler_isos_path`                | The path where ISO images are stored.                                                             | `/etc/cobbler/distro-isos`                                                                                                                                                                                  |
| `cobbler_isos_mount_path`          | The mount point for ISO images.                                                                   | `/mnt/cobbler`                                                                                                                                                                                              |
| `cobbler_isos_delete`              | Whether to delete ISO images after mounting.                                                      | `true`                                                                                                                                                                                                        |
| `cobbler_profiles`                 | A list of profiles to be created in Cobbler, each with a name, architecture, and URL.             | `[ { name: centos7, arch: x86_64, url: http://mirror.switch.ch/ftp/mirror/centos/7/isos/x86_64/CentOS-7-x86_64-DVD-1611.iso } ]`                                                                             |
| `cobbler_kickstart_path`           | The path where kickstart files are stored.                                                        | `/var/lib/cobbler/kickstarts`                                                                                                                                                                               |
| `cobbler_templates_force`          | Whether to force the update of Cobbler templates.                                                 | `true`                                                                                                                                                                                                        |
| `cobbler_firewalld_services`       | A list of services to be managed by firewalld.                                                    | `[]`                                                                                                                                                                                                          |
| `bind_packages`                    | Packages required for DNS management, specific to Debian and RedHat.                              | `{ Debian: [ bind9, bind9utils ], RedHat: [ bind, bind-utils, bind-chroot ] }`                                                                                                                               |
| `dhcp_packages`                    | Packages required for DHCP management, specific to Debian and RedHat.                             | `{ Debian: [ isc-dhcp-server ], RedHat: [ dhcp-common ] }`                                                                                                                                                   |
| `cobbler_depends_packages`         | Additional dependencies required by Cobbler, specific to Debian and RedHat.                       | `{ Debian: [ python-jsonschema, python-yaml, cobbler, syslinux-common, debian-installer-8-netboot-amd64, tftpd-hpa, xinetd, fence-agents, ipmitool, shim-signed, grub-efi-amd64-signed ], RedHat: [ createrepo, httpd, mod_wsgi, mod_ssl, python-cheetah, python-netaddr, python-simplejson, python-urlgrabber, PyYAML, rsync, syslinux, tftp-server, yum-utils, python-django, debmirror, pykickstart, fence-agents-all, nano, xinetd ] }` |
| `cobbler_packages`                 | Main Cobbler packages to be installed, specific to Debian and RedHat.                             | `{ Debian: [ cobbler ], RedHat: [ cobbler, cobbler-web ] }`                                                                                                                                                   |
| `cobbler_build_packages`           | Additional build-related packages required by Cobbler, specific to Debian and RedHat.             | `{ Debian: [ make, openssl, python-devel, python-cheetah, python-yaml, python-netaddr, python-simplejson, python-urlgrabber, libapache2-mod-wsgi, python-django, atftpd ], RedHat: [ make, openssl, httpd-devel, mod_wsgi, python-devel, python-cheetah ] }` |

## Tasks

### `tasks/main.yml`

1. **Set OS specific variables**
   - Includes OS-specific variable files based on the distribution or OS family.
   
2. **Ensure required packages are installed**
   - Installs the main Cobbler packages as specified in `cobbler_packages`.

3. **Ensure BIND is installed**
   - Conditionally installs BIND packages if DNS management is enabled.

4. **Ensure DHCP is installed**
   - Conditionally installs DHCP packages if DHCP management is enabled.

5. **RedHat | Ensure HTTPD is setup**
   - Configures and starts necessary services for RedHat-based systems:
     - Enables SELinux boolean `httpd_can_network_connect`.
     - Starts and enables `httpd`, `xinetd`, `named-chroot` (if DNS management is enabled), `dhcpd` (if DHCP management is enabled), and `cobblerd`.
   
6. **Copy modern Django URLs**
   - Copies updated URL configuration files for the Cobbler web interface.

7. **Update modern Django settings/URLs**
   - Updates Django settings using templates.

8. **Ensure Cobbler templates are present**
   - Ensures that necessary Cobbler templates are in place, optionally forcing their update based on `cobbler_templates_force`.

### `tasks/redhat.yml`

This file is essentially a duplicate of the relevant tasks from `tasks/main.yml` and is included for RedHat-based systems. It ensures that the same set of tasks are executed specifically for RedHat distributions.

## Handlers

### `handlers/main.yml`

1. **Restart Apache**
   - Restarts the Apache service to apply configuration changes.
   
2. **Restart Cobblerd**
   - Restarts the Cobbler daemon to apply configuration changes.
   
3. **Cobbler Sync**
   - Executes a Cobbler sync operation, which synchronizes all data with the filesystem.
   
4. **Reload Firewalld**
   - Reloads the firewalld service to apply any new rules or configurations.
   
5. **Restart Firewalld**
   - Restarts the firewalld service, tagged for specific use cases.

## Notes

- **Double-underscore variables** are internal only and should not be modified directly.
- This role does not invent related roles; all necessary tasks are encapsulated within this role.
- The documentation is formatted using standard GitHub Markdown for readability and consistency.

This comprehensive guide provides a detailed understanding of the `bootstrap_cobbler` Ansible role, its variables, tasks, and handlers.