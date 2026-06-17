---
title: "Webmin Bootstrap Role Documentation"
role: bootstrap_webmin
category: Ansible Roles
type: Configuration Management
tags: webmin, ansible, automation, configuration

## Summary
The `bootstrap_webmin` role is designed to automate the installation and configuration of Webmin on various Linux distributions. It handles repository setup, package installation, user management, module downloads, and configuration settings for Webmin.

## Variables

| Variable Name                                  | Default Value                                                                                       | Description                                                                                                                                                                                                 |
|------------------------------------------------|-----------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_webmin__enabled`                    | `true`                                                                                                | Enable or disable the role.                                                                                                                                                                                 |
| `bootstrap_webmin__base_dir`                   | `/usr/share/webmin`                                                                                 | Base directory for Webmin installation files.                                                                                                                                                                 |
| `bootstrap_webmin__config_file`                | `/etc/webmin/config`                                                                                | Configuration file path for Webmin settings.                                                                                                                                                                |
| `bootstrap_webmin__installer_tmpdir`           | `/var/tmp`                                                                                          | Temporary directory used during the installation process.                                                                                                                                                     |
| `bootstrap_webmin__tempdir`                    | `/var/lib/webmin/tmp`                                                                               | Custom temporary directory for Webmin to use.                                                                                                                                                                 |
| `bootstrap_webmin__tempdelete_days`            | `7`                                                                                                   | Number of days after which old temp files are deleted.                                                                                                                                                        |
| `bootstrap_webmin__remove_repo_after_install`  | `true`                                                                                                | Remove the repository configuration file after installation.                                                                                                                                                |
| `bootstrap_webmin__restart_after_install`      | `true`                                                                                                | Restart Webmin service after installation or configuration changes.                                                                                                                                         |
| `bootstrap_webmin__repo_installer_source`      | `local`                                                                                               | Source of the repository installer script (`local` or `github`).                                                                                                                                              |
| `bootstrap_webmin__repo_installer_url`         | `https://raw.githubusercontent.com/webmin/webmin/master/webmin-setup-repo.sh`                       | URL to the Webmin setup repository script if using a remote source.                                                                                                                                         |
| `bootstrap_webmin__repo_files`                 | `- webmin.list`                                                                                     | List of repository files to manage.                                                                                                                                                                         |
| `bootstrap_webmin__repo_key_url`               | `https://download.webmin.com/developers-key.asc`                                                    | URL for the Webmin repository key.                                                                                                                                                                          |
| `bootstrap_webmin__modules`                    | `- url: https://download.webmin.com/download/modules/disk-usage-1.2.wbm.gz`                          | List of Webmin modules to download and install.                                                                                                                                                             |
| `bootstrap_webmin__packages`                   | `- perl-Env<br>- perl-App-cpanminus<br>- perl-CPAN<br>- perl-JSON<br>- perl-JSON-PP<br>- perl-Encode-Detect<br>- perl-Net-SSLeay` | List of Perl packages required by Webmin.                                                                                                                                                                   |
| `bootstrap_webmin__user_hash_seed`             | `4556li5j56hu5y`                                                                                    | Seed for generating hashed passwords.                                                                                                                                                                         |
| `bootstrap_webmin__user_group`                 | `webmin`                                                                                              | Group name for the Webmin user.                                                                                                                                                                             |
| `bootstrap_webmin__user_shell`                 | `/bin/bash`                                                                                           | Shell for the Webmin user.                                                                                                                                                                                  |
| `bootstrap_webmin__user_username`              | `webmin`                                                                                              | Username for the Webmin user.                                                                                                                                                                               |
| `bootstrap_webmin__user_password`              | `change!me!`                                                                                        | Password for the Webmin user (plain text, will be hashed).                                                                                                                                                |
| `bootstrap_webmin__users`                      | `- username: "{{ bootstrap_webmin__user_username }}"<br>  password: "{{ bootstrap_webmin__user_password }}" | List of users to create and configure in Webmin.                                                                                                                                                            |
| `bootstrap_webmin__user_groups`                | RedHat, CentOS, Fedora, Scientific: `adm`<br>Debian, Ubuntu: `adm`, `cdrom`, `dip`, `plugdev`           | Groups to which the Webmin user should be added based on the distribution.                                                                                                                                    |
| `bootstrap_webmin__user_acls`                  | List of ACLs for the Webmin user (e.g., `acl`, `adsl-client`, etc.).                                                                                                | Access Control Lists for the Webmin user, defining permissions within Webmin.                                                                                                                               |
| `bootstrap_webmin__perl_mm_use_default`        | `1`                                                                                                   | Environment variable to use default values during Perl module installation.                                                                                                                                   |
| `bootstrap_webmin__repo_url`                   | `https://download.webmin.com/download/newkey/repository`                                            | URL for the Webmin repository.                                                                                                                                                                              |
| `bootstrap_webmin__repo_key_download`          | `/tmp/webmin-keyring.gpg`                                                                             | Path to download the Webmin repository key.                                                                                                                                                                 |
| `bootstrap_webmin__apt_keyring_dir`            | `/usr/share/keyrings`                                                                                 | Directory for storing the APT keyring file.                                                                                                                                                                   |
| `bootstrap_webmin__apt_repo_key_type`          | `trust_store`                                                                                         | Type of APT repository key (e.g., `trust_store`).                                                                                                                                                           |
| `bootstrap_webmin__apt_repo_keyring_file`      | `"{{ bootstrap_webmin__apt_keyring_dir }}/webmin-keyring.gpg"`                                        | Path to the APT repository keyring file.                                                                                                                                                                    |
| `bootstrap_webmin__apt_repo_template`          | `webmin.debian.repo.j2`                                                                               | Template for generating the APT repository configuration file.                                                                                                                                                |
| `bootstrap_webmin__apt_repo_version`           | `stable`                                                                                              | Version of the Webmin repository to use (e.g., `stable`).                                                                                                                                                   |
| `bootstrap_webmin__apt_repo_spec`              | `deb [arch=amd64 signed-by={{ bootstrap_webmin__apt_repo_keyring_file }}] {{ bootstrap_webmin__repo_url }} {{ bootstrap_webmin__apt_repo_version }} contrib` | Specification for the APT repository configuration.                                                                                                                                                         |

## Usage
To use the `bootstrap_webmin` role, include it in your playbook and optionally override any of the default variables as needed.

### Example Playbook
```yaml
---
- name: Install Webmin on target hosts
  hosts: webservers
  become: yes
  roles:
    - role: bootstrap_webmin
      vars:
        bootstrap_webmin__user_password: "securepassword123"
```

## Dependencies
The `bootstrap_webmin` role does not have any external dependencies. However, it requires the following to be installed on the target hosts:

- `perl`
- `wget` or `curl` (for downloading files)
- `apt-get` or `yum` (depending on the distribution)

## Best Practices
1. **Security**: Ensure that the password for the Webmin user is strong and not hardcoded in your playbooks.
2. **Customization**: Override default variables as needed to fit your environment's requirements.
3. **Testing**: Use Molecule tests to verify the role's functionality on different distributions.

## Molecule Tests
The `bootstrap_webmin` role includes Molecule tests to ensure its functionality across multiple Linux distributions. To run the tests, navigate to the role directory and execute:

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