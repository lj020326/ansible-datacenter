---
title: Bootstrap Webmin Role Documentation
role: bootstrap_webmin
category: Ansible Roles
type: Configuration Management
tags: webmin, ansible, automation
---

## Summary

The `bootstrap_webmin` role is designed to automate the installation and configuration of Webmin on various Linux distributions. It handles repository setup, package installation, user creation, module downloads, and configuration adjustments for optimal performance.

## Variables

| Variable Name                             | Default Value                                                                                           | Description                                                                                                                                                                                                 |
|-------------------------------------------|---------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_webmin__enabled`               | `true`                                                                                                  | Enable or disable the role.                                                                                                                                                                                 |
| `bootstrap_webmin__base_dir`              | `/usr/share/webmin`                                                                                     | Base directory for Webmin installation.                                                                                                                                                                     |
| `bootstrap_webmin__config_file`           | `/etc/webmin/config`                                                                                    | Path to the Webmin configuration file.                                                                                                                                                                      |
| `bootstrap_webmin__tempdir`               | `/var/lib/webmin/tmp`                                                                                   | Temporary directory used by Webmin.                                                                                                                                                                         |
| `bootstrap_webmin__tempdelete_days`       | `7`                                                                                                     | Number of days after which old temporary files are deleted.                                                                                                                                                 |
| `bootstrap_webmin__remove_repo_after_install` | `true`                                                                                                | Remove the repository configuration file after installation.                                                                                                                                                |
| `bootstrap_webmin__restart_after_install`   | `true`                                                                                                | Restart Webmin service after installation.                                                                                                                                                                  |
| `bootstrap_webmin__repo_installer_source` | `local`                                                                                                 | Source of the repository installer script (`github` or `local`).                                                                                                                                            |
| `bootstrap_webmin__repo_installer_url`    | `https://raw.githubusercontent.com/webmin/webmin/master/webmin-setup-repo.sh`                         | URL for downloading the repository installer script.                                                                                                                                                        |
| `bootstrap_webmin__repo_files`            | `['webmin.list']`                                                                                       | List of repository configuration files to manage.                                                                                                                                                           |
| `bootstrap_webmin__repo_key_url`          | `https://download.webmin.com/developers-key.asc`                                                        | URL for downloading the repository key.                                                                                                                                                                     |
| `bootstrap_webmin__modules`               | `[{'url': 'https://download.webmin.com/download/modules/disk-usage-1.2.wbm.gz'}]`                      | List of Webmin modules to download and install.                                                                                                                                                           |
| `bootstrap_webmin__packages`              | `['perl-Env', 'perl-App-cpanminus', 'perl-CPAN', 'perl-JSON', 'perl-JSON-PP', 'perl-Encode-Detect', 'perl-Net-SSLeay']` | List of required Perl packages.                                                                                                                                                                             |
| `bootstrap_webmin__user_hash_seed`        | `4556li5j56hu5y`                                                                                        | Seed for generating hashed passwords.                                                                                                                                                                       |
| `bootstrap_webmin__user_group`            | `webmin`                                                                                                | Group name for Webmin users.                                                                                                                                                                                |
| `bootstrap_webmin__user_shell`            | `/bin/bash`                                                                                             | Shell for Webmin users.                                                                                                                                                                                     |
| `bootstrap_webmin__user_username`         | `webmin`                                                                                                | Username for the default Webmin user.                                                                                                                                                                       |
| `bootstrap_webmin__user_password`         | `change!me!`                                                                                            | Password for the default Webmin user (plain text, will be hashed).                                                                                                                                          |
| `bootstrap_webmin__users`                 | `[{'username': '{{ bootstrap_webmin__user_username }}', 'password': '{{ bootstrap_webmin__user_password }}'}]` | List of users to create with their respective passwords.                                                                                                                                                  |
| `bootstrap_webmin__user_groups`           | RedHat: `['adm']`, CentOS: `['adm']`, Fedora: `['adm']`, Scientific: `['adm']`, Debian: `['adm', 'cdrom', 'dip', 'plugdev']`, Ubuntu: `['adm', 'cdrom', 'dip', 'plugdev']` | Groups to which Webmin users will be added based on the distribution.                                                                                                                                       |
| `bootstrap_webmin__user_acls`             | List of ACLs for Webmin modules (e.g., `acl`, `adsl-client`, etc.)                                       | Access Control Lists for Webmin modules.                                                                                                                                                                    |
| `bootstrap_webmin__perl_mm_use_default`   | `1`                                                                                                     | Environment variable to use default values during Perl module installation.                                                                                                                                   |
| `bootstrap_webmin__repo_url`              | `https://download.webmin.com/download/newkey/repository`                                                | URL for the Webmin repository.                                                                                                                                                                              |
| `bootstrap_webmin__repo_key_download`     | `/tmp/webmin-keyring.gpg`                                                                               | Path to download the repository key.                                                                                                                                                                        |
| `bootstrap_webmin__apt_keyring_dir`       | `/usr/share/keyrings`                                                                                   | Directory for storing APT keyrings.                                                                                                                                                                         |
| `bootstrap_webmin__apt_repo_key_type`     | `trust_store`                                                                                           | Type of APT repository key (e.g., `trust_store`).                                                                                                                                                         |
| `bootstrap_webmin__apt_repo_keyring_file` | `/usr/share/keyrings/webmin-keyring.gpg`                                                                | Path to the APT repository keyring file.                                                                                                                                                                    |
| `bootstrap_webmin__apt_repo_template`     | `webmin.debian.repo.j2`                                                                                 | Template for generating the APT repository configuration file.                                                                                                                                                |
| `bootstrap_webmin__apt_repo_version`      | `stable`                                                                                                | Version of the Webmin repository to use (e.g., `stable`).                                                                                                                                                   |
| `bootstrap_webmin__apt_repo_spec`         | `deb [arch=amd64 signed-by={{ bootstrap_webmin__apt_repo_keyring_file }}] {{ bootstrap_webmin__repo_url }} {{ bootstrap_webmin__apt_repo_version }} contrib` | Specification for the APT repository.                                                                                                                                                                     |

