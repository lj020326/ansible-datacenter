---
title: "Bootstrap OVFTool Role"
role: bootstrap_ovftool
category: System Tools
type: Role Documentation
tags: [ansible, role, bootstrap_ovftool]
---

# Bootstrap OVFTool Role

The `bootstrap_ovftool` role is designed to automate the installation and setup of VMware's OVF Tool on Linux systems. OVF Tool is a command-line utility that simplifies the process of importing and exporting OVF and OVA virtual appliances. This role ensures that the OVF Tool is properly installed, including handling necessary dependencies and creating required symbolic links on specific distributions like Ubuntu.

## Variables

| Variable Name                | Default Value                                 | Description                                                                 |
|------------------------------|-----------------------------------------------|-----------------------------------------------------------------------------|
| `ovftool_download_dir`       | `/tmp`                                        | Directory where the OVF Tool bundle file will be downloaded.                 |
| `ovftool_bundle_file`        | `VMware-ovftool-4.3.0-7948156-lin.x86_64.bundle` | The name of the OVF Tool bundle file to be downloaded.                       |
| `ovftool_bundle_file_md5`    | `63698e602af6e24640146a6592348c99`           | The MD5 checksum of the OVF Tool bundle file for verification.              |
| `ovftool_bundle_file_url`    | `{{ download_site }}/{{ ovftool_bundle_file }}` | The URL from which to download the OVF Tool bundle file.                     |
| `ovf_dir`                    | `/usr`                                        | The directory where OVF Tool will be installed.                              |

## Usage

To use this role, include it in your playbook and set any necessary variables. Here is an example playbook:

```yaml
---
- hosts: all
  roles:
    - role: bootstrap_ovftool
      vars:
        download_site: "https://example.com/downloads"  # Replace with actual URL
```

## Dependencies

This role requires the `unzip` package to be installed on the target system. The role will install this package if it is not already present.

## Best Practices

1. **Verify Download URLs**: Ensure that the `download_site` variable points to a valid and secure location where the OVF Tool bundle file can be downloaded.
2. **Checksum Verification**: The role verifies the MD5 checksum of the downloaded file to ensure its integrity. You can verify the checksum using tools like `md5sum`:
   ```bash
   md5sum VMware-ovftool-4.3.0-7948156-lin.x86_64.bundle
   ```
   Ensure that the `ovftool_bundle_file_md5` variable matches the checksum of the file you intend to download.
3. **Symbolic Links**: On Ubuntu systems, the role creates a symbolic link for `libncursesw.so.5` to `libncursesw.so.6`. Ensure that this link is appropriate for your system's configuration. You can verify the symbolic link using:
   ```bash
   ls -l /path/to/libncursesw.so.5
   ```
4. **Privileged Execution**: The role requires elevated privileges to install the OVF Tool. Ensure that the playbook is executed with the necessary permissions.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_ovftool/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_ovftool/tasks/main.yml)