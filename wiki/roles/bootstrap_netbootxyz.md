---
title: "Bootstrap Netbootxyz Role"
role: roles/bootstrap_netbootxyz
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_netbootxyz]
---

# Role Documentation: `bootstrap_netbootxyz`

## Overview

The `bootstrap_netbootxyz` Ansible role is designed to automate the generation and deployment of iPXE bootloaders, menus, and related assets for a netboot environment. This role supports multiple architectures including ARM, x86_64 (EFI and Legacy BIOS), Raspberry Pi, and hybrid images. It also handles the creation of checksums, signatures, and custom menus.

## Role Path

```
roles/bootstrap_netbootxyz
```

## Default Variables

The `defaults/main.yml` file contains default variables that can be overridden by inventory or playbook-specific values.

### Key Variables

- **boot_domain**: The domain name for the netboot environment.
  - Default: `boot.netboot.xyz`
  
- **boot_timeout**: Timeout value in milliseconds for booting.
  - Default: `300000`
  
- **boot_version**: Version of the iPXE bootloader.
  - Default: `2.x`
  
- **bootloader_disks**: List of disks to build iPXE bootloaders for.
  - Example:
    ```yaml
    bootloader_disks:
      - netboot.xyz
    ```
  
- **bootloader_http_enabled**: Enable HTTP service for serving bootloaders and assets.
  - Default: `true`
  
- **bootloader_https_enabled**: Enable HTTPS service for serving bootloaders and assets.
  - Default: `true`

### Bootloader Types

The role supports various types of iPXE bootloaders, categorized by architecture:

- **arm**
- **hybrid**
- **legacy**
- **multiarch**
- **rpi**
- **uefi**

Each category contains a list of bootloader configurations with descriptions and file details.

## Tasks

### `generate_checksums.yml`

Generates checksums for all created iPXE bootloaders and creates an index template.

- **Tasks:**
  - Registers a listing of all created iPXE bootloaders.
  - Generates the current date.
  - Gathers SHA256 checksums for each bootloader file.
  - Generates a checksums file using a Jinja2 template.
  - Optionally generates a site name banner for the index page if on Debian-based systems.
  - Resets the bootloader filename to the first in the list.
  - Generates an `index.html` template.

### `generate_cloudinits.yml`

Creates directories and generates cloud-init templates for specified operating system distributions.

- **Tasks:**
  - Creates a directory for each distribution's autoinstall files.
  - Generates cloud-init configuration files from Jinja2 templates.

### `generate_disks.yml`

Manages the generation of iPXE bootloaders based on architecture-specific tasks.

- **Tasks:**
  - Sets up the iPXE build environment.
  - Includes tasks to generate bootloaders for different architectures (legacy, linux, EFI, ARM, RPI, hybrid).

### `generate_disks_arm.yml`

Generates iPXE bootloaders specifically for ARM architectures.

- **Tasks:**
  - Copies local EFI iPXE configurations.
  - Sets trust files based on signature generation settings.
  - Applies a workaround for ARM compilation.
  - Compiles the iPXE bootloader for EFI ARM64.
  - Copies compiled binaries to the HTTP directory.

### `generate_disks_base.yml`

Sets up the base environment and checks out the latest iPXE sources.

- **Tasks:**
  - Gathers facts about the system.
  - Includes variables specific to the operating system.
  - Ensures EPEL is enabled on CentOS systems.
  - Creates necessary directories for iPXE files.
  - Copies helper applications (memdisk, wimboot).
  - Installs required packages.
  - Checks out the latest iPXE sources from a specified repository.
  - Copies an iPXE bootloader template to the source directory.
  - Touches local configuration files in the iPXE source.
  - Retrieves the iPXE CA certificate.

### `generate_disks_efi.yml`

Generates iPXE bootloaders for EFI architectures.

- **Tasks:**
  - Copies local EFI iPXE configurations.
  - Sets trust files based on signature generation settings.
  - Compiles the iPXE bootloader for EFI.
  - Generates hybrid ISO and USB images for EFI bootloaders.
  - Copies compiled binaries to the HTTP directory.

### `generate_disks_hybrid.yml`

Generates hybrid iPXE images that support both Legacy BIOS and EFI architectures.

- **Tasks:**
  - Generates hybrid ISO and USB images based on specified conditions.

### `generate_disks_legacy.yml`

Generates iPXE bootloaders for Legacy BIOS systems.

- **Tasks:**
  - Copies local legacy iPXE configurations.
  - Sets trust files based on signature generation settings.
  - Compiles the iPXE bootloader for Legacy BIOS.
  - Copies compiled binaries to the HTTP directory.

### `generate_disks_linux.yml`

Generates iPXE bootloaders specifically for Linux systems using Legacy BIOS.

- **Tasks:**
  - Copies local legacy iPXE configurations.
  - Sets trust files based on signature generation settings.
  - Compiles the iPXE bootloader with or without debug flags.
  - Copies compiled binaries to the HTTP directory.

### `generate_disks_rpi.yml`

Generates iPXE bootloaders specifically for Raspberry Pi systems.

- **Tasks:**
  - Installs required packages.
  - Checks out the latest pipxe sources.
  - Copies an iPXE bootloader template and local configurations.
  - Compiles the iPXE bootloader for RPI.
  - Copies compiled binaries to the HTTP directory.

### `generate_mac_configs.yml`

Generates default PXE files for each distribution and sets a specific PXE menu based on MAC addresses.

- **Tasks:**
  - Generates default PXE files from templates.
  - Sets the PXE menu to install based on host variables.

### `generate_menus.yml`

Generates iPXE menus and related configuration files.

- **Tasks:**
  - Combines overrides with release defaults.
  - Sets releases with user overrides.
  - Generates directories for menu files.
  - Sets the menu version.
  - Generates a version file.
  - Generates netboot.xyz source files from templates.
  - Retrieves `pciids.ipxe`.

### `generate_menus_custom.yml`

Generates custom iPXE menus based on provided templates.

- **Tasks:**
  - Generates directories for custom menus.
  - Generates custom user menu templates from Jinja2 templates.

### `generate_signatures.yml`

Generates digital signatures for source files using OpenSSL.

- **Tasks:**
  - Gathers a list of source files.
  - Creates directories for signatures.
  - Generates signatures for each source file.

### `main.yml`

The main entry point for the role, which orchestrates the execution of other tasks based on conditions.

- **Tasks:**
  - Prints the list of bootloader disks to build.
  - Includes tasks to generate menus if enabled.
  - Includes tasks to generate custom menus if enabled.
  - Includes tasks to generate iPXE bootloaders for each specified disk.
  - Includes tasks to generate checksums if enabled.
  - Includes tasks to generate signatures if enabled.

## Usage

To use the `bootstrap_netbootxyz` role, include it in your playbook and optionally override any default variables as needed.

### Example Playbook

```yaml
---
- name: Bootstrap netboot environment
  hosts: all
  become: yes
  roles:
    - role: bootstrap_netbootxyz
      vars:
        boot_domain: mynetboot.example.com
        bootloader_disks:
          - custom-bootloader
```

## Notes

- Double-underscore variables are internal and should not be modified.
- The role does not invent related roles; all necessary tasks are included within this role.
- Ensure that the required packages and dependencies are installed on your system before running the playbook.

This documentation provides a comprehensive overview of the `bootstrap_netbootxyz` Ansible role, detailing its purpose, variables, tasks, and usage.