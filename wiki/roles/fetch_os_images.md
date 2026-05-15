---
title: "fetch_os_images Role Documentation"
role: fetch_os_images
category: Ansible Roles
type: Technical Documentation
tags: ansible, role, os-images, vmware

---

## Summary

The `fetch_os_images` Ansible role is designed to automate the process of downloading and managing operating system (OS) ISO images. It supports fetching various OS distributions from specified URLs, verifying their integrity using checksums, and optionally cloning them to a VMware ISO storage directory if locally mounted.

## Variables

| Variable Name                             | Default Value                                                                                           | Description                                                                                                                                                                                                 |
|-------------------------------------------|---------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `fetch_os_images__osimage_dir`            | `/data/datacenter/jenkins/osimages`                                                                     | The local directory where OS images will be stored.                                                                                                                                                         |
| `fetch_os_images__vmware_images_dir`      | `/vmware/iso-repos/linux`                                                                               | The VMware ISO storage directory where OS images will be cloned if locally mounted.                                                                                                                         |
| `fetch_os_image__vmware_nfs_iso_locally_mounted` | `true`                                                                                                 | A boolean indicating whether the VMware ISO storage is locally mounted.                                                                                                                                     |
| `fetch_os_images__packages`               | `[]`                                                                                                    | A list of packages to be installed before fetching OS images.                                                                                                                                               |
| `fetch_os_images__default_os_images`      | List of default OS images with URLs, files, and checksums (see below)                                     | The default set of OS images that the role will attempt to fetch if no custom images are specified.                                                                                                          |

### Default OS Images

- **CentOS 8**: `http://mirror.cc.columbia.edu/pub/linux/centos/8.1.1911/isos/x86_64/CentOS-8.1.1911-x86_64-dvd1.iso`
- **CentOS 7**: `https://mirror.math.princeton.edu/pub/centos/7.9.2009/isos/x86_64/CentOS-7-x86_64-DVD-2009.iso`
- **CentOS 7 (2003)**: `http://mirror.cc.columbia.edu/pub/linux/centos/7.8.2003/isos/x86_64/CentOS-7-x86_64-DVD-2003.iso`
- **Debian 9**: `https://cdimage.debian.org/cdimage/archive/9.9.0/amd64/jigdo-cd/debian-9.9.0-amd64-netinst.jigdo`
- **Debian 10**: `https://get.debian.org/cdimage/release/current/amd64/iso-cd/debian-10.8.0-amd64-netinst.iso`
- **Ubuntu 18**: `http://cdimage.ubuntu.com/releases/18.04/release/ubuntu-18.04.5-server-amd64.iso`
- **Ubuntu 20**: `https://cdimage.ubuntu.com/ubuntu-legacy-server/releases/20.04/release/ubuntu-20.04.1-legacy-server-amd64.iso`
- **Ubuntu 22**: `https://releases.ubuntu.com/22.04/ubuntu-22.04-live-server-amd64.iso`

## Usage

To use the `fetch_os_images` role, include it in your playbook and specify any custom variables as needed. Here is an example playbook:

```yaml
---
- name: Fetch OS images
  hosts: localhost
  roles:
    - role: fetch_os_images
      vars:
        fetch_os_images__osimage_dir: /path/to/osimages
        fetch_os_images__vmware_images_dir: /path/to/vmware/iso-repos/linux
        fetch_os_image__vmware_nfs_iso_locally_mounted: true
        fetch_os_images__packages:
          - wget
          - jigdo-lite
```

## Dependencies

- `wget` (if not already installed, it can be specified in `fetch_os_images__packages`)
- `jigdo-lite` (required for fetching JIGDO images)

## Best Practices

1. **Checksum Verification**: Always specify checksums to ensure the integrity of downloaded ISO files.
2. **Local Mounting**: Ensure that the VMware ISO storage is correctly mounted if you intend to clone images there.
3. **Package Management**: Specify any required packages in `fetch_os_images__packages` to avoid runtime errors.

## Molecule Tests

This role does not currently include Molecule tests. Consider adding them for automated testing and validation of the role's functionality.

## Backlinks

- [defaults/main.yml](../../roles/fetch_os_images/defaults/main.yml)
- [tasks/fetch-os-image.yml](../../roles/fetch_os_images/tasks/fetch-os-image.yml)
- [tasks/main.yml](../../roles/fetch_os_images/tasks/main.yml)

---

This documentation provides a comprehensive overview of the `fetch_os_images` Ansible role, including its purpose, variables, usage, dependencies, best practices, and backlinks to the source files.