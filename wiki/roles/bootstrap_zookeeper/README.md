---
title: Apache ZooKeeper Ansible Role
category: Ansible Roles
tags: [Apache, ZooKeeper, Ansible, Debian]
---

# Apache ZooKeeper Ansible Role

This Ansible role installs and configures an Apache ZooKeeper service in a Debian environment.

- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installing](#installing)
- [Usage](#usage)
- [Configuration](#configuration)
- [Testing](#testing)
- [Built With](#built-with)
- [Versioning](#versioning)
- [Authors](#authors)
- [License](#license)
- [Contributing](#contributing)
- [Troubleshooting](#troubleshooting)

## Getting Started

These instructions will help you get a copy of the role for your Ansible Playbook. Once launched, it will install an Apache ZooKeeper server.

### Prerequisites

#### To execute this role:

- Ansible 2.8.1 or higher installed.
- The inventory destination should be a Debian environment.
- You will need to [install Java](https://github.com/idealista/java_role) (version 8 or higher) in that environment after executing this role.

#### For testing purposes:

- Python 2.7 or higher (Note: Python 2 has reached end of life)
- [Pipenv](https://github.com/pypa/pipenv)
- [Docker](https://www.docker.com/) as driver

**Note:** The image hosted on [Docker Hub](https://hub.docker.com/r/idealista/zookeeper/) is only for testing purposes. This image is deployed using *rolling tags* and major changes could break your tests. We strongly do not recommend using containers in production based on this image (though it might be ready in future releases).

### Installing

Create or add to your roles dependency file (e.g., `requirements.yml`):

```yaml
- src: bootstrap_zookeeper
  version: 1.5.0
  name: bootstrap_zookeeper
```

Install the role with the `ansible-galaxy` command:

```sh
ansible-galaxy install -p roles -r requirements.yml
```

Use in a playbook:

```yaml
---

- hosts: someserver
  roles:
    - bootstrap_zookeeper
```

## Usage

To set multiple versions:

```yaml
zookeeper_hosts:
  - host: zookeeper1
    id: 1
  - host: zookeeper2
    id: 2
  - host: zookeeper3
    id: 3
```

## Configuration

This role allows you to configure various ZooKeeper settings through variables. Here are some of the most common ones:

```yaml
# Example configuration
zookeeper_tick_time: 2000
zookeeper_data_dir: /var/lib/zookeeper
zookeeper_client_port: 2181
```

## Testing

```sh
$ pipenv install -r test-requirements.txt --python 2.7
$ pipenv run molecule test
```

## Built With

- [Ansible](https://www.ansible.com/)
- [Debian](https://www.debian.org/)
- [Java](https://www.java.com/)
- [Docker](https://www.docker.com/)

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/repository/tags).

## Authors

- **Your Name** - *Initial work* - [Your GitHub Profile](https://github.com/yourprofile)

See also the list of [contributors](https://github.com/your/repository/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Troubleshooting

If you encounter issues, please check the following:

- Ensure all prerequisites are met
- Verify that the inventory file is correctly configured
- Check the Ansible logs for error messages
- Consult the [issue tracker](https://github.com/your/repository/issues) for similar problems