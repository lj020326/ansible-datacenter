
# How To Test & Build Quickly Ansible Roles With Molecule+Docker

## Table of Contents

1.  [Installing Molecule With Docker Support](#installing-molecule-with-docker-support)
2.  [Initialize WordPress Role With Molecule](#initialize-wordpress-role-with-molecule)
3.  [Configure Molecule](#configure-molecule)
4.  [Automate WordPress Installation on Docker](#automate-wordpress-installation-on-docker)
5.  [Implement TestInfra Unit Tests](#implement-testinfra-unit-tests)
6.  [Test WordPress Role With Molecule](#test-wordpress-role-with-molecule)
7.  [Conclusion](#conclusion)
8.  [Resources](#resources)

Ansible is an agentless open-source automation tool including configuration management, application deployment, and infrastructure orchestration through playbooks running tasks sequentially :

```
---
- name: Install and Start Apache # Name of the playbook 
  hosts: webservers # Host group name
  tasks:
    # Play to install apache with yum module
    - name: Ensure apache is installed
      yum:
        name: httpd
        state enabled
    # Play to start apache with service module
    - name: Ensure apache is running
      service:
        name: httpd
        state: started
```

Ansible playbook to install and configure Apache

Over time the complexity of playbooks can begin hard to read and complex to maintain. In addition, you can have some redundant blocks reused in multiple playbooks. This is where the role concept comes into action by providing an independent component that is reusable.  A role has its own structure and clearly defined objective :

```
$ ansible-galaxy init apache                                                 
- apache was created successfully
$ $ tree apache
my-role
├── README.md
├── defaults
│   └── main.yml
├── files
├── handlers
│   └── main.yml
├── meta
│   └── main.yml
├── tasks
│   └── main.yml
├── templates
└── vars
    └── main.yml

8 directories, 8 files
```

Initialization of a role skeleton

-   The **defaults** directory contains the default variables for the role. Variables here have the lowest priority and can be overridden.
-   The **files** directory contains files targeted to be copied to target hosts
-   The **handlers** directory contains handlers that can be invoked by notify instruction by a service
-   The **meta** directory contains metadata of the role like the author, supported platforms, and dependencies
-   The **tasks** directory contains the list of steps executed by the role
-   The **templates** directory contains file templates using the Jinja2 templating language

The role is usable in playbooks in this way :

```
---
- name: Install and Configure Apache Web Servers
  hosts: webservers
  roles: 
    - role: apache
      vars:
        version: 2.4.48
        
```

Integration of Apache role inside a playbook

Roles can be considered as classical software modules and should be separately tested. For testing purposes, Molecule provides a framework supporting multiple platforms like virtual machines or containers. In this article, we are going to install Molecule to work with Docker and develop a fully testable WordPress. It will also include unit tests with TestInfra to ensure what is done is well what is expected.  The final goal will be to create a Docker image but you can use Docker for testing to target another platform.

## Installing Molecule With Docker Support

Assuming you have python installed with pip :

```
pip install --user ansible==2.9 molecule[docker] pytest-testinfra==6.3.0 pytest==6.2.4
```

Installation of Python dependencies

Check molecule is working :

```
molecule --version
```

## Initialize WordPress Role With Molecule

Molecule is able to generate the full role structured with Docker and TestInfra supports:

```
$ molecule init role -d docker --verifier-name testinfra wordpress
$ tree wordpress
├── README.md
├── defaults
│   └── main.yml
├── files
├── handlers
│   └── main.yml
├── meta
│   └── main.yml
├── molecule
│   └── default
│       ├── converge.yml
│       ├── molecule.yml
│       └── tests
│           ├── conftest.py
│           └── test_default.py
├── tasks
│   └── main.yml
├── templates
├── tests
│   ├── inventory
│   └── test.yml
└── vars
    └── main.yml

12 directories, 14 files
```

Initialization of the WordPress role with the molecule command

It uses previous `ansible-galaxy` command behind the scene and then injects molecule directory and asked dependencies. The `molecule/default` directory contains the default test scenario :

-   `molecule.yml` contains the configuration telling which platform to use, how to lint the role etc. We will see it in the section.
-   `converge.yml` is the playbook in the test sequence running your role
-   `tests` contains basic TestInfra unit tests to run additional verification of the result after Ansible got the job done.

## Configure Molecule

In the Molecule configuration, we add the filenames of the role and collection dependency files. The test sequence is the default generated by the previous molecule command. For the platform, we use `php:7.2-apache` as the base image to configure WordPress. A Jinja2 Dockerfile is specified to add extra packages in the base image :

```
---
dependency:
  name: galaxy
  options:
    ignore-certs: True
    ignore-errors: True
    role-file: requirements.yml
    requirements-file: collections.yml
driver:
  name: docker
platforms:
  - name: wordpress
    image: php:7.2-apache
    dockerfile: ../common/Dockerfile.j2
test_sequence:
  - lint
  - destroy
  - dependency
  - syntax
  - create
  - converge
  - idempotence
  - verify
  - destroy
provisioner:
  name: ansible
  lint: |
    yamllint .
    ansible-lint
    flake8
  config_options:
    defaults:
      remote_tmp: /tmp/.ansible
verifier:
  name: testinfra
```

molecule/default/molecule.yml

```
---
collections:
  - community.general
```

collections.yml

```
---
roles: []
```

requirements.yml

The converge playbook is redefined to include the WordPress role and the needed collection :

```
---
- name: Converge
  hosts: all
  collections:
    - community.general
  tasks:
    - name: Include wordpress role
      include_role:
        name: wordpress
```

molecule/default/converge.yml

```
{% if item.registry is defined %}
FROM {{ item.registry.url }}/{{ item.image }}
{% else %}
FROM {{ item.image }}
{% endif %}

{% if item.env is defined %}
{% for var, value in item.env.items() %}
{% if value %}
ENV {{ var }} {{ value }}
{% endif %}
{% endfor %}
{% endif %}

RUN apt update -y && \
apt install -y bash ca-certificates curl python3 python3-apt sudo vim sudo
```

molecule/common/Dockerfile.j2

## Automate WordPress Installation on Docker

The apache user and group are grouped into the defaults to avoid repetition :

```
---
# defaults file for test
apache_user: www-data
apache_group: www-data
```

defaults/main.yml

The task file contains the configuration recipe of the WordPress role. [wp-cli](https://wp-cli.org/) to installs and configures WordPress when the container is started through an entrypoint file :

```
---
# tasks file for wordpress
- name: Wordpress | Enable apache mod expires
  command: a2enmod rewrite expires
  changed_when: "'molecule-idempotence-notest' not in ansible_skip_tags"

- name: Wordpress | Install prerequisites packages
  apt:
    name: ["aptitude", "wget", "libpng-dev", "libjpeg-dev", "libjpeg62-turbo-dev", "libfreetype6-dev",
           "gnupg", "mariadb-client"]
    update_cache: yes
    state: present
    force_apt_get: yes
  tags: package

- name: Wordpress | Find all files in apt cache
  find:
    paths: /var/lib/apt/lists
    recurse: yes
  register: files_to_delete

- name: Wordpress | Clean apt cache
  file:
    command: "{{ item.path }}"
    state: absent
  with_items: "{{ files_to_delete.files }}"
  changed_when: "'molecule-idempotence-notest' not in ansible_skip_tags"

- name: Wordpress | Clean apt
  command: apt clean
  changed_when: "'molecule-idempotence-notest' not in ansible_skip_tags"

- name: Wordpress | Add jpeg and freetype support
  command: docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
  changed_when: "'molecule-idempotence-notest' not in ansible_skip_tags"

- name: Wordpress | Add MySQL support
  command: docker-php-ext-install gd mysqli
  changed_when: "'molecule-idempotence-notest' not in ansible_skip_tags"

- name: Wordpress | Configure php.ini
  template:
    src: php.ini.j2
    dest: /usr/local/etc/php/php.ini
    owner: "{{ apache_user }}"
    group: "{{ apache_group }}"
    mode: 0644

- name: Wordpress | Download wp-cli
  get_url:
    url: https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    dest: /usr/local/bin/wp
    mode: 0750

- name: Wordpress | Configure entrypoint
  copy:
    src: files/entrypoint.sh
    dest: /opt/entrypoint.sh
    mode: 0750
```

tasks/main.yml

There is also a template file to configure PHP settings :

```
date.timezone = Europe/Paris
```

templates/php.ini.j2

The entrypoint is a bash script passing variables from the docker command line to the container's environment variables. The variables are then loaded to the WordPress server. This avoids storing sensitive data and having static configuration inside the Docker image :

```
#!/usr/bin/env bash
set -eu

if [[ "$1" == apache2* ]] || [ "$1" == php-fpm ]; then
: ${WP_DB_WAIT_TIME:=${WP_DB_WAIT_TIME:-20}}
: ${WP_VERSION:=${WP_VERSION:-4.6.1}}
: ${WP_DOMAIN:=${WP_DOMAIN:-localhost}}
: ${WP_URL:=${WP_URL:-http://localhost}}
: ${WP_LOCALE:=${WP_LOCALE:-en_US}}
: ${WP_SITE_TITLE:=${WP_SITE_TITLE:-WordPress for development}}
: ${WP_ADMIN_USER:=${WP_ADMIN_USER:-admin}}
: ${WP_ADMIN_PASSWORD:=${WP_ADMIN_PASSWORD:-admin}}
: ${WP_ADMIN_EMAIL:=${WP_ADMIN_EMAIL:-admin@example.com}}
: ${WP_DB_HOST:=mysql}
: ${WP_DB_USER:=${MYSQL_ENV_MYSQL_USER:-root}}

sleep ${WP_DB_WAIT_TIME}

if [ "$WP_DB_USER" = 'root' ]; then
: ${WP_DB_PASSWORD:=$MYSQL_ENV_MYSQL_ROOT_PASSWORD}
fi
: ${WP_DB_PASSWORD:=$MYSQL_ENV_MYSQL_PASSWORD}
: ${WP_DB_NAME:=${MYSQL_ENV_MYSQL_DATABASE:-wordpress}}

if [ -z "$WP_DB_PASSWORD" ]; then
echo >&2 'error: missing required WP_DB_PASSWORD environment variable'
exit 1
fi

wp cli --allow-root update --nightly --yes

# Download WordPress.
wp core --allow-root download \
--version=${WP_VERSION} \
--force --debug

if -f /var/www/html/wp-config; then
rm -f /var/www/html/wp-config
fi

# Generate the wp-config file for debugging.
wp core --allow-root config \
--dbhost="$WP_DB_HOST" \
--dbname="$WP_DB_NAME" \
--dbuser="$WP_DB_USER" \
--dbpass="$WP_DB_PASSWORD" \
--locale="$WP_LOCALE" \
--extra-php <<PHP
define('WP_DEBUG', true );
define('WP_DEBUG_LOG', true );
PHP

if ! wp --allow-root db check; then
# Create the database.
wp db --allow-root create
fi

if ! wp core is-installed; then
wp core --allow-root install \
--url="${WP_URL}" \
--title="${WP_SITE_TITLE}" \
--admin_user="${WP_ADMIN_USER}" \
--admin_password="${WP_ADMIN_PASSWORD}" \
--admin_email="${WP_ADMIN_EMAIL}" \
--skip-email
# Add domain to hosts file. Required for Boot2Docker.
echo "127.0.0.1 ${WP_DOMAIN}" >> /etc/hosts
fi
fi

echo >&2 "Access the WordPress admin panel here ${WP_URL}"
exec "$@"
```

files/entrypoint.sh

## Implement TestInfra Unit Tests

We use TestInfra to ensure templates and files are well present with good permissions :

```
"""Role testing files using testinfra."""

APACHE_USER = "www-data"
APACHE_GROUP = "www-data"


def test_php_ini(host):
php_ini = host.file("/usr/local/etc/php/php.ini")
assert php_ini.user == APACHE_USER
assert php_ini.group == APACHE_GROUP
assert php_ini.mode == 0o644


def test_wp_cli(host):
wp_cli = host.file("/usr/local/bin/wp")
assert wp_cli.mode == 0o750


def test_entrypoint(host):
entrypoint = host.file("/opt/entrypoint.sh")
assert entrypoint.exists
assert entrypoint.mode == 0o750
```

molecule/default/tests/test\_default.py

TestInfra has a lot of modules to make extra verifications. You can check it out [here](https://testinfra.readthedocs.io/en/latest/modules.html).

## Test WordPress Role With Molecule

The molecule test command executes all the test sequences defined before  in the configuration file :

```
$ molecule test
INFO     default scenario test matrix: dependency, lint, cleanup, destroy, syntax, create, prepare, converge, idempotence, side_effect, verify, cleanup, destroy
INFO     Performing prerun...
INFO     Running ansible-galaxy role install --roles-path /home/vagrant/.cache/ansible-lint/48cbf3/roles -vr requirements.yml
INFO     Using /home/vagrant/.cache/ansible-lint/48cbf3/roles/guivin.wordpress_docker symlink to current repository in order to enable Ansible to find the role using its expected full name.
INFO     Added ANSIBLE_ROLES_PATH=~/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles:/home/vagrant/.cache/ansible-lint/48cbf3/roles
INFO     Running default > dependency
INFO     Dependency completed successfully.
Process install dependency map
|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-Starting collection install process
|Installing 'community.general:3.4.0' to '/home/vagrant/.cache/molecule/wordpress/default/collections/ansible_collections/community/general'
/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\
INFO     Dependency completed successfully.
INFO     Running default > lint
INFO     Lint is disabled.
INFO     Running default > cleanup
WARNING  Skipping, cleanup playbook not configured.
INFO     Running default > destroy
INFO     Confidence checks: 'docker'

PLAY [Destroy] *******************************************************************************************************************************************************************************************

TASK [Destroy molecule instance(s)] **********************************************************************************************************************************************************************
changed: [localhost] => (item=wordpress)

TASK [Wait for instance(s) deletion to complete] *********************************************************************************************************************************************************
ok: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '629242891697.541', 'results_file': '/home/vagrant/.ansible_async/629242891697.541', 'changed': True, 'failed': False, 'item': {'dockerfile': '../common/Dockerfile.j2', 'image': 'php:7.2-apache', 'name': 'wordpress', 'privileged': True}, 'ansible_loop_var': 'item'})

TASK [Delete docker network(s)] **************************************************************************************************************************************************************************

PLAY RECAP ***********************************************************************************************************************************************************************************************
localhost                  : ok=2    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

INFO     Running default > syntax

playbook: /vagrant/roles/wordpress/molecule/default/converge.yml
INFO     Running default > create

PLAY [Create] ********************************************************************************************************************************************************************************************

TASK [Log into a Docker registry] ************************************************************************************************************************************************************************
skipping: [localhost] => (item={'dockerfile': '../common/Dockerfile.j2', 'image': 'php:7.2-apache', 'name': 'wordpress', 'privileged': True}) 

TASK [Check presence of custom Dockerfiles] **************************************************************************************************************************************************************
ok: [localhost] => (item={'dockerfile': '../common/Dockerfile.j2', 'image': 'php:7.2-apache', 'name': 'wordpress', 'privileged': True})

TASK [Create Dockerfiles from image names] ***************************************************************************************************************************************************************
changed: [localhost] => (item={'dockerfile': '../common/Dockerfile.j2', 'image': 'php:7.2-apache', 'name': 'wordpress', 'privileged': True})

TASK [Discover local Docker images] **********************************************************************************************************************************************************************
ok: [localhost] => (item={'diff': [], 'dest': '/home/vagrant/.cache/molecule/wordpress/default/Dockerfile_php_7_2_apache', 'src': '/tmp/.ansible/ansible-tmp-1627924793.4338043-252280101443736/source', 'md5sum': 'c40449541cb68c8437655b9e442a99d2', 'checksum': 'dc3f26f3835156f5648b1bbd65c390220fe944ca', 'changed': True, 'uid': 1000, 'gid': 1000, 'owner': 'vagrant', 'group': 'vagrant', 'mode': '0600', 'state': 'file', 'size': 122, 'invocation': {'module_args': {'src': '/tmp/.ansible/ansible-tmp-1627924793.4338043-252280101443736/source', 'dest': '/home/vagrant/.cache/molecule/wordpress/default/Dockerfile_php_7_2_apache', 'mode': '0600', 'follow': False, '_original_basename': 'Dockerfile.j2', 'checksum': 'dc3f26f3835156f5648b1bbd65c390220fe944ca', 'backup': False, 'force': True, 'content': None, 'validate': None, 'directory_mode': None, 'remote_src': None, 'local_follow': None, 'owner': None, 'group': None, 'seuser': None, 'serole': None, 'selevel': None, 'setype': None, 'attributes': None, 'regexp': None, 'delimiter': None, 'unsafe_writes': None}}, 'failed': False, 'item': {'dockerfile': '../common/Dockerfile.j2', 'image': 'php:7.2-apache', 'name': 'wordpress', 'privileged': True}, 'ansible_loop_var': 'item', 'i': 0, 'ansible_index_var': 'i'})

TASK [Build an Ansible compatible image (new)] ***********************************************************************************************************************************************************
ok: [localhost] => (item=molecule_local/php:7.2-apache)

TASK [Create docker network(s)] **************************************************************************************************************************************************************************

TASK [Determine the CMD directives] **********************************************************************************************************************************************************************
ok: [localhost] => (item={'dockerfile': '../common/Dockerfile.j2', 'image': 'php:7.2-apache', 'name': 'wordpress', 'privileged': True})

TASK [Create molecule instance(s)] ***********************************************************************************************************************************************************************
changed: [localhost] => (item=wordpress)

TASK [Wait for instance(s) creation to complete] *********************************************************************************************************************************************************
FAILED - RETRYING: Wait for instance(s) creation to complete (300 retries left).
changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '553950933721.739', 'results_file': '/home/vagrant/.ansible_async/553950933721.739', 'changed': True, 'failed': False, 'item': {'dockerfile': '../common/Dockerfile.j2', 'image': 'php:7.2-apache', 'name': 'wordpress', 'privileged': True}, 'ansible_loop_var': 'item'})

PLAY RECAP ***********************************************************************************************************************************************************************************************
localhost                  : ok=7    changed=3    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0

INFO     Running default > prepare
WARNING  Skipping, prepare playbook not configured.
INFO     Running default > converge

PLAY [Converge] ******************************************************************************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************************************************************************
ok: [wordpress]

TASK [Include wordpress role] ****************************************************************************************************************************************************************************

TASK [wordpress : Wordpress | Enable apache mod expires] *************************************************************************************************************************************************
changed: [wordpress]

TASK [wordpress : Wordpress | Install prerequisites packages] ********************************************************************************************************************************************
changed: [wordpress]

TASK [wordpress : Wordpress | Find all files in apt cache] ***********************************************************************************************************************************************
ok: [wordpress]

TASK [wordpress : Wordpress | Clean apt cache] ***********************************************************************************************************************************************************
changed: [wordpress] => (item={'path': '/var/lib/apt/lists/security.debian.org_debian-security_dists_buster_updates_InRelease', 'mode': '0644', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 65372, 'inode': 262381, 'dev': 2049, 'nlink': 1, 'atime': 1627862493.0, 'mtime': 1627862493.0, 'ctime': 1627924810.2230368, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': True, 'xgrp': False, 'woth': False, 'roth': True, 'xoth': False, 'isuid': False, 'isgid': False})
changed: [wordpress] => (item={'path': '/var/lib/apt/lists/security.debian.org_debian-security_dists_buster_updates_main_binary-amd64_Packages.lz4', 'mode': '0644', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 581052, 'inode': 262389, 'dev': 2049, 'nlink': 1, 'atime': 1627843047.0, 'mtime': 1627843047.0, 'ctime': 1627924810.2230368, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': True, 'xgrp': False, 'woth': False, 'roth': True, 'xoth': False, 'isuid': False, 'isgid': False})
changed: [wordpress] => (item={'path': '/var/lib/apt/lists/deb.debian.org_debian_dists_buster-updates_InRelease', 'mode': '0644', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 51901, 'inode': 262383, 'dev': 2049, 'nlink': 1, 'atime': 1627913428.0, 'mtime': 1627913428.0, 'ctime': 1627924810.2230368, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': True, 'xgrp': False, 'woth': False, 'roth': True, 'xoth': False, 'isuid': False, 'isgid': False})
changed: [wordpress] => (item={'path': '/var/lib/apt/lists/deb.debian.org_debian_dists_buster_InRelease', 'mode': '0644', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 121562, 'inode': 262382, 'dev': 2049, 'nlink': 1, 'atime': 1624095664.0, 'mtime': 1624095664.0, 'ctime': 1627924809.9148827, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': True, 'xgrp': False, 'woth': False, 'roth': True, 'xoth': False, 'isuid': False, 'isgid': False})
changed: [wordpress] => (item={'path': '/var/lib/apt/lists/deb.debian.org_debian_dists_buster-updates_main_binary-amd64_Packages.diff_Index', 'mode': '0644', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 7624, 'inode': 262384, 'dev': 2049, 'nlink': 1, 'atime': 1624457148.0, 'mtime': 1624457148.0, 'ctime': 1627924810.2230368, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': True, 'xgrp': False, 'woth': False, 'roth': True, 'xoth': False, 'isuid': False, 'isgid': False})
changed: [wordpress] => (item={'path': '/var/lib/apt/lists/lock', 'mode': '0640', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 0, 'inode': 262378, 'dev': 2049, 'nlink': 1, 'atime': 1624282938.0, 'mtime': 1624282938.0, 'ctime': 1627924809.7267888, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': True, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
changed: [wordpress] => (item={'path': '/var/lib/apt/lists/deb.debian.org_debian_dists_buster-updates_main_binary-amd64_Packages.lz4', 'mode': '0644', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 26620, 'inode': 262390, 'dev': 2049, 'nlink': 1, 'atime': 1619186242.0, 'mtime': 1624457148.0, 'ctime': 1627924810.2230368, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': True, 'xgrp': False, 'woth': False, 'roth': True, 'xoth': False, 'isuid': False, 'isgid': False})
changed: [wordpress] => (item={'path': '/var/lib/apt/lists/deb.debian.org_debian_dists_buster_main_binary-amd64_Packages.lz4', 'mode': '0644', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 16782139, 'inode': 778958, 'dev': 2049, 'nlink': 1, 'atime': 1624093156.0, 'mtime': 1624093156.0, 'ctime': 1624282975.5261908, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': True, 'xgrp': False, 'woth': False, 'roth': True, 'xoth': False, 'isuid': False, 'isgid': False})

TASK [wordpress : Wordpress | Add jpeg and freetype support] *********************************************************************************************************************************************
changed: [wordpress]

TASK [wordpress : Wordpress | Add MySQL support] *********************************************************************************************************************************************************
changed: [wordpress]

TASK [wordpress : Wordpress | Configure php.ini] *********************************************************************************************************************************************************
changed: [wordpress]

TASK [wordpress : Wordpress | Download wp-cli] ***********************************************************************************************************************************************************
changed: [wordpress]

TASK [wordpress : Wordpress | Configure entrypoint] ******************************************************************************************************************************************************
changed: [wordpress]

PLAY RECAP ***********************************************************************************************************************************************************************************************
wordpress                  : ok=10   changed=8    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

INFO     Running default > idempotence

PLAY [Converge] ******************************************************************************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************************************************************************
ok: [wordpress]

TASK [Include wordpress role] ****************************************************************************************************************************************************************************

TASK [wordpress : Wordpress | Enable apache mod expires] *************************************************************************************************************************************************
ok: [wordpress]

TASK [wordpress : Wordpress | Install prerequisites packages] ********************************************************************************************************************************************
ok: [wordpress]

TASK [wordpress : Wordpress | Find all files in apt cache] ***********************************************************************************************************************************************
ok: [wordpress]

TASK [wordpress : Wordpress | Clean apt cache] ***********************************************************************************************************************************************************
ok: [wordpress] => (item={'path': '/var/lib/apt/lists/security.debian.org_debian-security_dists_buster_updates_InRelease', 'mode': '0644', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 65372, 'inode': 262375, 'dev': 2049, 'nlink': 1, 'atime': 1627862493.0, 'mtime': 1627862493.0, 'ctime': 1627924862.6932588, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': True, 'xgrp': False, 'woth': False, 'roth': True, 'xoth': False, 'isuid': False, 'isgid': False})
ok: [wordpress] => (item={'path': '/var/lib/apt/lists/deb.debian.org_debian_dists_buster_main_binary-amd64_Packages.lz4', 'mode': '0644', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 16782139, 'inode': 262378, 'dev': 2049, 'nlink': 1, 'atime': 1624093156.0, 'mtime': 1624093156.0, 'ctime': 1627924862.6852548, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': True, 'xgrp': False, 'woth': False, 'roth': True, 'xoth': False, 'isuid': False, 'isgid': False})
ok: [wordpress] => (item={'path': '/var/lib/apt/lists/security.debian.org_debian-security_dists_buster_updates_main_binary-amd64_Packages.lz4', 'mode': '0644', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 581052, 'inode': 262402, 'dev': 2049, 'nlink': 1, 'atime': 1627843047.0, 'mtime': 1627843047.0, 'ctime': 1627924862.6932588, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': True, 'xgrp': False, 'woth': False, 'roth': True, 'xoth': False, 'isuid': False, 'isgid': False})
ok: [wordpress] => (item={'path': '/var/lib/apt/lists/deb.debian.org_debian_dists_buster-updates_InRelease', 'mode': '0644', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 51901, 'inode': 262403, 'dev': 2049, 'nlink': 1, 'atime': 1627913428.0, 'mtime': 1627913428.0, 'ctime': 1627924862.6932588, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': True, 'xgrp': False, 'woth': False, 'roth': True, 'xoth': False, 'isuid': False, 'isgid': False})
ok: [wordpress] => (item={'path': '/var/lib/apt/lists/deb.debian.org_debian_dists_buster_InRelease', 'mode': '0644', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 121562, 'inode': 262400, 'dev': 2049, 'nlink': 1, 'atime': 1624095664.0, 'mtime': 1624095664.0, 'ctime': 1627924862.6812527, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': True, 'xgrp': False, 'woth': False, 'roth': True, 'xoth': False, 'isuid': False, 'isgid': False})
ok: [wordpress] => (item={'path': '/var/lib/apt/lists/lock', 'mode': '0640', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 0, 'inode': 262352, 'dev': 2049, 'nlink': 1, 'atime': 1627924859.8478367, 'mtime': 1627924859.8478367, 'ctime': 1627924859.8478367, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': True, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
ok: [wordpress] => (item={'path': '/var/lib/apt/lists/deb.debian.org_debian_dists_buster-updates_main_binary-amd64_Packages.lz4', 'mode': '0644', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 26620, 'inode': 262383, 'dev': 2049, 'nlink': 1, 'atime': 1624456683.0, 'mtime': 1624456683.0, 'ctime': 1627924862.6932588, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': True, 'xgrp': False, 'woth': False, 'roth': True, 'xoth': False, 'isuid': False, 'isgid': False})

TASK [wordpress : Wordpress | Add jpeg and freetype support] *********************************************************************************************************************************************
ok: [wordpress]

TASK [wordpress : Wordpress | Add MySQL support] *********************************************************************************************************************************************************
ok: [wordpress]

TASK [wordpress : Wordpress | Configure php.ini] *********************************************************************************************************************************************************
ok: [wordpress]

TASK [wordpress : Wordpress | Download wp-cli] ***********************************************************************************************************************************************************
ok: [wordpress]

TASK [wordpress : Wordpress | Configure entrypoint] ******************************************************************************************************************************************************
ok: [wordpress]

PLAY RECAP ***********************************************************************************************************************************************************************************************
wordpress                  : ok=10   changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

INFO     Idempotence completed successfully.
INFO     Running default > side_effect
WARNING  Skipping, side effect playbook not configured.
INFO     Running default > verify
INFO     Executing Testinfra tests found in /vagrant/roles/wordpress/molecule/default/tests/...
============================= test session starts ==============================
platform linux -- Python 3.9.4, pytest-6.2.4, py-1.10.0, pluggy-0.13.1
rootdir: /
plugins: testinfra-6.3.0
collected 3 items

molecule/default/tests/test_default.py ...                               [100%]

============================== 3 passed in 1.85s ===============================
INFO     Verifier completed successfully.
INFO     Running default > cleanup
WARNING  Skipping, cleanup playbook not configured.
INFO     Running default > destroy

PLAY [Destroy] *******************************************************************************************************************************************************************************************

TASK [Destroy molecule instance(s)] **********************************************************************************************************************************************************************
changed: [localhost] => (item=wordpress)

TASK [Wait for instance(s) deletion to complete] *********************************************************************************************************************************************************
FAILED - RETRYING: Wait for instance(s) deletion to complete (300 retries left).
changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '369932584169.31439', 'results_file': '/home/vagrant/.ansible_async/369932584169.31439', 'changed': True, 'failed': False, 'item': {'dockerfile': '../common/Dockerfile.j2', 'image': 'php:7.2-apache', 'name': 'wordpress', 'privileged': True}, 'ansible_loop_var': 'item'})

TASK [Delete docker network(s)] **************************************************************************************************************************************************************************

PLAY RECAP ***********************************************************************************************************************************************************************************************
localhost                  : ok=2    changed=2    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

INFO     Pruning extra files from scenario ephemeral directory
```

You can execute the specific step of the test sequence by replacing the test argument with the step you want (e.g `molecule converge`).

## Conclusion

Coupling Molecule with Docker increases the development velocity of Ansible roles. In addition, using a local Docker daemon doesn't add additional cost contrary to using virtual machines in the cloud. Molecule offers the opportunity to run tests on-demand to inspect there is no regression. When detected they can be easily identified and fixed before any deployment.

In this article, you will discover how to reuse this role to build the WordPress Docker with Packer

## Resources

[Ansible Molecule — Molecule 3.3.5.dev14 documentation](https://molecule.readthedocs.io/en/latest/)

[Intro to playbooks — Ansible Documentation](https://docs.ansible.com/ansible/latest/user_guide/playbooks_intro.html)

[Roles — Ansible Documentation](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html)

[Testinfra test your infrastructure — testinfra 6.4.1.dev1+g05df015.d20210704 documentation](https://testinfra.readthedocs.io/en/latest/)

[Infrastructure as Code](https://getbetterdevops.io/tag/infrastructure-as-code/)

[Testing ansible roles using molecule with docker](https://getbetterdevops.io/testing-ansible-roles-using-molecule-with-docker/)

___