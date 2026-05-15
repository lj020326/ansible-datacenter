---
title: Bootstrap PlexUpdate Role Documentation
role: bootstrap_plexupdate
category: Automation
type: Ansible Role
tags: plex, update, automation, cron
---

## Summary

The `bootstrap_plexupdate` role is designed to automate the installation and configuration of PlexUpdate on a target system. It installs necessary prerequisites, clones the PlexUpdate repository from GitHub, sets up configuration files, configures daily updates via cron, and ensures that the Plex user is added to the media group.

## Variables

| Variable Name               | Default Value                             | Description                                                                 |
|-----------------------------|-------------------------------------------|-----------------------------------------------------------------------------|
| `plexupdate_download_dir`   | `/tmp`                                    | The directory where PlexUpdate will be temporarily downloaded.              |
| `plexupdate_repo`           | `https://github.com/lj020326/plexupdate.git` | The GitHub repository URL for PlexUpdate.                                   |
| `plexupdate_dir`            | `/opt/plexupdate`                         | The directory where PlexUpdate will be installed.                           |
| `plexupdate_version`        | `main`                                    | The branch or tag of the PlexUpdate repository to clone.                    |

## Usage

To use this role, include it in your Ansible playbook and optionally override any default variables as needed.

### Example Playbook
```yaml
- hosts: all
  roles:
    - role: bootstrap_plexupdate
      vars:
        plexupdate_dir: /usr/local/plexupdate
```

## Dependencies

This role depends on the following packages being available in your package manager:

- `git` (for cloning the PlexUpdate repository)

No other roles are required for this role to function.

## Best Practices

1. **Backup Configuration Files**: Before running this role, ensure you have backups of any existing configuration files that might be overwritten.
2. **Review Cron Jobs**: Verify that the cron job created by this role aligns with your update schedule requirements.
3. **User Permissions**: Ensure that the `plex` user and `media` group exist on your system before running this role.

## Molecule Tests

This role does not currently include any Molecule tests. Consider adding tests to ensure the role behaves as expected in different environments.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_plexupdate/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_plexupdate/tasks/main.yml)