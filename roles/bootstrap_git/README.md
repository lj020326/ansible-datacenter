# Ansible Role: bootstrap_git

Installs Git, a distributed version control system, on any RHEL/CentOS or Debian/Ubuntu Linux system.

## Requirements

None.

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

    bootstrap_git__workspace: /root

Where certain files will be downloaded and adjusted prior to git installation, if needed.

    bootstrap_git__enablerepo: ""

This variable, a well as `bootstrap_git__packages`, will be used to install git via a particular `yum` repo if `bootstrap_git__install_from_source` is false (CentOS only). Any additional repositories you have installed that you would like to use for a newer/different Git version.

    bootstrap_git__packages:
      - git

The specific Git packages that will be installed. By default, only `git` is installed, but you could add additional git-related packages like `git-svn` if desired.

    bootstrap_git__install_from_source: false
    bootstrap_git__install_path: "/usr"
    bootstrap_git__version: "2.26.0"

Whether to install Git from source; if set to `true`, `bootstrap_git__version` is required and will be used to install a particular version of git (see all available versions here: https://www.kernel.org/pub/software/scm/git/), and `bootstrap_git__install_path` defines where git should be installed.

    bootstrap_git__force_update: false

If git is already installed at and older version, force a new source build. Only applies if `bootstrap_git__install_from_source` is `true`.

## Dependencies

None.

## Example Playbook

    - hosts: servers
      roles:
        - { role: bootstrap_git }

