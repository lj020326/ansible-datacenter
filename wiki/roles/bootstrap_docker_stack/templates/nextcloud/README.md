```markdown
---
title: Nextcloud Command Line Installation Guide
original_path: roles/bootstrap_docker_stack/templates/nextcloud/README.md
category: Documentation
tags: [Nextcloud, Docker, Installation, OCC]
---

# Nextcloud Command Line Installation

## Installation Commands

To install Nextcloud using the command line with SQLite as the database, use the following commands:

```shell
$ occ maintenance:install --database "sqlite" --admin-user "admin" --admin-pass "password"
$ occ status --output=json_pretty
```

## Reference Documentation

For more detailed information and advanced configurations, refer to the official Nextcloud documentation:

- [Command Line Installation](https://docs.nextcloud.com/server/latest/admin_manual/installation/command_line_installation.html)
- [OCC Command - Maintenance Install](https://docs.nextcloud.com/server/latest/admin_manual/configuration_server/occ_command.html#command-line-installation-label)
- [Automatic Configuration](https://docs.nextcloud.com/server/latest/admin_manual/configuration_server/automatic_configuration.html)
- [MailserverGuru Nextcloud Installation Guide](https://mailserverguru.com/install-nextcloud-from-command-line/)
- [OCC Command Documentation](https://docs.nextcloud.com/server/latest/admin_manual/configuration_server/occ_command.html)
- [Nextcloud Maintenance and Updates](https://docs.nextcloud.com/server/latest/admin_manual/maintenance/update.html)
- [Upgrading Nextcloud via Command Line or GUI](https://www.linuxbabe.com/cloud-storage/upgrade-nextcloud-command-line-gui)
- [Manual Upgrade Process](https://docs.nextcloud.com/server/latest/admin_manual/maintenance/manual_upgrade.html)

## Docker Resources

If you are using Docker to deploy Nextcloud, refer to the following resources:

- [LinuxServer.io Docker Image for Nextcloud](https://github.com/linuxserver/docker-nextcloud)
- [Docker Hub Tags for LinuxServer Nextcloud](https://hub.docker.com/r/linuxserver/nextcloud/tags)
- [Usage Guide for LinuxServer Docker Nextcloud](https://docs.linuxserver.io/images/docker-nextcloud/#usage)

## Backlinks

- [Bootstrap Docker Stack Documentation](../README.md)
```

This improved Markdown document includes a structured format with clear headings, an updated YAML frontmatter, and a "Backlinks" section to provide context for where this documentation might fit within a larger project.