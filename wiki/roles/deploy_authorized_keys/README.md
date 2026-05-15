```markdown
---
title: Deploy Authorized Keys Role Documentation
original_path: roles/deploy_authorized_keys/README.md
category: Ansible Roles
tags: [ansible, deploy, authorized-keys]
---

# Deploy Authorized Keys

## Details

For more detailed information, refer to the [Deploy Authorized Keys](./../../docs/ansible/ansible-deploy-authorized-keys.md) documentation.

## Usage

To run this playbook, use the following command:

```bash
ansible-playbook -i <inventory-file> deploy_authorized_keys.yml --ask-pass --extra-vars='pubkey="<pubkey>"'
```

## Backlinks

- [Ansible Documentation](./../../docs/ansible/index.md)
```

This improved Markdown document includes a standardized YAML frontmatter with additional fields for title, category, and tags. It also introduces clear headings and a "Backlinks" section for better navigation and context.