---
title: Bootstrap Caddy2 Role Documentation
role: bootstrap_caddy2
category: Ansible Roles
type: Installation
tags: caddy, webserver, automation
---

## Summary

The `bootstrap_caddy2` role is designed to automate the installation and configuration of Caddy 2 on a target system. It handles the creation of a dedicated service account for running Caddy, downloads the specified version of Caddy, installs it in the designated directory, sets up a systemd service file, creates a basic Caddyfile, and starts the Caddy service.

## Variables

| Variable Name                      | Default Value                                                                                     | Description                                                                 |
|------------------------------------|---------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------|
| `bootstrap_caddy2__user`           | `caddy`                                                                                           | The username for the Caddy service account.                                 |
| `bootstrap_caddy2__version`        | `2.1.0-beta.1`                                                                                  | The version of Caddy to install.                                            |
| `bootstrap_caddy2__install_root`   | `/opt/caddy`                                                                                    | The installation directory for Caddy.                                       |
| `bootstrap_caddy2__arch`           | `{{ 'arm64' if ansible_facts.machine == 'aarch64' else 'amd64' }}`                                 | The architecture of the system (automatically detected).                    |
| `bootstrap_caddy2__base_url`       | `https://github.com/caddyserver/caddy/releases/download`                                          | The base URL for downloading Caddy releases.                                |
| `bootstrap_caddy2__bin_url`        | `{{ bootstrap_caddy2__base_url }}/v2.1.0-beta.1/{{ bootstrap_caddy2__version }}_linux_{{ bootstrap_caddy2__arch }}.tar.gz` | The full URL for downloading the specified version of Caddy.              |
| `bootstrap_caddy2__file`           | `""`                                                                                              | The content of the Caddyfile to be created (can be overridden by user).     |

## Usage

To use this role, include it in your playbook and optionally override any variables as needed:

```yaml
- hosts: webservers
  roles:
    - role: bootstrap_caddy2
      vars:
        bootstrap_caddy2__version: "2.1.0"
        bootstrap_caddy2__file: |
          :80 {
              root * /var/www/html
              file_server
          }
```

## Dependencies

This role does not have any external dependencies other than the standard Ansible modules used in its tasks.

## Best Practices

- Always specify a stable version of Caddy to avoid unexpected behavior due to beta or release candidate versions.
- Customize the `bootstrap_caddy2__file` variable with your desired Caddy configuration to suit your web server needs.
- Ensure that the target system has internet access to download the specified version of Caddy.

## Molecule Tests

This role does not currently include any Molecule tests. Consider adding tests to ensure the role behaves as expected across different environments and configurations.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_caddy2/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_caddy2/tasks/main.yml)