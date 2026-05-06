---
title: "Bootstrap Sanoid Role"
role: roles/bootstrap_sanoid
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_sanoid]
---

# Role Documentation: `bootstrap_sanoid`

## Overview

The `bootstrap_sanoid` role is designed to automate the installation and configuration of [Sanoid](https://github.com/jimsalterjrs/sanoid) and its replication tool, Syncoid, on a Debian-based system. This role provides flexibility in installing Sanoid either via pre-built packages or by building it from source.

## Role Variables

### Default Variables

The following variables are defined in `defaults/main.yml`:

- **sanoid_build_from_source**: (Boolean) Determines whether to build Sanoid from source (`true`) or install it using a package manager (`false`).  
  *Default: false*

- **sanoid_apt_package_name**: (String) The name of the Sanoid package as recognized by the APT package manager.  
  *Default: sanoid*

- **syncoid_binary_path**: (String) The path where the Syncoid binary is installed.  
  *Default: /usr/sbin/syncoid*

### Customizable Variables

- **sanoid_config_source**: (String) Specifies the source file for the Sanoid configuration that will be copied to `/etc/sanoid/sanoid.conf`. This variable should point to a file within your Ansible project's `files` or `templates` directory.  
  *Example: sanoid.conf.j2*

- **syncoid_cron_jobs**: (List of Dictionaries) A list of cron jobs for Syncoid replication tasks. Each dictionary can specify the following keys:
  - **name**: (String) The name of the cron job.
  - **job**: (String) The command to be executed by the cron job.
  - **weekday**: (String, Optional) The day of the week on which the job should run.  
    *Default: `*` (every day)*
  - **minute**: (String, Optional) The minute at which the job should run.  
    *Default: `00`*
  - **hour**: (String, Optional) The hour at which the job should run.  
    *Default: `00`*
  - **dom**: (String, Optional) The day of the month on which the job should run.  
    *Default: `*` (every day)*

## Role Tasks

The role is structured into several tasks to handle different aspects of Sanoid and Syncoid setup:

### Main Tasks (`tasks/main.yml`)

- **Run sanoid setup**: Includes the `sanoid.yml` task file, which handles the installation and configuration of Sanoid.
- **Run replication setup**: Includes the `replication.yml` task file, which sets up cron jobs for Syncoid replication.

### Sanoid Setup (`tasks/sanoid.yml`)

1. **Check whether sanoid is installed**: Verifies if Sanoid is already installed using the APT package manager.
2. **Install sanoid?**: Sets a fact `install_sanoid` based on the value of `sanoid_build_from_source` and the result of the installation check.
3. **Build sanoid | clone git repo**: Clones the Sanoid builder repository from GitHub if building from source is enabled.
4. **Build sanoid | make build script executable**: Makes the build script executable.
5. **Build sanoid | build .deb package**: Executes the build script to create a Debian package.
6. **Install dependencies for sanoid**: Installs necessary dependencies required by Sanoid.
7. **Build sanoid | install built .deb**: Installs the built Debian package of Sanoid.
8. **Ensure sanoid is installed**: Ensures that Sanoid is installed via APT if not already done.
9. **Create target dir for sanoid config**: Creates the directory `/etc/sanoid` to store configuration files.
10. **Configure sanoid**: Copies the specified Sanoid configuration file to `/etc/sanoid/sanoid.conf`.

### Replication Setup (`tasks/replication.yml`)

- **Setup cron job for replication**: Configures cron jobs based on the `syncoid_cron_jobs` variable, allowing scheduled Syncoid replication tasks.

## Example Playbook

Below is an example playbook that demonstrates how to use the `bootstrap_sanoid` role:

```yaml
---
- name: Setup Sanoid and Syncoid
  hosts: all
  become: yes
  vars:
    sanoid_build_from_source: true
    sanoid_config_source: sanoid.conf.j2
    syncoid_cron_jobs:
      - name: "Daily Sync"
        job: "/usr/sbin/syncoid zpool1/dataset1 zpool2/dataset1"
        weekday: "*"
        minute: "0"
        hour: "3"
  roles:
    - role: bootstrap_sanoid
```

## Notes

- **Double-underscore variables**: These are internal to the role and should not be modified.
- **No related roles**: This role does not depend on any other roles for its functionality.

This documentation provides a comprehensive guide to using the `bootstrap_sanoid` role, ensuring that Sanoid and Syncoid are installed and configured correctly according to your requirements.