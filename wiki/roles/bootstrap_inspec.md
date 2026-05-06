---
title: Bootstrap Inspec Role Documentation
role: bootstrap_inspec
category: Ansible Roles
type: Installation
tags: inspec, ansible, automation, compliance
---

## Summary

The `bootstrap_inspec` role is designed to automate the installation of the InSpec tool on various Linux distributions, including Debian-based systems (Debian and Ubuntu) and Red Hat Enterprise Linux (RHEL) family systems. This role ensures that the specified version of InSpec is installed and handles downloading, extracting, and installing the package based on the operating system.

## Variables

| Variable Name                             | Default Value                                                                                                    | Description                                                                                                                                                                                                 |
|-------------------------------------------|------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_inspec__app`                   | `inspec`                                                                                                         | The name of the application to be installed.                                                                                                                                                                |
| `bootstrap_inspec__version`               | `5.22.3`                                                                                                         | The specific version of InSpec to install.                                                                                                                                                                  |
| `bootstrap_inspec__debian_os`             | `{{ ansible_facts['distribution'] \| lower }}`                                                                    | The detected Debian-based OS name (e.g., debian, ubuntu).                                                                                                                                                   |
| `bootstrap_inspec__debian_os_version`     | `{{ ansible_facts['distribution_major_version'] }}`                                                               | The major version of the Debian-based OS.                                                                                                                                                                   |
| `bootstrap_inspec__debian_os_arch`        | `amd64`                                                                                                          | The architecture for the Debian-based OS package.                                                                                                                                                           |
| `bootstrap_inspec__debian_dl_url`         | `https://packages.chef.io/files/stable/{{ bootstrap_inspec__app }}/{{ bootstrap_inspec__version }}/{{ bootstrap_inspec__debian_os }}/{{ bootstrap_inspec__debian_os_version }}/{{ bootstrap_inspec__app }}_{{ bootstrap_inspec__version }}-1_{{ bootstrap_inspec__debian_os_arch }}.deb` | The download URL for the Debian package of InSpec.                                                                                                                                                        |
| `bootstrap_inspec__ubuntu_os`             | `{{ ansible_facts['distribution'] \| lower }}`                                                                    | The detected Ubuntu OS name (e.g., ubuntu).                                                                                                                                                                 |
| `bootstrap_inspec__ubuntu_os_version`     | `{{ ansible_facts['distribution_version'] }}`                                                                     | The version of the Ubuntu OS.                                                                                                                                                                               |
| `bootstrap_inspec__ubuntu_os_arch`        | `amd64`                                                                                                          | The architecture for the Ubuntu package.                                                                                                                                                                    |
| `bootstrap_inspec__ubuntu_dl_url`         | `https://packages.chef.io/files/stable/{{ bootstrap_inspec__app }}/{{ bootstrap_inspec__version }}/{{ bootstrap_inspec__ubuntu_os }}/{{ bootstrap_inspec__ubuntu_os_version }}/{{ bootstrap_inspec__app }}_{{ bootstrap_inspec__version }}-1_{{ bootstrap_inspec__debian_os_arch }}.deb` | The download URL for the Ubuntu package of InSpec.                                                                                                                                                        |
| `bootstrap_inspec__el_os`                 | `el`                                                                                                             | The detected Red Hat Enterprise Linux OS name (e.g., el).                                                                                                                                                     |
| `bootstrap_inspec__el_os_version`         | `"7"`                                                                                                            | The version of the RHEL OS.                                                                                                                                                                                 |
| `bootstrap_inspec__el_os_arch`            | `x86_64`                                                                                                         | The architecture for the RHEL package.                                                                                                                                                                      |
| `bootstrap_inspec__el_dl_url`             | `https://packages.chef.io/files/stable/{{ bootstrap_inspec__app }}/{{ bootstrap_inspec__version }}/{{ bootstrap_inspec__el_os }}/{{ bootstrap_inspec__el_os_version }}/{{ bootstrap_inspec__app }}-{{ bootstrap_inspec__version }}-1.el{{ bootstrap_inspec__el_os_version }}.{{ bootstrap_inspec__el_os_arch }}.rpm` | The download URL for the RHEL package of InSpec.                                                                                                                                                          |
| `bootstrap_inspec__inspec_el_disable_gpg_check` | `false`                                                                                                        | Whether to disable GPG check when installing RPM packages on EL systems.                                                                                                                                    |
| `bootstrap_inspec__inspec_el_rpm_key_url` | `https://packages.chef.io/chef.asc`                                                                                | The URL for the Chef signing key used to verify RPM packages.                                                                                                                                               |
| `bootstrap_inspec__inspec_el_rpm_key_fingerprint` | `1168 5DB9 2F03 640A 2FFE 7CA8 2940 ABA9 83EF 826A`                                                         | The fingerprint of the Chef signing key.                                                                                                                                                                    |
| `bootstrap_inspec__inspec_el_rpm_key_state` | `present`                                                                                                        | The state of the RPM key (e.g., present, absent).                                                                                                                                                           |
| `bootstrap_inspec__install_from_source_force_update` | `false`                                                                                                     | Whether to force an update by reinstalling InSpec from source.                                                                                                                                            |
| `bootstrap_inspec__reinstall_from_source` | `false`                                                                                                          | Whether to reinstall InSpec from source if the installed version does not match the specified version or is not found.                                                                                      |

## Usage

To use this role, include it in your Ansible playbook and specify any necessary variables as needed. Here is an example of how to include the role in a playbook:

```yaml
- name: Install InSpec on target hosts
  hosts: all
  roles:
    - role: bootstrap_inspec
      vars:
        bootstrap_inspec__version: "5.22.3"
```

## Dependencies

This role does not have any external dependencies other than the availability of the specified version of InSpec from the Chef packages repository.

## Tags

- `inspec`
- `install`
- `bootstrap`

You can use these tags to target specific tasks within the role when running your playbook. For example:

```bash
ansible-playbook -i inventory playbook.yml --tags "inspec,install"
```

## Best Practices

1. **Version Control**: Always specify a version of InSpec in your playbooks to ensure consistency across environments.
2. **Security**: Ensure that GPG checks are enabled unless there is a specific reason to disable them for RPM installations on EL systems.
3. **Testing**: Use Molecule tests to verify the role's functionality before deploying it to production.

## Molecule Tests

This role includes Molecule tests to ensure its functionality across different operating systems. To run the tests, navigate to the role directory and execute:

```bash
molecule test
```

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_inspec/defaults/main.yml)
- [tasks/install_debian.yml](../../roles/bootstrap_inspec/tasks/install_debian.yml)
- [tasks/install_el.yml](../../roles/bootstrap_inspec/tasks/install_el.yml)
- [tasks/install_ubuntu.yml](../../roles/bootstrap_inspec/tasks/install_ubuntu.yml)
- [tasks/main.yml](../../roles/bootstrap_inspec/tasks/main.yml)