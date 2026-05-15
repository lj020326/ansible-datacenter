```markdown
---
title: bootstrap_telegraf Role Documentation
original_path: roles/bootstrap_telegraf/README.md
category: Ansible Roles
tags: telegraf, influxdb, ansible, monitoring
---

# bootstrap_telegraf

An Ansible role to install, configure, and manage [Telegraf](https://github.com/influxdb/telegraf), the plugin-driven server agent for reporting metrics into InfluxDB.

## Requirements

Prior knowledge/experience with InfluxDB and Telegraf is highly recommended. Full documentation is available [here](https://docs.influxdata.com).

## Installation

Either clone this repository, or install through Ansible Galaxy directly using the command:

```bash
ansible-galaxy install rossmcdonald.telegraf
```

## Role Variables

The high-level variables are stored in the `defaults/main.yml` file. The most important ones being:

```yaml
# Channel of Telegraf to install (currently only 'stable' is supported)
telegraf_install_version: stable
```

More advanced configuration options are stored in the `vars/main.yml` file, which includes all of the necessary bells and whistles to tweak your configuration.

## Dependencies

No other Ansible dependencies are required. This role was tested and developed with Ansible 1.9.4.

## Example Playbook

An example playbook is included in the `test.yml` file. There is also a `Vagrantfile`, which can be used for quick local testing leveraging [Vagrant](https://www.vagrantup.com/).

## Backlinks

- [Ansible Roles Collection](../ansible_roles.md)
```

This improved Markdown document adheres to clean, professional standards and includes all original information while adding YAML frontmatter for better categorization and tagging.