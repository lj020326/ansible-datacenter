---
title: Bootstrap AWX Role Documentation
role: bootstrap_awx
category: Ansible Roles
type: Infrastructure Setup
tags: [awx, automation-controller, k3s, rancher, cert-manager]
---

## Summary

The `bootstrap_awx` role is designed to automate the setup of an Ansible Automation Platform (AWX) instance on a Kubernetes cluster managed by K3s. This role handles the installation and configuration of necessary components such as K3s, Rancher for Kubernetes management, Cert-Manager for SSL certificates, and AWX itself. It also configures firewalld to allow essential services.

## Variables

| Variable Name                      | Default Value                                                                 | Description                                                                                                                                                                                                 |
|--------------------------------------|-------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_awx_awx_url`              | `panel.example.org`                                                         | The URL for the AWX instance.                                                                                                                                                                               |
| `bootstrap_awx_rancher_url`          | `rancher.example.org`                                                       | The URL for the Rancher management interface.                                                                                                                                                                 |
| `bootstrap_awx_certbot_email`        | `ljohnson@dettonville.com`                                                  | Email address used by Cert-Manager to register with Let's Encrypt.                                                                                                                                          |
| `bootstrap_awx_cloudflare_api_key`   | `<< cloudflare API key >>`                                                  | Cloudflare API key for DNS-based challenges with Cert-Manager (if applicable).                                                                                                                                |
| `bootstrap_awx_cloudflare_email`     | `cloudflareaccount@protonmail.com`                                          | Email address associated with the Cloudflare account.                                                                                                                                                       |
| `bootstrap_awx_rancher_password`     | `<< strong-password >>`                                                     | Password for the Rancher admin user.                                                                                                                                                                        |
| `bootstrap_awx_admin_username`       | `admin`                                                                     | Username for the AWX admin user.                                                                                                                                                                            |
| `bootstrap_awx_admin_password`       | `<< strong-password >>`                                                     | Password for the AWX admin user.                                                                                                                                                                            |
| `bootstrap_awx_secret_key`           | `<< strong-password >>`                                                     | Secret key used by AWX for cryptographic signing.                                                                                                                                                           |
| `bootstrap_awx_pg_password`          | `<< strong-password >>`                                                     | Password for the PostgreSQL database used by AWX.                                                                                                                                                           |
| `bootstrap_awx_firewalld_services`   | `[ { name: ssh }, { name: http }, { name: https } ]`                        | List of services to be enabled in firewalld.                                                                                                                                                                |

## Usage

To use this role, include it in your Ansible playbook and provide the necessary variables as shown below:

```yaml
- hosts: awx_servers
  roles:
    - role: bootstrap_awx
      vars:
        bootstrap_awx_awx_url: "your-awx-url.com"
        bootstrap_awx_rancher_url: "your-rancher-url.com"
        bootstrap_awx_certbot_email: "your-email@example.com"
        bootstrap_awx_cloudflare_api_key: "your-cloudflare-api-key"
        bootstrap_awx_cloudflare_email: "your-cloudflare-email@example.com"
        bootstrap_awx_rancher_password: "strong-password"
        bootstrap_awx_admin_username: "admin"
        bootstrap_awx_admin_password: "strong-password"
        bootstrap_awx_secret_key: "strong-secret-key"
        bootstrap_awx_pg_password: "strong-db-password"
```

## Dependencies

- `bootstrap_linux_firewalld` role for configuring firewalld.

## Tags

- `[never, setup]`: Used for tasks that set up the server, K3s, AWX, and Rancher.
- `[never, setup-firewall]`: Used specifically for configuring firewalld.
- `[never, setup-rancher]`: Used for setting up Rancher on the host.

## Best Practices

1. **Security**: Ensure all passwords and sensitive information are stored securely using Ansible Vault or environment variables.
2. **Customization**: Modify the templates in `templates/` directory to suit your specific requirements.
3. **Testing**: Use Molecule tests (if available) to validate changes before deploying to production.

## Molecule Tests

This role does not include Molecule tests at this time. Consider adding them for automated testing and validation of the role's functionality.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_awx/defaults/main.yml)
- [tasks/awx_setup.yml](../../roles/bootstrap_awx/tasks/awx_setup.yml)
- [tasks/k3s_setup.yml](../../roles/bootstrap_awx/tasks/k3s_setup.yml)
- [tasks/main.yml](../../roles/bootstrap_awx/tasks/main.yml)
- [tasks/rancher_setup.yml](../../roles/bootstrap_awx/tasks/rancher_setup.yml)
- [tasks/server_setup.yml](../../roles/bootstrap_awx/tasks/server_setup.yml)