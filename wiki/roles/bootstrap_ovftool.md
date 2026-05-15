---
title: "Bootstrap OVFTool Role Documentation"
role: bootstrap_ovftool
category: Ansible Roles
type: Installation
tags: ovftool, vmware, automation
---

## Summary

The `bootstrap_ovftool` role is designed to automate the installation of VMware's OVF Tool on a target system. This tool is essential for managing and deploying Open Virtualization Format (OVF) files, which are used to package virtual machines and their configurations.

## Variables

| Variable Name                  | Default Value                                                                                          | Description                                                                                                                                 |
|--------------------------------|--------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------|
| `ovftool_download_dir`         | `/tmp`                                                                                                 | The directory where the OVF Tool bundle file will be downloaded.                                                                            |
| `ovftool_bundle_file`          | `VMware-ovftool-4.3.0-7948156-lin.x86_64.bundle`                                                        | The filename of the OVF Tool bundle to be downloaded.                                                                                         |
| `ovftool_bundle_file_md5`      | `63698e602af6e24640146a6592348c99`                                                                       | The MD5 checksum of the OVF Tool bundle file to ensure integrity upon download.                                                              |
| `ovftool_bundle_file_url`      | `"{{ download_site }}/{{ ovftool_bundle_file }}"`                                                      | The URL from which the OVF Tool bundle will be downloaded. This variable is dynamically constructed using the `download_site` and `ovftool_bundle_file`. |
| `ovf_dir`                      | `/usr`                                                                                                 | The directory where the OVF Tool will be installed.                                                                                           |

## Usage

To use this role, include it in your Ansible playbook as follows:

```yaml
- hosts: all
  roles:
    - bootstrap_ovftool
```

Ensure that the `download_site` variable is defined in your inventory or playbook to specify where the OVF Tool bundle can be downloaded from. For example:

```yaml
download_site: "https://packages.vmware.com/tools/ovf"
```

## Dependencies

- The role requires the `unzip` package to be installed on the target system, which is handled by the role itself.
- On Ubuntu systems, a symbolic link for `libncursesw.so.5` pointing to `libncursesw.so.6` is created to resolve compatibility issues.

## Best Practices

- Always ensure that the `download_site` variable points to a reliable and secure source for downloading the OVF Tool bundle.
- Verify the MD5 checksum of the downloaded file to confirm its integrity before proceeding with installation.
- Consider using Ansible's `become` directive to run tasks with elevated privileges, as required by this role.

## Molecule Tests

This role does not include any Molecule tests at this time. Future updates may introduce test scenarios to validate the functionality of the role.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_ovftool/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_ovftool/tasks/main.yml)

---

This documentation provides a comprehensive overview of the `bootstrap_ovftool` Ansible role, detailing its purpose, configuration options, usage instructions, and dependencies. For more detailed information or troubleshooting, refer to the linked source files.