<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [ansible-role-openvswitch](#ansible-role-openvswitch)
  - [Role Variables](#role-variables)
  - [License](#license)
  - [Author Information](#author-information)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

Ansible Role: OpenvSwitch
==========================

[![Build Status](https://travis-ci.org/Anthony25/ansible-role-openvswitch.svg?branch=master)](https://travis-ci.org/Anthony25/ansible-role-openvswitch)

An [Ansible](https://www.ansible.com) multi-platform role to install/configure [Open vSwitch](http://openvswitch.org/)

## Role Variables

```yaml
openvswitch_bridges: []
  # - bridge: 'br-int'
  #   state: 'present'

openvswitch_ports: []
  # - bridge: 'br-int'
  #   ports:
  #     - port: 'enp0s9'
  #       state: 'present'
  #     - port: 'enp0s10'
  #       state: 'present'

openvswitch_system_tuning: []
  # - name: 'net.ipv4.ip_forward'
  #   value: 1
```

```yaml
# overriden variables, predefined by platform in `vars/`

# packages to install
openvswitch_packages: []

# services to enable and start
openvswitch_services: []
```

## License

MIT

## Author Information

Anthony25 \<Anthony Ruhier\>

Larry Smith Jr.

-   [@mrlesmithjr](https://www.twitter.com/mrlesmithjr)
-   [EverythingShouldBeVirtual](http://www.everythingshouldbevirtual.com)
-   [mrlesmithjr.com](http://mrlesmithjr.com)
-   mrlesmithjr [at] gmail.com
