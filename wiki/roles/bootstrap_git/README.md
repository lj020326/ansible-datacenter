---
harvested_date: '2026-08-07T18:07:09.214755+00:00'
original_path: roles/bootstrap_git/README.md
source_type: legacy_markdown
title: Ansible Role: bootstrap_git
category: Ansible Roles
tags: [Ansible, Git, RHEL, CentOS, Debian, Ubuntu]
---

# Ansible Role: bootstrap_git

Installs Git, a distributed version control system, on any RHEL/CentOS or Debian/Ubuntu Linux system. This role can install Git from package repositories or from source, allowing for specific version control.

## Requirements

None.

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

- `bootstrap_git__workspace: /root`

  Specifies the directory where certain files will be downloaded and adjusted prior to Git installation, if needed.

- `bootstrap_git__enablerepo: ""`

  This variable, along with `bootstrap_git__packages`, will be used to install Git via a particular `yum` repo if `bootstrap_git__install_from_source` is set to `false` (CentOS only). Any additional repositories you have installed that you would like to use for a newer/different Git version.

- `bootstrap_git__packages: ["git"]`

  The specific Git packages that will be installed. By default, only `git` is installed, but you could add additional Git-related packages like `git-svn` if desired.

- `bootstrap_git__install_from_source: false`

  Whether to install Git from source.

- `bootstrap_git__install_path: "/usr"`

  Defines where Git should be installed when installing from source.

- `bootstrap_git__version: "2.26.0"`

  The specific version of Git to install when installing from source. See all available versions [here](https://www.kernel.org/pub/software/scm/git/).

- `bootstrap_git__force_update: false`

  If Git is already installed at an older version, force a new source build. Only applies if `bootstrap_git__install_from_source` is `true`.

## Dependencies

None.

## Example Playbook

```yaml
- hosts: servers
  roles:
    - { role: bootstrap_git }
```

## Related Documentation

(This section can be used to link to related documents or pages)