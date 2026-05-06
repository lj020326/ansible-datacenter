---
title: "Bootstrap Snapraid Role"
role: roles/bootstrap_snapraid
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_snapraid]
---

# Role Documentation: `bootstrap_snapraid`

## Overview

The `bootstrap_snapraid` Ansible role is designed to automate the installation, configuration, and setup of SnapRAID on Debian-based systems. SnapRAID is a disk array management tool that provides data protection through redundancy and parity checks. This role handles the installation of SnapRAID from source, along with additional tools like `snapraid-runner` for automation and `snapraid-checks` for health monitoring.

## Role Variables

The following variables are defined in `defaults/main.yml`. You can override these variables in your playbook or inventory to customize the behavior of the role.

### General Configuration
- **snapraid_apt_package_name**: The name of the SnapRAID package. Default is `snapraid`.
- **snapraid_bin_path**: Path where SnapRAID binary will be installed. Default is `/usr/local/bin/snapraid`.
- **snapraid_force_install**: Force installation even if SnapRAID is already installed. Default is `false`.

### Source and Build Configuration
- **snapraid_src_dir**: Directory to clone the SnapRAID source code. Default is `/var/lib/src/snapraid`.
- **snapraid_healthchecks_dir**: Directory for `snapraid-checks` tools. Default is `/opt/snapraid-checks`.
- **snapraid_healthcheck_io_uuid**: UUID for health check integration (e.g., with Healthchecks.io). Default is an empty string.

### Email Notifications
- **snapraid_email_address**: Email address to send notifications from.
- **snapraid_email_pass**: Password for the email account. **Sensitive information**; consider using Ansible Vault.
- **snapraid_email_address_from**: Sender's email address. Defaults to `snapraid_email_address`.
- **snapraid_email_address_to**: Recipient's email address. Defaults to `snapraid_email_address`.
- **snapraid_email_sendon**: Conditions for sending emails (e.g., `error`). Default is `error`.
- **snapraid_smtp_host**: SMTP server host. Default is `smtp.gmail.com`.
- **snapraid_smtp_port**: SMTP server port. Default is `465`.
- **snapraid_use_ssl**: Use SSL for SMTP connection. Default is `true`.

### SnapRAID Configuration
- **snapraid_config_excludes**: List of directories to exclude from SnapRAID operations.
- **snapraid_config_hidden_files_enabled**: Enable hidden files in SnapRAID configuration. Default is `false`.
- **snapraid_config_hidden_files**: Hidden files setting in SnapRAID config. Default is `nohidden`.
- **snapraid_config_path**: Path to the SnapRAID configuration file. Default is `/etc/snapraid.conf`.

### Health Check URL
- **snapraid_healthcheck_url**: URL for health check integration (e.g., with Healthchecks.io). Default is constructed using `snapraid_healthcheck_io_uuid`.

### SnapRAID Runner Configuration
- **snapraid_run_path**: Directory for `snapraid-runner` scripts. Default is `/opt/snapraid-runner`.
- **snapraid_run_conf**: Path to the `snapraid-runner` configuration file.
- **snapraid_run_bin**: Path to the `snapraid-runner.py` script.
- **snapraid_run_command**: Command to run SnapRAID and send health check ping.
- **snapraid_run_scrub**: Enable scrubbing. Default is `true`.
- **snapraid_run_scrub_percent**: Percentage of files to scrub during each run. Default is `22`.
- **snapraid_run_scrub_age**: Minimum age (in days) for files to be considered for scrubbing. Default is `8`.
- **snapraid_touch**: Enable touching files to update their timestamps. Default is `true`.
- **snapraid_deletethreshold**: Threshold for deletions before prompting for confirmation. Default is `250`.

### Cron Jobs
- **snapraid_cron_jobs**: List of cron jobs to schedule SnapRAID operations.

## Tasks

The role consists of several tasks organized into separate files:

### `tasks/install-debian.yml`
1. **Check whether SnapRAID is installed**:
   - Uses `dpkg-query` to check if SnapRAID is already installed.
2. **Install SnapRAID?**:
   - Sets a fact `install_snapraid` based on the presence of SnapRAID and `snapraid_force_install`.
3. **Build SnapRAID | Clone git repo**:
   - Clones the SnapRAID source code repository if installation is required.
4. **Build SnapRAID | Make build script executable**:
   - Makes the build script executable.
5. **Build SnapRAID | Build .deb package**:
   - Executes the build script to create a `.deb` package.
6. **Build SnapRAID | Install built .deb**:
   - Installs the built `.deb` package.

### `tasks/install-snapraid-checks.yml`
1. **Check for existing snapraid-healthchecks-tools src dir**:
   - Checks if the `snapraid-checks` directory already exists.
2. **Install-snapraid-checks | Clone git repo**:
   - Clones the `snapraid-checks` repository if it does not exist.

### `tasks/install-snapraid-runner.yml`
1. **Clone snapraid-runner**:
   - Clones the `snapraid-runner` repository.
2. **Install snapraid-runner configuration file**:
   - Installs the `snapraid-runner.conf` configuration file using a template.
3. **Setup cron job snapraid-runner**:
   - Sets up a cron job to run SnapRAID operations based on the defined schedule.

### `tasks/main.yml`
1. **Install snapraid**:
   - Includes tasks from `install-debian.yml` if the OS family is Debian.
2. **Configure snapraid**:
   - Installs and configures the SnapRAID configuration file using a template.
3. **Install snapraid-runner to automate parity checks**:
   - Includes tasks from `install-snapraid-runner.yml`.
4. **Install snapraid-checks to automate health checks**:
   - Includes tasks from `install-snapraid-checks.yml`.

## Usage

To use the `bootstrap_snapraid` role, include it in your playbook and define any necessary variables:

```yaml
---
- name: Bootstrap SnapRAID on Debian-based systems
  hosts: all
  become: yes
  roles:
    - bootstrap_snapraid
  vars:
    snapraid_email_address: "your-email@example.com"
    snapraid_email_pass: "your-email-password"
    snapraid_healthcheck_io_uuid: "your-healthcheck-uuid"
```

## Notes

- **Double-underscore variables**: These are internal only and should not be modified.
- **Sensitive information**: Variables like `snapraid_email_pass` should be managed securely, e.g., using Ansible Vault.

This role provides a comprehensive setup for SnapRAID on Debian-based systems, ensuring that all necessary components are installed and configured correctly.