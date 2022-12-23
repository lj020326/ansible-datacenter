
# bootstrap-awx : Automation Controller Setup

This playbook bootstraps an AWX/Automation Controller system that can create and manage multiple servers.

It also can install [rancher](https://www.rancher.com/), a tool for managing Kubernetes.

Ideally this system can manage the updates, configuration, backups and monitoring of servers on its own. 


## Installation

To configure and install this AWX/Automation Controller setup on your own server, follow the [bootstrap setup steps detailed here](docs/bootstrap_awx.md).


## Features

- Allow deployment onto Ubuntu 20.04 and 22.04. [done]
- Update AWX to newer version. 1.1.0 [done]
- Update awx-on-k3s to newer version. 1.1.0 [done]
- Update k9s to latest version. [done]

## To Do

- Fix Rancher. []
- Fix AWX token generation. [fixed?]
- Automate backups using borg.
- Automate recovery.
- Automate routine recovery testing for the AWX setup.


## Reference

* https://github.com/PC-Admin/awx-ansible
* 