---
title: "bootstrap_awx Role Documentation"
role: bootstrap_awx
category: Ansible Roles
type: Infrastructure Automation
tags: [ansible, awx, automation-controller, k3s, rancher, cert-manager]
---

## Summary

The `bootstrap_awx` role is designed to automate the setup and deployment of AWX (Ansible Webex) or Ansible Controller on a Kubernetes cluster managed by K3s. It includes tasks for setting up the server environment, installing K3s, deploying AWX using the awx-operator, configuring cert-manager for SSL/TLS certificates, and optionally deploying Rancher for Kubernetes management.

## Variables

| Variable Name                         | Default Value                                                                                   | Description                                                                                                                                                                                                 |
|---------------------------------------|-------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_awx__awx_url`              | `panel.example.org`                                                                             | The URL for the AWX/Automation Controller instance.                                                                                                                                                           |
| `bootstrap_awx__rancher_url`          | `rancher.example.org`                                                                           | The URL for the Rancher management interface (if deployed).                                                                                                                                                   |
| `bootstrap_awx__certbot_email`        | `ljohnson@dettonville.com`                                                                      | Email address used by Certbot for SSL/TLS certificate issuance.                                                                                                                                             |
| `bootstrap_awx__cloudflare_api_key`   | `<< cloudflare API key >>`                                                                      | Cloudflare API key for DNS-based challenges with Certbot (if using Cloudflare).                                                                                                                               |
| `bootstrap_awx__cloudflare_email`     | `cloudflareaccount@protonmail.com`                                                              | Email address associated with the Cloudflare account.                                                                                                                                                       |
| `bootstrap_awx__rancher_password`     | `<< strong-password >>`                                                                         | Password for the Rancher admin user (if deploying Rancher).                                                                                                                                                   |
| `bootstrap_awx__admin_username`       | `admin`                                                                                         | Username for the AWX/Automation Controller admin account.                                                                                                                                                   |
| `bootstrap_awx__admin_password`       | `<< strong-password >>`                                                                         | Password for the AWX/Automation Controller admin account.                                                                                                                                                   |
| `bootstrap_awx__secret_key`           | `<< strong-password >>`                                                                         | Secret key used by AWX/Automation Controller for cryptographic signing (must be kept secret).                                                                                                                |
| `bootstrap_awx__pg_password`          | `<< strong-password >>`                                                                         | Password for the PostgreSQL database used by AWX/Automation Controller.                                                                                                                                    |
| `bootstrap_awx__firewalld_services`   | `[ { name: ssh }, { name: http }, { name: https } ]`                                             | List of services to be enabled in firewalld (e.g., SSH, HTTP, HTTPS).                                                                                                                                      |
| `bootstrap_awx__arch`                 | `"{{ 'arm64' if ansible_facts.machine == 'aarch64' else 'amd64' }}"`                              | Architecture of the target system (automatically detected as either arm64 or amd64).                                                                                                                        |
| `bootstrap_awx__cmtl_version`         | `"1.10.1"`                                                                                      | Version of cert-manager tooling (`cmctl`) to be installed.                                                                                                                                                  |
| `bootstrap_awx__cmtl_archive`         | `"cmctl-linux-{{ bootstrap_awx__arch }}.tar.gz"`                                                 | Filename of the cert-manager tooling archive corresponding to the specified version and architecture.                                                                                                         |
| `bootstrap_awx__cmtl_url`             | `"https://github.com/cert-manager/cert-manager/releases/download/v{{ bootstrap_awx__cmtl_version }}/cmctl-linux-{{ bootstrap_awx__arch }}.tar.gz"` | URL from which to download the cert-manager tooling archive.                                                                                                                                                |
| `bootstrap_awx__cmtl_checksum`        | `sha256:c0996ec98b87c8ee2854162da25238c4e74092c3ab156710619423f794eb1aa6`                          | SHA256 checksum of the cert-manager tooling archive to ensure integrity during download.                                                                                                                      |

## Usage

To use the `bootstrap_awx` role, include it in your playbook and provide necessary variables as needed:

```yaml
- hosts: awx_servers
  roles:
    - role: bootstrap_awx
      vars:
        bootstrap_awx__awx_url: "your-awx-url.com"
        bootstrap_awx__rancher_url: "your-rancher-url.com"
        bootstrap_awx__certbot_email: "your-email@example.com"
        bootstrap_awx__cloudflare_api_key: "your-cloudflare-api-key"
        bootstrap_awx__cloudflare_email: "your-cloudflare-email@example.com"
        bootstrap_awx__rancher_password: "strong-password"
        bootstrap_awx__admin_username: "admin"
        bootstrap_awx__admin_password: "strong-password"
        bootstrap_awx__secret_key: "very-secret-key"
        bootstrap_awx__pg_password: "another-strong-password"
```

## Dependencies

- `bootstrap_linux_firewalld` role (for configuring firewalld)

## Best Practices

1. **Security**: Ensure all passwords and sensitive information are stored securely, preferably using Ansible Vault.
2. **Customization**: Customize the variables in `defaults/main.yml` to fit your specific environment requirements.
3. **Testing**: Use Molecule for testing the role in isolated environments before deploying it to production.

## Molecule Tests

This role does not include Molecule tests at this time. Consider adding Molecule scenarios to ensure the role behaves as expected across different environments.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_awx/defaults/main.yml)
- [tasks/awx_setup.yml](../../roles/bootstrap_awx/tasks/awx_setup.yml)
- [tasks/k3s_setup.yml](../../roles/bootstrap_awx/tasks/k3s_setup.yml)
- [tasks/main.yml](../../roles/bootstrap_awx/tasks/main.yml)
- [tasks/rancher_setup.yml](../../roles/bootstrap_awx/tasks/rancher_setup.yml)
- [tasks/server_setup.yml](../../roles/bootstrap_awx/tasks/server_setup.yml)