## Usage

To use the `bootstrap_webmin` role, include it in your playbook and optionally override any of the default variables as needed.

### Example Playbook

```yaml
- name: Install Webmin on target hosts
  hosts: all
  become: yes
  roles:
    - role: bootstrap_webmin
      vars:
        bootstrap_webmin__user_password: "securepassword123"
```

## Dependencies

This role does not have any external dependencies, but it requires the following to be present on the target systems:

- `perl`
- `wget` or `curl` for downloading files.
- Package manager (`apt`, `yum`, etc.) appropriate for the distribution.

## Best Practices

1. **Security**: Ensure that passwords are securely managed and not hard-coded in playbooks. Consider using Ansible Vault to encrypt sensitive data.
2. **Customization**: Customize the list of modules, users, and ACLs according to your specific requirements.
3. **Monitoring**: Monitor the Webmin service for any issues after installation.

## Molecule Tests

This role includes Molecule tests to verify its functionality across different Linux distributions. The test scenarios include:

- Debian
- Ubuntu
- CentOS
- Fedora

To run the tests, navigate to the role directory and execute:

```bash
molecule test
```

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_webmin/defaults/main.yml)
- [tasks/install.yml](../../roles/bootstrap_webmin/tasks/install.yml)
- [tasks/main.yml](../../roles/bootstrap_webmin/tasks/main.yml)
- [tasks/setup-modules.yml](../../roles/bootstrap_webmin/tasks/setup-modules.yml)
- [tasks/setup-users.yml](../../roles/bootstrap_webmin/tasks/setup-users.yml)
- [handlers/main.yml](../../roles/bootstrap_webmin/handlers/main.yml)