---
title: Bootstrap Caddy2 Role Documentation
role: bootstrap_caddy2
category: Ansible Roles
type: Installation
tags: caddy, webserver, automation
---

## Summary

The `bootstrap_caddy2` role is designed to automate the installation and configuration of Caddy 2 on a Linux system. It handles the creation of a dedicated service account for Caddy, downloads and installs the specified version of Caddy from a provided URL, sets up a systemd service file, creates a Caddyfile with user-defined content, and starts the Caddy service.

## Variables

| Variable Name            | Default Value                                                                                         | Description                                                                                                                                 |
|--------------------------|-------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------|
| `caddy_user`             | `caddy`                                                                                             | The username for the Caddy service account.                                                                                                 |
| `caddy_install_root`     | `/opt/caddy`                                                                                        | The directory where Caddy will be installed.                                                                                                |
| `caddy_bin_url`          | `https://github.com/caddyserver/caddy/releases/download/v2.1.0-beta.1/caddy_2.1.0-beta.1_linux_amd64.tar.gz` | The URL to download the Caddy binary tarball.                                                                                               |
| `caddy_file`             | `""`                                                                                                | The content of the Caddyfile, which can be provided as a string. If left empty, no Caddyfile will be created.                              |

## Usage

To use this role, include it in your playbook and optionally override any default variables to suit your environment.

### Example Playbook

```yaml
- hosts: webservers
  roles:
    - role: bootstrap_caddy2
      vars:
        caddy_file: |
          :80 {
              root * /var/www/html
              file_server
          }
```

## Dependencies

This role does not have any external dependencies.

## Tags

No specific tags are defined in this role. The tasks will run as part of the default playbook execution.

## Best Practices

- Ensure that the `caddy_bin_url` points to a trusted and secure source.
- Provide a valid Caddyfile configuration in the `caddy_file` variable to avoid issues with service startup.
- Regularly update the `caddy_bin_url` to use the latest stable version of Caddy.

## Molecule Tests

This role does not include any Molecule tests at this time.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_caddy2/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_caddy2/tasks/main.yml)