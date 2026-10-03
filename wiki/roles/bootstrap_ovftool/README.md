---
title: "Bootstrap OVFTool"
original_path: roles/bootstrap_ovftool/README.md
category: Ansible Roles
tags: [Ansible, OVFTool, VMware, Debian, Ubuntu]
harvested_date: '2026-08-07T18:07:09.372473+00:00'
source_type: legacy_markdown
---

# Bootstrap OVFTool

Ansible playbook to automate downloading and installing OVFTool.

## Description

OVFTool is a command-line utility that simplifies the process of importing and exporting OVF packages to and from VMware products. This role automates the download and installation of OVFTool on Debian/Ubuntu systems.

## Requirements

OVFTool can be downloaded from [VMware's official site](https://www.vmware.com/support/developer/ovf/). To use this role, you must:
1. Download the OVFTool zip file.
2. Host it in a local repository.
3. Set `ovf_zip_url` to the location where you store it.

This role currently supports only Debian/Ubuntu distributions.

## Role Variables

Note: The non-defaulted variable `download_site` must be set by a vars file or by another mechanism prior to calling this role. The `download_site` must provide a valid URL base (e.g., `http://mysite.com/downloads`) from which the download files (e.g., ISO files or similar) may be obtained. See the `ovf_zip_url` variable below for more details.

```yaml
# The temporary directory to use for storing downloaded and other temporary files.
tmp_dir: "/tmp"

# The OVFTool binary to download.
ovf_zip: "VMware-ovftool-4.1.0-2459827-lin.x86_64.zip"

# The MD5 hash of the binary to download.
ovf_zip_md5: "63698e602af6e24640146a6592348c99"

# The URL to use for downloading the binary.
# Note: You must define the download_site in a vars file.
ovf_zip_url: "{{ download_site }}/{{ ovf_zip }}"

# The directory into which to install the downloaded OVFTool binaries.
ovf_dir: "/usr/local/bin"
```

## Usage

To use this role, you need to set the `download_site` variable in your vars file. For example:

```yaml
download_site: "http://mysite.com/downloads"
```

Then, you can include the role in your playbook:

```yaml
---
- hosts: ovftool
  roles:
    - ovftool
```

## Versioning

To update to a newer version of OVFTool, update the `ovf_zip` variable with the new filename and the `ovf_zip_md5` variable with the new MD5 hash.

## Verification

To verify the integrity of the downloaded file, you can use the `ovf_zip_md5` variable to check the MD5 hash of the file.

## Limitations

This role currently supports only Debian/Ubuntu distributions.

## Dependencies

This role does not have any dependencies.

## License

This role is licensed under the MIT License.

## Contributing

If you would like to contribute to this role, please open an issue or submit a pull request on GitHub.

## Changelog

- 2026-08-07: Initial release.