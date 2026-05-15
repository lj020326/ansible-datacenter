```markdown
---
title: Unattend Automatic Install Config Files Documentation
original_path: roles/deploy_vm/files/autoinstall/README.md
category: Configuration
tags: [unattended-install, autoinstall, CentOS, RHEL, SLES, SLED, Windows, PhotonOS, Ubuntu, Debian, UnionTechOS, Fedora]
---

# Unattend Automatic Install Config Files

This document provides guidance on using unattend automatic install configuration files for various operating systems.

## Configuration File Paths

1. **CentOS 7.x**: Use files under `CentOS/7` or `RHEL/7`.
2. **RHEL-like Varieties 7.x**: Use files under `RHEL/7`.
3. **RHEL-like Varieties 8.x and Later**: Use files under `RHEL/8`.
4. **SLES 15 SP3 and Later**:
   - Full Installation: Use files under `SLE/15/SP3/SLES`.
   - Minimal Installation: Use files under `SLE/15/SP3/SLES_Minimal`.
5. **SLED 15 SP3**: Use `SLE/15/SP3/SLED/autoinst.xml`.
6. **SLED 15 SP4**: Use `SLE/15/SP4/SLED/autoinst.xml`.
7. **Windows 10 or Windows 11 with TPM Device**: Use files under `Windows/win10`.
8. **Windows 11 without TPM Device**: Use files under `Windows/win11` to bypass TPM check during installation.
9. **Windows Server LTSC**: Use files under `Windows/win_server`.
10. **Windows Server SAC**: Use files under `Windows/win_server_sac`.
11. **Photon OS 3.0 and Later**: Use file `Photon/ks.cfg`.
12. **Ubuntu Server 20.04 and Later**: Use file `Ubuntu/Server/user-data.j2`.
13. **Ubuntu Desktop 20.04 and Later**: Use file `Ubuntu/Desktop/ubuntu.seed`.
14. **Debian 10.x and 11.x**: Use file `Debian/10/preseed.cfg`.
15. **UnionTech OS Server 20 1050a**: Use file `UOS/Server/20/1050a/ks.cfg`.
16. **UnionTech OS Server 20 1050e**: Use file `UOS/Server/20/1050e/ks.cfg`.
17. **Fedora Server 36 and Later**: Use file `Fedora/36/Server/ks.cfg`.

## Notes

### For Windows

- If the OS auto-install process does not proceed as expected or if errors appear in the VM console, set the parameter `windows_product_key` in the `vars/test.yml` file with a valid license key and try again.
- Refer to [Windows KMS Client Setup Key](https://docs.microsoft.com/en-us/windows-server/get-started/kmsclientkeys) for more information.

## Backlinks

- [Main Documentation Index](../README.md)
```

This version of the documentation is structured clearly, uses proper Markdown formatting, and includes a YAML frontmatter with additional metadata. The "Backlinks" section provides a link back to the main documentation index for easy navigation.