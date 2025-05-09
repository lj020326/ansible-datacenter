<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

**Table of Contents** _generated with [DocToc](https://github.com/thlorenz/doctoc)_

- [ansible-netplan](#ansible-netplan)
  - [Requirements](#requirements)
  - [Role Variables](#role-variables)
  - [Dependencies](#dependencies)
  - [Example Playbook](#example-playbook)
  - [License](#license)
  - [Author Information](#author-information)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# ansible-netplan

An [Ansible](https://www.ansible.com) role to manage [Netplan](https://netplan.io)

## Requirements

You probably want to run the role with `become: true`

## Role Variables

[defaults/main.yml](defaults/main.yml)

## Dependencies

## Example Playbook

The following is a trivial example of a playbook that sets a single
network interface.  See defaults/main.yml for a full list of values
that can be set for this role.

```yaml
---
- hosts: ...your hosts...
  any_errors_fatal: true
  roles:
    - role: bootstrap_netplan
      become: yes
      # This role will do nothing unless bootstrap_netplan__enabled is true.
      bootstrap_netplan__enabled: true
      
      # This should point to an existing netplan configuration file 
      # on your system which this role will overwrite, 
      # or to a nonexistent file which netplan is aware of.
      #
      # The default is /etc/netplan/config.yaml.
      bootstrap_netplan__config_file: /etc/netplan/my-awesome-netplan.yaml
      
      # Ubuntu 18.04, for example, defaults to using networkd.
      bootstrap_netplan__renderer: networkd
      # Simple network configuration to add a single network interface.
      # Configuration defined bellow will be written to the file defined
      # above in `bootstrap_netplan__config_file`.
      bootstrap_netplan__configuration:
        network:
          version: 2
          ethernets:
            enp28s0f7:
              addresses:
                - 10.11.12.99/24
```

## License

MIT

## Author Information

Larry Smith Jr.

- [EverythingShouldBeVirtual](http://everythingshouldbevirtual.com)
- [@mrlesmithjr](https://www.twitter.com/mrlesmithjr)
- <mailto:mrlesmithjr@gmail.com>
