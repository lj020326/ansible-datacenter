---
title: "Bootstrap Windows Role"
role: roles/bootstrap_windows
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_windows]
---

# Bootstrap Windows Role Documentation

## Purpose

The `bootstrap_windows` role is designed to automate the setup and configuration of Windows systems. It includes tasks such as installing Windows updates, configuring remote desktop settings, enabling firewall rules, setting up OpenSSH, and installing various utilities like BleachBit and UltraDefrag. This role ensures that Windows systems are properly configured and optimized for use in various environments.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `bootstrap_windows_ntp_servers` | `['0.centos.pool.ntp.org', '1.centos.pool.ntp.org', '2.centos.pool.ntp.org']` | List of NTP servers to configure on the Windows system. |
| `bootstrap_windows_allow_windows_reboot_during_win_updates` | `true` | Whether to allow the system to reboot during Windows update installations. |
| `bootstrap_windows_ansible_user` | `ansible` | The username to use for Ansible operations. |
| `bootstrap_windows_ssh_pub_authorized_key` | `{{ lookup('file', '~/.ssh/id_rsa.pub' | expanduser) }}` | The SSH public key to add to the authorized keys. |
| `bootstrap_windows_install_windows_updates` | `false` | Whether to install Windows updates. |
| `bootstrap_windows_install_virtio_drivers` | `false` | Whether to install Virtio drivers. |
| `bootstrap_windows_install_vdagent` | `false` | Whether to install the SPICE vdagent. |
| `bootstrap_windows_bleachbit_url` | `https://download.bleachbit.org/BleachBit-4.4.2-portable.zip` | URL to download BleachBit. |
| `bootstrap_windows_openssh_url` | `https://github.com/PowerShell/Win32-OpenSSH/releases/download/V8.6.0.0p1-Beta/OpenSSH-Win64.zip` | URL to download OpenSSH. |
| `bootstrap_windows_ultradefrag_version` | `7.1.4` | Version of UltraDefrag to install. |
| `bootstrap_windows_ultradefrag_msi_file_name` | `ultradefrag-portable-{{bootstrap_windows_ultradefrag_version}}.bin.amd64.zip` | MSI file name for UltraDefrag. |
| `bootstrap_windows_ultradefrag_download_url` | `https://archiva.admin.dettonville.int/repository/internal/org/dettonville/infra/ultradefrag-portable/{{ bootstrap_windows_ultradefrag_version }}.bin.amd64/{{ bootstrap_windows_ultradefrag_msi_file_name}}` | URL to download UltraDefrag. |
| `bootstrap_windows_vdagent_win_version` | `0.10.0` | Version of the SPICE vdagent to install. |
| `bootstrap_windows_virtio_win_iso_url` | `https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso` | URL to download the Virtio ISO. |
| `bootstrap_windows_virtio_win_iso_path` | `E:\\virtio-win\\` | Path to the Virtio ISO. |
| `bootstrap_windows_putty_regedit` | `path: HKCU:\SOFTWARE\SimonTatham\PuTTY\Sessions\Default%20Settings configs: - name: TCPKeepalives data: 1 type: dword - name: PingIntervalSecs data: 30 type: dword - name: Compression data: 1 - name: AgentFwd data: 1 - name: LinuxFunctionKeys data: 1 - name: MouseIsXterm data: 1 - name: ConnectionSharing data: 1` | Registry settings for PuTTY. |
| `bootstrap_windows_install_vdagent_url` | `https://www.spice-space.org/download/windows/vdagent/vdagent-win-{{ bootstrap_windows_vdagent_win_version }}/vdagent-win-{{ bootstrap_windows_vdagent_win_version }}-x64.zip` | URL to download the SPICE vdagent. |

## Usage

To use the `bootstrap_windows` role, include it in your playbook and configure the variables as needed. Here is an example playbook:

```yaml
---
- hosts: windows
  roles:
    - role: bootstrap_windows
      vars:
        bootstrap_windows_install_windows_updates: true
        bootstrap_windows_install_virtio_drivers: true
        bootstrap_windows_install_vdagent: true
```

To override specific variables, you can define them in your playbook or inventory:

```yaml
---
- hosts: windows
  roles:
    - role: bootstrap_windows
  vars:
    bootstrap_windows_ntp_servers:
      - pool.ntp.org
      - time.google.com
```

## Dependencies

This role requires the following Ansible collections:

- `ansible.windows`
- `community.windows`

Make sure to install these collections before running the playbook:

```bash
ansible-galaxy collection install ansible.windows community.windows
```

## Main Tasks

The `bootstrap_windows` role performs the following main tasks:

- Installs Windows updates (if enabled)
- Configures NTP servers
- Sets up OpenSSH server
- Installs and configures BleachBit
- Installs and configures UltraDefrag
- Installs Virtio drivers (if enabled)
- Installs SPICE vdagent (if enabled)
- Configures PuTTY settings

## Best Practices

- Ensure that the Windows systems are properly configured to allow Ansible to connect and execute tasks.
- Test the role in a development environment before deploying it to production.
- Regularly update the role to include the latest security patches and updates.
- Use specific versions for software downloads to ensure consistency across environments.
- Monitor the execution of Windows updates to avoid unexpected reboots during critical times.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_windows/defaults/main.yml)
- [tasks/install-vdagent.yml](../../roles/bootstrap_windows/tasks/install-vdagent.yml)
- [tasks/install-virtio-drivers.yml](../../roles/bootstrap_windows/tasks/install-virtio-drivers.yml)
- [tasks/install-windows-updates.yml](../../roles/bootstrap_windows/tasks/install-windows-updates.yml)
- [tasks/main.yml](../../roles/bootstrap_windows/tasks/main.yml)