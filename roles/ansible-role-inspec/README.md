
# Ansible Role: Inspec

Role to install (_by default_) extended [inspec](https://github.com/inspec/inspec) on **Debian**, **Ubuntu** and **EL** systems.

## Requirements

None.

## Role Variables

Available variables are listed below (located in `defaults/main.yml`):

### Variables list:

```yaml
inspec_app: inspec
inspec_version: 4.29.3
inspec_debian_os: "{{ ansible_distribution|lower }}"
inspec_debian_os_version: "{{ ansible_distribution_major_version }}"
inspec_debian_os_arch: amd64
inspec_debian_dl_url: "https://packages.chef.io/files/stable/{{ inspec_app }}/{{ inspec_version }}/{{ inspec_debian_os }}/{{ inspec_debian_os_version }}/{{ inspec_app }}_{{ inspec_version }}-1_{{ inspec_debian_os_arch }}.deb"
inspec_ubuntu_os: "{{ ansible_distribution|lower }}"
inspec_ubuntu_os_version: "{{ ansible_distribution_version}}"
inspec_ubuntu_os_arch: amd64
inspec_ubuntu_dl_url: "https://packages.chef.io/files/stable/{{ inspec_app }}/{{ inspec_version }}/{{ inspec_debian_os }}/{{ inspec_debian_os_version }}/{{ inspec_app }}_{{ inspec_version }}-1_{{ inspec_debian_os_arch }}.deb"
inspec_el_os: el
inspec_el_os_arch: x86_64
inspec_el_os_version: "{{ ansible_distribution_major_version }}"
inspec_el_dl_url: "https://packages.chef.io/files/stable/{{ inspec_app }}/{{ inspec_version }}/{{ inspec_el_os }}/{{ inspec_el_os_version }}/{{ inspec_app }}-{{ inspec_version }}-1.el{{ inspec_el_os_version }}.{{ inspec_el_os_arch }}.rpm"
inspec_el_disable_gpg_check: no
inspec_el_rpm_key_url: "https://packages.chef.io/chef.asc"
inspec_el_rpm_key_fingerprint: "1168 5DB9 2F03 640A 2FFE 7CA8 2940 ABA9 83EF 826A"
inspec_el_rpm_key_state: present
```

### Variables table:

Variable                      | Description
----------------------------- | ---------------------------------------------------------------------------------------------------------------------------------
inspec_app                    | Defines the app to install i.e. **inspec**
inspec_version                | Defined to dynamically fetch the desired version to install. Defaults to: **4.29.3**
inspec_debian_os              | Defined to collect the operating system name and store it's value in lowercase
inspec_debian_os_version      | Gathers facts to collect OS Version.
inspec_debian_os_arch         | Defines os architecture. Used for obtaining the correct type of binaries based on OS System Architecture. Defaults to: **amd64**
inspec_debian_dl_url          | Defines URL to download the inspec debian file from for Debain Systems.
inspec_ubuntu_os              | Defined to collect the operating system name and store it's value in lowercase
inspec_ubuntu_os_version      | Gathers facts to collect OS Version.
inspec_ubuntu_os_arch         | Defines os architecture. Used for obtaining the correct type of binaries based on OS System Architecture. Defaults to: **amd64**
inspec_ubuntu_dl_url          | Defines URL to download the inspec debian file from for Ubuntu Systems.
inspec_el_os                  | Defined to for EL based systems.
inspec_el_os_version          | Gathers facts to collect OS major version on EL based systems.
inspec_el_os_arch             | Defines os architecture. Used for obtaining the correct type of binaries based on OS System Architecture. Defaults to: **x86_64**
inspec_el_dl_url              | Defines URL to download the inspec rpm file from for EL based Operating Systems.
inspec_el_disable_gpg_check   | Defines whether to disable the GPG signature checking or not on EL based Operating Systems. Defaults to 'no'.
inspec_el_rpm_key_url         | RPM key to be used for inspec on EL based Operating Systems.
inspec_el_rpm_key_fingerprint | Fingerprint of the rpm key to be used on EL based Operating Systems.
inspec_el_rpm_key_state       | Defines whether the rpm key should be imported or not in rpm db on EL based Operating Systems.

## Dependencies

None

## Example Playbook

For default behaviour of role (i.e. installation of **inspec**) in ansible playbooks.

```yaml
- hosts: servers
  roles:
    - darkwizard242.inspec
```

For customizing behavior of role (i.e. specifying the desired **inspec** version) in ansible playbooks.

```yaml
- hosts: servers
  roles:
    - darkwizard242.inspec
  vars:
    inspec_version: 4.18.99
```
