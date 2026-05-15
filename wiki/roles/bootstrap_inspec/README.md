```markdown
---
title: Ansible Role for Inspec Installation
original_path: roles/bootstrap_inspec/README.md
category: Ansible Roles
tags: [ansible, inspec, debian, ubuntu, el]
---

# Ansible Role: Inspec

This role installs the extended [InSpec](https://github.com/inspec/inspec) by default on **Debian**, **Ubuntu**, and **EL** systems.

## Requirements

- None.

## Role Variables

Available variables are listed below (located in `defaults/main.yml`):

### Variables List:

```yaml
bootstrap_inspec__app: inspec
bootstrap_inspec__version: 4.29.3
bootstrap_inspec__debian_os: "{{ ansible_facts['distribution']|lower }}"
bootstrap_inspec__debian_os_version: "{{ ansible_facts['distribution_major_version'] }}"
bootstrap_inspec__debian_os_arch: amd64
bootstrap_inspec__debian_dl_url: "https://packages.chef.io/files/stable/{{ bootstrap_inspec__app }}/{{ bootstrap_inspec__version }}/{{ bootstrap_inspec__debian_os }}/{{ bootstrap_inspec__debian_os_version }}/{{ bootstrap_inspec__app }}_{{ bootstrap_inspec__version }}-1_{{ bootstrap_inspec__debian_os_arch }}.deb"
bootstrap_inspec__ubuntu_os: "{{ ansible_facts['distribution']|lower }}"
bootstrap_inspec__ubuntu_os_version: "{{ ansible_facts['distribution_version']}}"
bootstrap_inspec__ubuntu_os_arch: amd64
bootstrap_inspec__ubuntu_dl_url: "https://packages.chef.io/files/stable/{{ bootstrap_inspec__app }}/{{ bootstrap_inspec__version }}/{{ bootstrap_inspec__debian_os }}/{{ bootstrap_inspec__debian_os_version }}/{{ bootstrap_inspec__app }}_{{ bootstrap_inspec__version }}-1_{{ bootstrap_inspec__debian_os_arch }}.deb"
bootstrap_inspec__el_os: el
bootstrap_inspec__el_os_arch: x86_64
bootstrap_inspec__el_os_version: "{{ ansible_facts['distribution_major_version'] }}"
bootstrap_inspec__el_dl_url: "https://packages.chef.io/files/stable/{{ bootstrap_inspec__app }}/{{ bootstrap_inspec__version }}/{{ bootstrap_inspec__el_os }}/{{ bootstrap_inspec__el_os_version }}/{{ bootstrap_inspec__app }}-{{ bootstrap_inspec__version }}-1.el{{ bootstrap_inspec__el_os_version }}.{{ bootstrap_inspec__el_os_arch }}.rpm"
bootstrap_inspec__inspec_el_disable_gpg_check: no
bootstrap_inspec__inspec_el_rpm_key_url: "https://packages.chef.io/chef.asc"
bootstrap_inspec__inspec_el_rpm_key_fingerprint: "1168 5DB9 2F03 640A 2FFE 7CA8 2940 ABA9 83EF 826A"
bootstrap_inspec__inspec_el_rpm_key_state: present
```

### Variables Table:

| Variable                              | Description                                                                                                             |
|---------------------------------------|-------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_inspec__app`               | Defines the app to install, i.e., **InSpec**.                                                                         |
| `bootstrap_inspec__version`           | Specifies the version of InSpec to install. Defaults to: **4.29.3**.                                                  |
| `bootstrap_inspec__debian_os`         | Collects and stores the operating system name in lowercase for Debian systems.                                          |
| `bootstrap_inspec__debian_os_version` | Gathers the OS version for Debian systems.                                                                              |
| `bootstrap_inspec__debian_os_arch`    | Defines the OS architecture, defaulting to **amd64**.                                                                   |
| `bootstrap_inspec__debian_dl_url`     | URL to download the InSpec Debian package for Debian systems.                                                           |
| `bootstrap_inspec__ubuntu_os`         | Collects and stores the operating system name in lowercase for Ubuntu systems.                                          |
| `bootstrap_inspec__ubuntu_os_version` | Gathers the OS version for Ubuntu systems.                                                                              |
| `bootstrap_inspec__ubuntu_os_arch`    | Defines the OS architecture, defaulting to **amd64**.                                                                   |
| `bootstrap_inspec__ubuntu_dl_url`     | URL to download the InSpec Debian package for Ubuntu systems.                                                           |
| `bootstrap_inspec__el_os`             | Specifies that this configuration is for EL-based systems.                                                              |
| `bootstrap_inspec__el_os_version`     | Gathers the OS major version for EL-based systems.                                                                      |
| `bootstrap_inspec__el_os_arch`        | Defines the OS architecture, defaulting to **x86_64**.                                                                  |
| `bootstrap_inspec__el_dl_url`         | URL to download the InSpec RPM package for EL-based systems.                                                            |
| `bootstrap_inspec__inspec_el_disable_gpg_check` | Disables GPG signature checking on EL-based systems if set to 'yes'. Defaults to 'no'.                       |
| `bootstrap_inspec__inspec_el_rpm_key_url`      | URL of the RPM key for InSpec on EL-based systems.                                                              |
| `bootstrap_inspec__inspec_el_rpm_key_fingerprint` | Fingerprint of the RPM key for InSpec on EL-based systems.                                                  |
| `bootstrap_inspec__inspec_el_rpm_key_state`     | Defines whether to import the RPM key into the RPM database on EL-based systems. Defaults to 'present'.      |

## Dependencies

- None.

## Example Playbook

### Default Behavior

To install InSpec with default settings:

```yaml
- hosts: servers
  roles:
    - bootstrap_inspec
```

### Custom Version

To specify a custom version of InSpec:

```yaml
- hosts: servers
  roles:
    - bootstrap_inspec
  vars:
    bootstrap_inspec__version: 4.18.99
```

## Backlinks

- [Ansible Roles Documentation](/ansible-roles)
```

This improved Markdown document maintains the original information while adhering to clean, professional formatting standards suitable for GitHub rendering.