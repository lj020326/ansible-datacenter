---
title: "Bootstrap Awx Role"
role: roles/bootstrap_awx
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_awx]
---

# Bootstrap AWX Role Documentation

## Overview

The `bootstrap_awx` role is designed to automate the setup and deployment of AWX (Ansible Automation Platform) on a Kubernetes cluster managed by K3s. This role handles the installation of necessary dependencies, configuration of the Kubernetes environment, and deployment of AWX, including the setup of Rancher for Kubernetes management and Cert-Manager for SSL certificate management.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `bootstrap_awx__awx_url` | `panel.example.org` | The URL for the AWX instance. |
| `bootstrap_awx__rancher_url` | `rancher.example.org` | The URL for the Rancher instance. |
| `bootstrap_awx__certbot_email` | `ljohnson@dettonville.com` | The email address for Certbot/Let's Encrypt notifications. |
| `bootstrap_awx__cloudflare_api_key` | *Required* | The API key for Cloudflare. |
| `bootstrap_awx__cloudflare_email` | `cloudflareaccount@protonmail.com` | The email address for Cloudflare account. |
| `bootstrap_awx__rancher_password` | *Required* | The password for Rancher. |
| `bootstrap_awx__admin_username` | `admin` | The admin username for AWX. |
| `bootstrap_awx__admin_password` | *Required* | The admin password for AWX. |
| `bootstrap_awx__secret_key` | *Required* | The secret key for AWX. |
| `bootstrap_awx__pg_password` | *Required* | The password for the PostgreSQL database. |
| `bootstrap_awx__firewalld_services` | `[{"name": "ssh"}, {"name": "http"}, {"name": "https"}]` | The list of services to configure in firewalld. |
| `bootstrap_awx__arch` | `{{ 'arm64' if ansible_facts.machine == 'aarch64' else 'amd64' }}` | The architecture of the system. |
| `bootstrap_awx__cmtl_version` | `1.10.1` | The version of Cert-Manager to install. |
| `bootstrap_awx__cmtl_archive` | `cmctl-linux-{{ bootstrap_awx__arch }}.tar.gz` | The archive name for Cert-Manager. |
| `bootstrap_awx__cmtl_url` | `https://github.com/cert-manager/cert-manager/releases/download/v{{ bootstrap_awx__cmtl_version }}/{{ bootstrap_awx__cmtl_archive }}` | The URL to download Cert-Manager. |
| `bootstrap_awx__cmtl_checksum` | `sha256:c0996ec98b87c8ee2854162da25238c4e74092c3ab156710619423f794eb1aa6` | The checksum for the Cert-Manager archive. |

## Requirements

- A server with internet access
- Kubernetes cluster managed by K3s
- Valid Cloudflare API key
- Strong passwords for Rancher, AWX admin, secret key, and PostgreSQL database

## Usage

To use this role, include it in your playbook and set the required variables:

```yaml
- hosts: all
  roles:
    - role: bootstrap_awx
      vars:
        bootstrap_awx__awx_url: "awx.example.org"
        bootstrap_awx__rancher_url: "rancher.example.org"
        bootstrap_awx__certbot_email: "your-email@example.com"
        bootstrap_awx__cloudflare_api_key: "your-cloudflare-api-key"
        bootstrap_awx__cloudflare_email: "your-cloudflare-email"
        bootstrap_awx__rancher_password: "your-rancher-password"
        bootstrap_awx__admin_username: "admin"
        bootstrap_awx__admin_password: "your-admin-password"
        bootstrap_awx__secret_key: "your-secret-key"
        bootstrap_awx__pg_password: "your-pg-password"
```

## Dependencies

This role depends on the following roles and modules:

- `bootstrap_linux_firewalld` for configuring firewalld.
- `community.general.snap` for installing Helm via snap.

## Best Practices

- Ensure all required variables are set with appropriate values before running the playbook
- Use strong, unique passwords for all sensitive fields
- Keep the role and its dependencies up to date
- Regularly backup your AWX configuration and data
- Monitor the AWX instance for any security updates or patches

## Related Files

- [defaults/main.yml](../../roles/bootstrap_awx/defaults/main.yml)
- [tasks/awx_setup.yml](../../roles/bootstrap_awx/tasks/awx_setup.yml)
- [tasks/k3s_setup.yml](../../roles/bootstrap_awx/tasks/k3s_setup.yml)
- [tasks/main.yml](../../roles/bootstrap_awx/tasks/main.yml)
- [tasks/rancher_setup.yml](../../roles/bootstrap_awx/tasks/rancher_setup.yml)
- [tasks/server_setup.yml](../../roles/bootstrap_awx/tasks/server_setup.yml)