---
title: Bootstrap PlexUpdate Role Documentation
role: bootstrap_plexupdate
category: Automation
type: Ansible Role
tags: plex, update, automation, cron

---

## Summary

The `bootstrap_plexupdate` role is designed to automate the installation and configuration of PlexUpdate on a target system. This role installs necessary prerequisites, clones the PlexUpdate repository from GitHub, sets up configuration files, configures daily updates via cron, and ensures that the Plex user is added to the media group.

## Variables

The following variables are used within this role:

| Variable Name               | Default Value                                      | Description                                                                 |
|-----------------------------|----------------------------------------------------|-----------------------------------------------------------------------------|
| `plexupdate_download_dir`   | `/tmp`                                             | Directory where temporary files for PlexUpdate will be downloaded.          |
| `plexupdate_repo`           | `https://github.com/lj020326/plexupdate.git`     | URL of the PlexUpdate GitHub repository to clone.                             |
| `plexupdate_dir`            | `/opt/plexupdate`                                  | Directory where PlexUpdate will be installed.                               |
| `plexupdate_version`        | `main`                                             | Branch or tag of the PlexUpdate repository to checkout.                     |

## Usage

To use this role, include it in your playbook as follows:

```yaml
- hosts: all
  roles:
    - bootstrap_plexupdate
```

You can override any default variables by specifying them in your playbook or inventory file. For example:

```yaml
- hosts: all
  vars:
    plexupdate_dir: /usr/local/plexupdate
  roles:
    - bootstrap_plexupdate
```

## Dependencies

This role has the following dependencies:

- `git` package must be available for installation on the target system.

## Tags

No specific tags are defined within this role. However, you can use the default Ansible tags to control task execution (e.g., `--tags install`, `--skip-tags configure`).

## Best Practices

- Ensure that the Plex user exists before running this role or include a role that creates it.
- Verify that the media group is present and correctly configured on your system.

## Molecule Tests

This role does not currently include Molecule tests. Consider adding them for future testing and validation purposes.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_plexupdate/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_plexupdate/tasks/main.yml)