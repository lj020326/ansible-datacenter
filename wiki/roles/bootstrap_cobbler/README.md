```markdown
---
title: Ansible Role `bootstrap_cobbler`
original_path: roles/bootstrap_cobbler/README.md
category: Ansible Roles
tags: [cobbler, ansible]
---

# Ansible Role `bootstrap_cobbler`

## Purpose

This Ansible role is designed for PURPOSE. Specifically, the responsibilities of this role include:

- [List specific tasks or purposes here]

## Requirements

- No specific requirements.

## Role Variables

| Variable                           | Required | Default   | Comments (type)                                                                |
| :---                               | :---     | :---      | :---                                                                           |
| `cobbler_default_password_crypted` | no       | `(cobbler)` | MD-5 crypted hash containing the root password for systems set up with Cobbler |

## Dependencies

- No dependencies.

## Example Playbook

Refer to the [test playbook](tests/test.yml) for an example of how to use this role.

## Testing

The `tests` directory contains tests for this role in the form of a Vagrant environment. The directory `tests/roles/cobbler` is a symbolic link that should point to the root of this project to function correctly. To set up the symbolic link, follow these steps:

```shell
$ cd tests/
$ mkdir roles
$ ln -frs ../../PROJECT_DIR roles/bootstrap_cobbler
```

You may want to change the base box to one you prefer. The current configuration uses Box-Cutter's [CentOS Packer template](https://github.com/boxcutter/centos).

The playbook [`test.yml`](tests/test.yml) applies the role to a VM and sets the necessary role variables.

## Contributing

Issues, feature requests, and ideas are appreciated and can be posted in the Issues section. Pull requests are also welcome. When submitting a pull request, please create a topic branch and squash your commits into one with a descriptive message.

## Backlinks

- [Ansible Roles](../ansible-roles.md)
```

This improved Markdown document adheres to clean, professional standards suitable for GitHub rendering while maintaining all original information and meaning.