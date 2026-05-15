---
title: Bootstrap Webmin Role Documentation
original_path: roles/bootstrap_webmin/README.md
category: Ansible Roles
tags: webmin, ansible, automation
---

# Bootstrap Webmin Role

This role allows you to install the [Webmin](http://www.webmin.com) service on Linux hosts.

## Role Variables

The following is a list of default variables available in the inventory:

```yaml
---
bootstrap_webmin__enabled: yes                       # Enable module installation
bootstrap_webmin__base_dir: "/usr/share/webmin"      # Base directory for Webmin installation
bootstrap_webmin__repo_files:
  - "webmin.list"                                   # Repository file to be used
bootstrap_webmin__modules:
  - url: https://download.webmin.com/download/modules/disk-usage-1.2.wbm.gz  # Additional modules to install
```

## Detailed Usage Guide

For detailed instructions on how to use this role, follow these steps:

1. **Include the Role in Your Playbook**: Add `bootstrap_webmin` to your Ansible playbook.
2. **Configure Variables**: Adjust the variables as needed in your inventory or playbook.
3. **Run the Playbook**: Execute the playbook to install Webmin on your target hosts.

## Testing

To test this role, you can use Vagrant:

```shell
$ vagrant up
```

This command will set up a virtual environment and apply the role to it.

## Backlinks

- [Ansible Roles Documentation](../README.md)

---

Ensure that all paths and URLs are correct and accessible in your environment.