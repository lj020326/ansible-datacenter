---
title: Bootstrap Windows Role Documentation
role: bootstrap_windows
category: Ansible Roles
type: Configuration Management
tags: windows, ansible, automation, configuration
---

## Summary

The `bootstrap_windows` role is designed to automate the initial setup and configuration of Windows machines. It includes tasks for enabling remote desktop, configuring firewall rules, installing necessary software (such as OpenSSH, BleachBit, UltraDefrag), updating system drivers, applying Windows updates, and more. This role ensures that a Windows machine is ready for further automation and management.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `role_bootstrap_windows__ntp_servers` | `['0.centos.pool.ntp.org', '1.centos.pool.ntp.org', '2.centos.pool.ntp.org']` | List of NTP servers to synchronize the system time. |
| `role_bootstrap_windows__allow_windows_reboot_during_win_updates` | `true` | Allows the role to reboot the Windows machine if required during Windows updates installation. |
| `role_bootstrap_windows__ansible_user` | `ansible` | The username for Ansible management on the Windows machine. |
| `role_bootstrap_windows__ssh_pub_authorized_key` | `{{ lookup('file', '~/.ssh/id_rsa.pub' \| expanduser) }}` | The public SSH key to be added to the authorized keys of the Ansible user. |
| `role_bootstrap_windows__install_windows_updates` | `false` | If set to true, the role will install all available Windows updates. |
| `role_bootstrap_windows__install_virtio_drivers` | `false` | If set to true, the role will install VirtIO drivers on the machine. |
| `role_bootstrap_windows__install_vdagent` | `false` | If set to true, the role will install VD Agent for SPICE support. |
| `role_bootstrap_windows__bleachbit_url` | `https://download.bleachbit.org/BleachBit-4.4.2-portable.zip` | URL to download BleachBit portable version. |
| `role_bootstrap_windows__openssh_url` | `https://github.com/PowerShell/Win32-OpenSSH/releases/download/V8.6.0.0p1-Beta/OpenSSH-Win64.zip` | URL to download OpenSSH for Windows. |
| `role_bootstrap_windows__ultradefrag_version` | `7.1.4` | Version of UltraDefrag to install. |
| `role_bootstrap_windows__ultradefrag_msi_file_name` | `ultradefrag-portable-{{ role_bootstrap_windows__ultradefrag_version }}.bin.amd64.zip` | Filename for the UltraDefrag portable version. |
| `role_bootstrap_windows__ultradefrag_download_url` | `https://archiva.admin.dettonville.int/repository/internal/org/dettonville/infra/ultradefrag-portable/{{ role_bootstrap_windows__ultradefrag_version }}.bin.amd64/{{ role_bootstrap_windows__ultradefrag_msi_file_name }}` | URL to download UltraDefrag portable version. |
| `role_bootstrap_windows__vdagent_win_version` | `0.10.0` | Version of VD Agent for Windows. |
| `role_bootstrap_windows__virtio_win_iso_url` | `https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso` | URL to download VirtIO drivers ISO. |
| `role_bootstrap_windows__virtio_win_iso_path` | `E:\\virtio-win\\` | Path where the VirtIO drivers ISO will be mounted or stored. |
| `role_bootstrap_windows__putty_regedit` | `{ path: HKCU:\SOFTWARE\SimonTatham\PuTTY\Sessions\Default%20Settings, configs: [{ name: TCPKeepalives, data: 1, type: dword }, { name: PingIntervalSecs, data: 30, type: dword }, { name: Compression, data: 1 }, { name: AgentFwd, data: 1 }, { name: LinuxFunctionKeys, data: 1 }, { name: MouseIsXterm, data: 1 }, { name: ConnectionSharing, data: 1 }] }` | Configuration for PuTTY default settings. |
| `role_bootstrap_windows__install_vdagent_url` | `https://www.spice-space.org/download/windows/vdagent/vdagent-win-{{ role_bootstrap_windows__vdagent_win_version }}/vdagent-win-{{ role_bootstrap_windows__vdagent_win_version }}-x64.zip` | URL to download VD Agent for Windows. |

## Usage

To use the `bootstrap_windows` role, include it in your playbook and configure the necessary variables as needed:

```yaml
---
- hosts: windows_servers
  roles:
    - role: bootstrap_windows
      vars:
        role_bootstrap_windows__install_windows_updates: true
        role_bootstrap_windows__install_virtio_drivers: true
```

## Dependencies

The `bootstrap_windows` role depends on the following Ansible collections:

- `ansible.windows`
- `community.windows`

Ensure these collections are installed before running the role:

```bash
ansible-galaxy collection install ansible.windows community.windows
```

## Best Practices

1. **Backup Data**: Before applying this role, ensure that all important data is backed up.
2. **Test Environment**: Test the role in a non-production environment to verify its behavior and make necessary adjustments.
3. **Review Variables**: Review and customize variables as per your specific requirements.

## Molecule Tests

This role does not currently include Molecule tests. Consider adding them for automated testing of the role's functionality.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_windows/defaults/main.yml)
- [tasks/install-vdagent.yml](../../roles/bootstrap_windows/tasks/install-vdagent.yml)
- [tasks/install-virtio-drivers.yml](../../roles/bootstrap_windows/tasks/install-virtio-drivers.yml)
- [tasks/install-windows-updates.yml](../../roles/bootstrap_windows/tasks/install-windows-updates.yml)
- [tasks/main.yml](../../roles/bootstrap_windows/tasks/main.yml)