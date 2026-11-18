---
title: "Bootstrap Webmin Role"
role: roles/bootstrap_webmin
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_webmin]
---

# Bootstrap Webmin Ansible Role

This Ansible role automates the installation and configuration of Webmin, a popular web-based interface for system administration on Unix-like systems. It handles the setup of Webmin, including the installation of required Perl modules, user configuration, and module management.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `bootstrap_webmin__enabled` | `true` | Enable the Webmin installation module. |
| `bootstrap_webmin__base_dir` | `/usr/share/webmin` | Base directory for Webmin installation. |
| `bootstrap_webmin__config_file` | `/etc/webmin/config` | Path to the Webmin configuration file. |
| `bootstrap_webmin__installer_tmpdir` | `/var/tmp` | Temporary directory for the installer. |
| `bootstrap_webmin__tempdir` | `/var/lib/webmin/tmp` | Temporary directory for Webmin. |
| `bootstrap_webmin__tempdelete_days` | `7` | Number of days to retain temporary files. |
| `bootstrap_webmin__remove_repo_after_install` | `true` | Remove the Webmin repository after installation. |
| `bootstrap_webmin__restart_after_install` | `true` | Restart Webmin service after installation. |
| `bootstrap_webmin__repo_installer_source` | `local` | Source of the repository installer (local or github). |
| `bootstrap_webmin__repo_installer_url` | `https://raw.githubusercontent.com/webmin/webmin/master/webmin-setup-repo.sh` | URL for the Webmin repository installer script. |
| `bootstrap_webmin__repo_files` | `["webmin.list"]` | List of repository files to manage. |
| `bootstrap_webmin__repo_key_url` | `https://download.webmin.com/developers-key.asc` | URL for the Webmin repository key. |
| `bootstrap_webmin__modules` | `[{"url": "https://download.webmin.com/download/modules/disk-usage-1.2.wbm.gz"}]` | List of Webmin modules to install. |
| `bootstrap_webmin__packages` | `["perl-Env", "perl-App-cpanminus", "perl-CPAN", "perl-JSON", "perl-JSON-PP", "perl-Encode-Detect", "perl-Net-SSLeay"]` | List of Perl packages required by Webmin. |
| `bootstrap_webmin__user_hash_seed` | `4556li5j56hu5y` | Seed for user password hashing. |
| `bootstrap_webmin__user_group` | `webmin` | Group for Webmin users. |
| `bootstrap_webmin__user_shell` | `/bin/bash` | Default shell for Webmin users. |
| `bootstrap_webmin__user_username` | `webmin` | Default username for Webmin. |
| `bootstrap_webmin__user_password` | `change!me!` | Default password for Webmin. |
| `bootstrap_webmin__users` | `[{"username": "{{ bootstrap_webmin__user_username }}", "password": "{{ bootstrap_webmin__user_password }}"}]` | List of Webmin users to create. |
| `bootstrap_webmin__user_groups` | `{"RedHat": ["adm"], "CentOS": ["adm"], "Fedora": ["adm"], "Scientific": ["adm"], "Debian": ["adm", "cdrom", "dip", "plugdev"], "Ubuntu": ["adm", "cdrom", "dip", "plugdev"]}` | Groups to add Webmin users to, based on distribution. |
| `bootstrap_webmin__user_acls` | `[...]` | List of ACLs to configure for Webmin users. |
| `bootstrap_webmin__perl_mm_use_default` | `1` | Use default settings for Perl module installation. |
| `bootstrap_webmin__repo_url` | `https://download.webmin.com/download/newkey/repository` | URL for the Webmin repository. |
| `bootstrap_webmin__repo_key_download` | `/tmp/webmin-keyring.gpg` | Path to download the Webmin repository key. |
| `bootstrap_webmin__apt_keyring_dir` | `/usr/share/keyrings` | Directory for APT keyrings. |
| `bootstrap_webmin__apt_repo_key_type` | `trust_store` | Type of APT repository key. |
| `bootstrap_webmin__apt_repo_keyring_file` | `{{ bootstrap_webmin__apt_keyring_dir }}/webmin-keyring.gpg` | Path to the APT repository keyring file. |
| `bootstrap_webmin__apt_repo_template` | `webmin.debian.repo.j2` | Template for the APT repository configuration. |
| `bootstrap_webmin__apt_repo_version` | `"stable"` | Version of the Webmin repository. |
| `bootstrap_webmin__apt_repo_spec` | `deb [arch=amd64 signed-by={{ bootstrap_webmin__apt_repo_keyring_file }}] {{ bootstrap_webmin__repo_url }} {{ bootstrap_webmin__apt_repo_version }} contrib` | Specification for the APT repository. |

## Usage

To use this role, include it in your playbook and set the desired variables:

```yaml
- hosts: webservers
  roles:
    - role: bootstrap_webmin
      vars:
        bootstrap_webmin__enabled: true
        bootstrap_webmin__user_password: "new_secure_password"
```

## Dependencies

This role does not have any external dependencies.

## Best Practices

1. **Security**: Always change the default Webmin password and ensure secure communication by configuring SSL/TLS.
2. **Backup**: Regularly back up the Webmin configuration files.
3. **Updates**: Keep Webmin and its modules up to date to benefit from the latest features and security patches.
4. **Monitoring**: Monitor the Webmin service to ensure it is running smoothly.

## Related Files

- [defaults/main.yml](../../roles/bootstrap_webmin/defaults/main.yml)
- [tasks/install.yml](../../roles/bootstrap_webmin/tasks/install.yml)
- [tasks/main.yml](../../roles/bootstrap_webmin/tasks/main.yml)
- [tasks/setup-modules.yml](../../roles/bootstrap_webmin/tasks/setup-modules.yml)
- [tasks/setup-users.yml](../../roles/bootstrap_webmin/tasks/setup-users.yml)
- [handlers/main.yml](../../roles/bootstrap_webmin/handlers/main.yml)