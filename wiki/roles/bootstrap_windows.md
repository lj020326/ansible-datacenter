---
title: Bootstrap Windows Role Documentation
role: bootstrap_windows
category: Ansible Roles
type: Configuration Management
tags: ansible, windows, automation, configuration
---

## Summary

The `bootstrap_windows` role is designed to perform initial setup and configuration tasks on Windows machines. This includes enabling Remote Desktop, configuring firewall rules, downloading and installing necessary tools like OpenSSH, BleachBit, UltraDefrag, and optionally VirtIO drivers and Windows updates. The role also handles the installation of VD Agent for SPICE integration.

## Variables

| Variable Name                                             | Default Value                                                                                           | Description                                                                                                                                                                                                 |
|-----------------------------------------------------------|---------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_windows_ntp_servers`                           | `['0.centos.pool.ntp.org', '1.centos.pool.ntp.org', '2.centos.pool.ntp.org']`                          | List of NTP servers to synchronize the system clock.                                                                                                                                                            |
| `bootstrap_windows_allow_windows_reboot_during_win_updates` | `true`                                                                                                  | Whether to allow reboots during Windows updates installation.                                                                                                                                                |
| `bootstrap_windows_ansible_user`                          | `ansible`                                                                                               | The username for Ansible management on the target machine.                                                                                                                                                  |
| `bootstrap_windows_ssh_pub_authorized_key`                | `{{ lookup('file', '~/.ssh/id_rsa.pub' \| expanduser) }}`                                                | Public SSH key to be added to the authorized keys of the specified user.                                                                                                                                    |
| `bootstrap_windows_install_windows_updates`               | `false`                                                                                                 | Whether to install Windows updates during the bootstrap process.                                                                                                                                            |
| `bootstrap_windows_install_virtio_drivers`                | `false`                                                                                                 | Whether to install VirtIO drivers for virtualized environments.                                                                                                                                             |
| `bootstrap_windows_install_vdagent`                       | `false`                                                                                                 | Whether to install VD Agent for SPICE integration.                                                                                                                                                          |
| `bootstrap_windows_bleachbit_url`                         | `https://download.bleachbit.org/BleachBit-4.4.2-portable.zip`                                            | URL to download BleachBit portable version.                                                                                                                                                                   |
| `bootstrap_windows_openssh_url`                           | `https://github.com/PowerShell/Win32-OpenSSH/releases/download/V8.6.0.0p1-Beta/OpenSSH-Win64.zip`        | URL to download OpenSSH for Windows.                                                                                                                                                                        |
| `bootstrap_windows_ultradefrag_version`                   | `7.1.4`                                                                                                 | Version of UltraDefrag to be installed.                                                                                                                                                                       |
| `bootstrap_windows_ultradefrag_msi_file_name`             | `ultradefrag-portable-{{ bootstrap_windows_ultradefrag_version }}.bin.amd64.zip`                         | Filename for the UltraDefrag portable version.                                                                                                                                                                |
| `bootstrap_windows_ultradefrag_download_url`              | `https://archiva.admin.dettonville.int/repository/internal/org/dettonville/infra/ultradefrag-portable/{{ bootstrap_windows_ultradefrag_version }}.bin.amd64/{{ bootstrap_windows_ultradefrag_msi_file_name}}` | URL to download UltraDefrag portable version.                                                                                                                                                                 |
| `bootstrap_windows_vdagent_win_version`                   | `0.10.0`                                                                                                | Version of VD Agent for Windows.                                                                                                                                                                              |
| `bootstrap_windows_virtio_win_iso_url`                    | `https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso`            | URL to download the VirtIO drivers ISO file.                                                                                                                                                                  |
| `bootstrap_windows_virtio_win_iso_path`                   | `E:\\virtio-win\\`                                                                                      | Path where the VirtIO drivers ISO will be mounted or already exists.                                                                                                                                        |
| `bootstrap_windows_putty_regedit`                         | `{ path: HKCU:\SOFTWARE\SimonTatham\PuTTY\Sessions\Default%20Settings, configs: [...] }`                 | Registry settings for PuTTY default session configuration.                                                                                                                                                  |

## Usage

To use the `bootstrap_windows` role in your Ansible playbook, include it as follows:

```yaml
- hosts: windows_servers
  roles:
    - role: bootstrap_windows
      vars:
        bootstrap_windows_install_virtio_drivers: true
        bootstrap_windows_install_windows_updates: true
```

## Dependencies

This role does not have any external dependencies beyond the standard Ansible modules and Windows-specific modules provided by `ansible.windows` and `community.windows`.

## Best Practices

- Ensure that the target machines are reachable via WinRM.
- Configure appropriate permissions for the Ansible user to perform administrative tasks on the target machines.
- Verify network connectivity to the URLs specified in the variables, especially if using a proxy or restricted network environment.

## Molecule Tests

This role does not include any Molecule tests. To ensure the role functions correctly, it is recommended to manually test the role in a controlled environment before deploying it in production.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_windows/defaults/main.yml)
- [tasks/install-vdagent.yml](../../roles/bootstrap_windows/tasks/install-vdagent.yml)
- [tasks/install-virtio-drivers.yml](../../roles/bootstrap_windows/tasks/install-virtio-drivers.yml)
- [tasks/install-windows-updates.yml](../../roles/bootstrap_windows/tasks/install-windows-updates.yml)
- [tasks/main.yml](../../roles/bootstrap_windows/tasks/main.yml)