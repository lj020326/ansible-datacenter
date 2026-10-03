title: Nextcloud Installation
original_path: roles/bootstrap_docker_stack/templates/nextcloud/README.md
category: Nextcloud
tags:
  - Nextcloud
  - Installation
  - Command Line
  - Docker
harvested_date: '2023-10-07T18:07:09.203799+00:00'
source_type: legacy_markdown
---

## Nextcloud Command-Line Installation

This guide provides instructions for installing Nextcloud using the command line in a Docker environment. It includes the necessary commands, prerequisites, and references for further reading.

### Introduction

Nextcloud is a popular self-hosted productivity platform that provides a range of online office applications, such as document editing, calendar, contacts, and more. This guide will walk you through the process of installing Nextcloud using the command line in a Docker environment.

### Prerequisites

Before you begin, ensure you have the following:

- Docker installed on your system
- Basic knowledge of Docker and command-line usage

### Installation Commands

1. **Install Nextcloud:**

   ```shell
   $ occ maintenance:install --database "sqlite" --admin-user "admin" --admin-pass "password"
   ```

   This command installs Nextcloud with SQLite as the database, and sets up an admin user with the specified username and password.

2. **Check Nextcloud Status:**

   ```shell
   $ occ status --output=json_pretty
   ```

   This command displays the current status of your Nextcloud installation in a pretty-printed JSON format.

### Reference

#### Official Documentation
- [Nextcloud OCC Command: Command-Line Installation](https://docs.nextcloud.com/server/latest/admin_manual/configuration_server/occ_command.html#command-line-installation-label)
- [Nextcloud Command-Line Installation](https://docs.nextcloud.com/server/latest/admin_manual/installation/command_line_installation.html)
- [Nextcloud Automatic Configuration](https://docs.nextcloud.com/server/latest/admin_manual/configuration_server/automatic_configuration.html)

#### Community Resources
- [Install Nextcloud from Command Line](https://mailserverguru.com/install-nextcloud-from-command-line/)
- [Upgrade Nextcloud Command Line GUI](https://www.linuxbabe.com/cloud-storage/upgrade-nextcloud-command-line-gui)

#### Docker Resources
- [LinuxServer Docker Nextcloud](https://github.com/linuxserver/docker-nextcloud)
- [LinuxServer Nextcloud Docker Tags](https://hub.docker.com/r/linuxserver/nextcloud/tags)
- [LinuxServer Docker Nextcloud Usage](https://docs.linuxserver.io/images/docker-nextcloud/#usage)

### Troubleshooting

If you encounter any issues during the installation process, consider the following:

- Ensure Docker is running and properly configured on your system.
- Check the Nextcloud logs for any error messages.
- Consult the official Nextcloud documentation for additional troubleshooting steps.

### Additional Resources

- [Nextcloud OCC Command](https://docs.nextcloud.com/server/latest/admin_manual/configuration_server/occ_command.html)
- [Nextcloud Maintenance: Update](https://docs.nextcloud.com/server/latest/admin_manual/maintenance/update.html)
- [Nextcloud Manual Upgrade](https://docs.nextcloud.com/server/latest/admin_manual/maintenance/manual_upgrade.html)