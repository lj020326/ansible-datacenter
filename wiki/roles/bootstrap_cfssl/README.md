```markdown
---
title: bootstrap_cfssl Role Documentation
original_path: roles/bootstrap_cfssl/README.md
category: Ansible Roles
tags: [cfssl, ansible, kubernetes, certificate-authority]
---

# bootstrap_cfssl

Installs CFSSL (CloudFlare's PKI toolkit) binaries. This role is used as a lightweight certificate authority (CA) for Kubernetes. It is part of the setup described in [Kubernetes the not so hard way with Ansible - Certificate Authority](https://www.tauceti.blog/posts/kubernetes-the-not-so-hard-way-with-ansible-certificate-authority/).

## Role Variables

```yaml
# Specifies the version of CFSSL toolkit to download and use
cfssl_version: "1.6.1"

# URL for the checksum file
cfssl_checksum_url: "https://github.com/cloudflare/cfssl/releases/download/v{{ cfssl_version }}/cfssl_{{ cfssl_version }}_checksums.txt"

# Directory where CFSSL binaries will be installed
cfssl_bin_directory: "/usr/local/bin"

# Owner of the CFSSL binaries
cfssl_owner: "root"

# Group for the CFSSL binaries
cfssl_group: "root"

# Operating system for which CFSSL should be built (use "darwin" for macOS, "windows" for Windows)
cfssl_os: "linux"

# Processor architecture for which CFSSL should be built (currently only "amd64" is supported)
cfssl_arch: "amd64"
```

## Testing

This role includes a test setup using [Molecule](https://github.com/ansible-community/molecule). To run the tests, follow the Molecule [installation guide](https://molecule.readthedocs.io/en/latest/installation.html) and ensure that Docker is running on your machine.

Assuming Docker is already installed, you need to install the following Python packages:

```bash
pip3 install --user molecule
pip3 install --user molecule-docker
```

After installation, you can run Molecule with:

```bash
molecule converge
```

This command sets up Docker containers running Ubuntu 18.04/20.04 and Debian 10/11, with CFSSL installed.

To clean up the test environment, run:

```bash
molecule destroy
```

## Example Playbook

```yaml
- hosts: cfssl-hosts
  roles:
    - githubixx.cfssl
```

## Backlinks

- [Kubernetes the not so hard way with Ansible](https://www.tauceti.blog/posts/kubernetes-the-not-so-hard-way-with-ansible-certificate-authority/)
```