```markdown
---
title: SolrCloud Ansible Role Documentation
original_path: roles/bootstrap_solr_cloud/README.md
category: Ansible Roles
tags: solrcloud, ansible, debian, molecule, docker, prometheus
---

![Logo](https://raw.githubusercontent.com/idealista/solrcloud-role/master/logo.gif)

[![Build Status](https://travis-ci.org/idealista/solrcloud-role.png)](https://travis-ci.org/idealista/solrcloud-role)

# SolrCloud Ansible Role

This Ansible role installs a SolrCloud server in a Debian environment.

- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installing](#installing)
- [Usage](#usage)
- [Prometheus Exporter](#prometheus-exporter)
- [Testing](#testing)
- [Built With](#built-with)
- [Versioning](#versioning)
- [Authors](#authors)
- [License](#license)
- [Contributing](#contributing)

## Getting Started

These instructions will get you a copy of the role for your Ansible playbook. Once launched, it will install a [SolrCloud](https://cwiki.apache.org/confluence/display/solr/SolrCloud) server in a Debian system.

### Prerequisites

- **Ansible**: Version 2.5.5.0 or later.
- **Inventory Destination**: Must be a Debian environment.
- **Testing**: [Molecule](https://molecule.readthedocs.io/) with [Docker](https://www.docker.com/) as the driver.

### Installing

1. Create or add to your roles dependency file (e.g., `requirements.yml`):

    ```yaml
    - src: bootstrap_solr_cloud
      version: 2.1.0
      name: solrcloud
    ```

2. Install the role using the `ansible-galaxy` command:

    ```bash
    ansible-galaxy install -p roles -r requirements.yml -f
    ```

3. Use the role in a playbook:

    ```yaml
    ---
    - hosts: someserver
      roles:
        - { role: bootstrap_solr_cloud }
    ```

4. **Example Playbook**: Below is an example playbook that provisions a SolrCloud cluster with two nodes and creates an empty collection called `sample_techproducts_configs`. It uses the idealista [java](https://github.com/idealista/java-role), [zookeeper](https://github.com/idealista/zookeeper-role), and [solrcloud](https://github.com/idealista/solrcloud-role) roles.

    **Note:** This example assumes that the `solrcloud` group has two nodes (`solrcloud1` and `solrcloud2`) as declared in [molecule.yml](https://github.com/idealista/solrcloud-role/tree/master/molecule/default/molecule.yml). The collection will have two shards, one replica per shard, and one shard per node as declared in the group vars file called [solrcloud.yml](https://github.com/idealista/solrcloud-role/tree/master/molecule/default/group_vars/solrcloud.yml). Configuration files are stored under a directory named `sample_techproducts_configs` within the templates directory.

    ```yaml
    ---

    - hosts: zookeeper
      roles:
        - role: bootstrap_zookeeper
      pre_tasks:
        - name: Install required libraries
          apt:
            pkg: "{{ item }}"
            state: present
          loop:
            - net-tools
            - netcat

    - hosts: solrcloud
      roles:
        - role: bootstrap_solr_cloud
    ```

## Usage

Refer to the `defaults` properties file for possible configuration options.

## Prometheus Exporter

To scrape metrics from Solr using [Prometheus](https://github.com/idealista/prometheus_server-role), you need to [configure an exporter](https://lucene.apache.org/solr/guide/7_7/monitoring-solr-with-prometheus-and-grafana.html). We provide a [Prometheus Solr Exporter role](https://github.com/idealista/prometheus_solr_exporter_role) that simplifies this configuration. Ensure that the variables `solr_version` and `prometheus_solr_exporter_version` have the same value.

## Testing

1. Install dependencies:

    ```bash
    pipenv install -r test-requirements.txt --python 2.7
    ```

2. Run tests without destroying the created environment:

    ```bash
    pipenv run molecule test --destroy=never -s setup_with_collections
    ```

**Solr Admin UI**: Accessible from the Docker container host at:

- [http://localhost:8983/solr/#/](http://localhost:8983/solr/#/) (node: `solrcloud1`)
- [http://localhost:8984/solr/#/](http://localhost:8984/solr/#/) (node: `solrcloud2`)

![Solr Admin UI Example](https://raw.githubusercontent.com/idealista/solrcloud-role/master/assets/solr_admin_ui.png)

Refer to [molecule.yml](https://github.com/idealista/solrcloud-role/blob/master/molecule/default/molecule.yml) for available testing platforms.

## Built With

![Ansible](https://img.shields.io/badge/ansible-2.5.5.0-green.svg)

## Versioning

For available versions, see the [tags on this repository](https://github.com/idealista/solrcloud-role/tags).

Additional details about changes in each version can be found in the [CHANGELOG.md](https://github.com/idealista/solrcloud-role/blob/master/CHANGELOG.md) file.

## Authors

- **Idealista** - *Work with* - [idealista](https://github.com/idealista)

See also the list of [contributors](https://github.com/idealista/solrcloud-role/contributors) who participated in this project.

## License

![Apache 2.0 License](https://img.shields.io/hexpm/l/plug.svg)

This project is licensed under the [Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0) license - see the [LICENSE](LICENSE) file for details.

## Contributing

Please read [CONTRIBUTING.md](https://github.com/idealista/solrcloud-role/blob/master/.github/CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## Backlinks

- [Ansible Roles](../ansible_roles.md)
```

This improved Markdown document is structured clearly, uses proper headings, and includes a "Backlinks" section as requested.