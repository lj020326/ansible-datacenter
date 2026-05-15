```markdown
---
title: bootstrap_ovftool Role Documentation
original_path: roles/bootstrap_ovftool/README.md
category: Ansible Roles
tags: [ansible, ovftool, automation]
---

# bootstrap_ovftool

An Ansible role to automate the downloading and installation of VMware OVF Tool.

## Requirements

- **Ovftool**: Download it from [VMware's official site](https://www.vmware.com/support/developer/ovf/).
- Host the downloaded OVF Tool zip file in a local repository.
- Set the `ovf_zip_url` variable to point to your hosted zip file location.

**Note:** This role currently supports only Debian and Ubuntu distributions.

## Role Variables

**Important:** The non-defaulted variable, `download_site`, must be set via a vars file or another mechanism before invoking this role. It should provide a valid URL base (e.g., `http://mysite.com/downloads`) from which the download files can be obtained.

```yaml
# Temporary directory for storing downloaded and other temporary files.
tmp_dir: "/tmp"

# Ovftool binary to download.
ovf_zip: "VMware-ovftool-4.1.0-2459827-lin.x86_64.zip"

# MD5 hash of the binary to download for verification.
ovf_zip_md5: "63698e602af6e24640146a6592348c99"

# URL to use for downloading the Ovftool binary. Ensure `download_site` is defined.
ovf_zip_url: "{{ download_site }}/{{ ovf_zip }}"

# Directory into which to install the downloaded Ovftool binaries.
ovf_dir: "/usr/local/bin"
```

## Example Playbook

```yaml
---
- hosts: ovftool
  roles:
    - bootstrap_ovftool

- hosts: localhost
  roles:
    - bootstrap_ovftool
```

## Backlinks

- [Ansible Roles Documentation](/ansible-roles)
- [VMware OVF Tool Installation Guide](https://docs.vmware.com/en/VMware-vSphere/7.0/com.vmware.vsphere.vm_admin.doc/GUID-E1BB4B23-698D-4A5F-AE7C-4128FC19B57E.html)
```

This improved version includes a standardized YAML frontmatter with additional metadata, clear headings, and a structured layout. The "Backlinks" section provides references to related documentation for context.