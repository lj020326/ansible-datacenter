
# Bootstrap yq

Installs [Yq](https://www.yq.io), a Go-based image and box builder.

## Requirements

None.

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

    bootstrap_yq__version: "4.40.5"

The Yq version to install.

    bootstrap_yq__binary: "yq_linux_amd64"

The name of the binary extracted from the archive.

    bootstrap_yq__bin_path: /usr/local/bin

The location where the Yq binary will be installed (should be in system `$PATH`).

## Dependencies

None.

## Example Playbook

```yaml
- hosts: servers
  roles:
    - bootstrap_yq

```
