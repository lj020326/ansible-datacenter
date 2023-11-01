---
layout: post
author: hagzag
tags: 
  - devops
  - Ansible
permalink: "/devops/Running-Your-Own-Ansible-Driven-CA"
published: yes
title: "Running your own Ansible Driven CA"
---
# Overview & Purpose

As a preparation for running a swarm cluster in production, I needed a way to manage my Root CA and distribute the certificates between my SWARM nodes, configuring their services to use them etc etc

# A root CA

There is a bunch of posts / articles out there managing your own CA, none of them offer a free, automated solution which scales.

If running in a public DNS there ss a nice free online solution which can be configured programtically (and via [ansible module](https://docs.ansible.com/ansible/letsencrypt_module.html)) called [https://letsencrypt.org/](https://letsencrypt.org/) there are also provides which give a free official SSL certificate which expire every 3 monthes which could be also a suitable solution … 

In my case I needed a CA I can create | destroy | redistribute etc so I had in a way to create my own kind of solution ...

# CA Objectives

1. Install OpenSSL on your CA server host

    1. Configure the CA server options

    2. Generate CA private key

    3. Generate CA certificate generated with that key

2. Generate the required certificate requests for each of your nodes { including the CA server itself }

3. Distribute both the CA cert and the Host certificates to clients 

4. Configure my services to use these certs & keys

Creates a sub-directory for each domain
For example:

```bash
# ~/pki/example.com
# ~/pki/example.com/cacsr.json - cfssl CA config
# ~/pki/example.com/ca_key.pem
# ~/pki/example.com/ca.csr
# ~/pki/example.com/ca.pem
# ~/pki/example.com/www-1.example.com.csr
# ~/pki/example.com/www-1.example.com-key.pem
# ~/pki/example.com/www-1.example.com.pem
# ~/pki/example.com/www-2.example.com.csr
# ~/pki/example.com/www-2.example.com-key.pem
# ~/pki/example.com/www-2.example.com.pem
# ~/pki/example.com/www-3.example.com.csr
# ~/pki/example.com/www-3.example.com-key.pem
# ~/pki/example.com/www-3.example.com.pem
#...

```



Requirements
------------

A Java installation with JAVA_HOME configured is required on the host.

OpenSSL is required on the host.

Pip is required on the host. See the example Playbook.


# Materials Needed

1. An inventory of hosts you wish to generate certificates for ...

2. [Ansible CA role](https://github.com/shelleg/ansible-role-ca/)

# How does this work ?

__In "ca context" the hosts / inventory could be either generated on the fly via a [Dynamic Inventor*y](http://docs.ansible.com/ansible/intro_dynamic_inventory.html) or via general group_vars/all/xx_hosts file (more on this in another post  …)__

* Ansible managed hosts:

Let’s take a look at a part of our group vars (hosts.yml) which hold our inventory, this example has 1 CA server and 2 nodes like so:

```yaml
ca_root_node:
- commonName: caserver01
  ssl_cert: caserver01-cert.pem
  ssl_key: caserver01-priv-key.pem

ca_node:
  swarm:
    swarm-managers:
      - commonName: swarm-mgr01
        ssl_cert: swarm-mgr01-cert.pem
        ssl_key: swarm-mgr01-priv-key.pem
    swarm-workers:
      - commonName: swarm-node01
        ssl_cert: swarm-node01-cert.pem
        ssl_key: swarm-node01-priv-key.pem
      - commonName: swarm-node02
        ssl_cert: swarm-node02-cert.pem
        ssl_key: swarm-node02-priv-key.pem
```

* Ansible CA role -> [https://github.com/shelleg/ansible-role-ca/](https://github.com/shelleg/ansible-role-ca/) has the following steps:

```yaml
--- # tasks file for role cert-auth
include: ca-init.yml
when: bootstrap_certs__ca_init is defined and ca_force_create == yes

include: certify_nodes.yml
when: bootstrap_certs__ca_certify_nodes is defined and ca_force_certify_nodes

include: fetch_keys.yml
when: bootstrap_certs__ca_fetch_certs is defined

```

* Setting up the CA server:

```yaml
- name: "Ensure openssl is installed"
  apt: name=openssl state=latest

- name: "Delete ca-certs directory"
  file:
    path: "{{ item }}"
    state: absent
    owner: root
    group: root
  with_items:
  - "{{ ca_certs_base_dir }}"
- name: "Make configuration directory"
  file:
    path: "{{ item }}"
    state: directory
    owner: root
    group: root
  with_items:
  - "{{ ca_certs_base_dir }}"

- name: "Deploy configuration items"
  template:
    src: "{{ item }}.j2"
    dest: "{{ ca_certs_base_dir }}/{{ item }}"
    owner: root
    group: root
  with_items:
  - serial
  - ca.conf

- name: "set CA_SUBJECT var"
  set_fact:
    ca_subject: '/C={{ ca_country }}/ST={{ ca_state }}/L={{ ca_locality }}/O={{ ca_organization }}/OU={{ ca_organizationalUnit }}/CN={{ ca_signer_common_name }}/emailAddress={{ ca_email }}'
   when: ca_subject is not defined

- name: "Generate private key && Create root CA files"
  shell: "{{ item }}"
  args:
    chdir: "{{ ca_certs_dir }}"
  with_items:
  - "openssl genrsa -out {{ bootstrap_certs__caroot_key }} 2048"
  - "openssl req -config /usr/lib/ssl/openssl.cnf -new -key {{ bootstrap_certs__caroot_key }} -x509 -days 1825 -out {{ bootstrap_certs__caroot_cert }} -passin pass:{{ ca_rootca_password }} -subj \"{{ ca_subject }}\""
```

* Generating the node certificates:

```yaml
- name: "Generate Certs for Infra server || CA server"
  shell: 'openssl genrsa -out {{ item.commonName }}-priv-key.pem 2048'
  args:
    chdir: "{{ ca_certs_dir }}"
  with_items:
  - "{{ ca_node.ca_root_node }}"
  - "{{ ca_node.swarm.swarm-workers }}"
  - "{{ ca_node.swarm.swarm-managers }}"

- name: "Create certificate request for Infra server || CA server"
  shell: 'openssl req -subj "/CN={{ item.commonName }}" -new -key "{{ item.commonName }}"-priv-key.pem -out "{{ item.commonName }}".csr'
  args:
   chdir: "{{ ca_certs_dir }}"
  with_items:
  - "{{ ca_node.ca_root_node }}"
  - "{{ ca_node.swarm.swarm-workers }}"
  - "{{ ca_node.swarm.swarm-managers }}"

- name: "Generate the CA trusted certificate"
  shell: 'sudo openssl x509 -req -days 1825 -in "{{ item.commonName }}".csr -CA ca.pem -CAkey ca-priv-key.pem -CAcreateserial -out "{{ item.commonName }}"-cert.pem -extensions v3_req -extfile /usr/lib/ssl/openssl.cnf'
  args:
   chdir: "{{ ca_certs_dir }}"
  with_items:
  - "{{ ca_node.ca_root_node }}"
  - "{{ ca_node.swarm.swarm-workers }}"
  - "{{ ca_node.swarm.swarm-managers }}"
```

* Fetching the keys for distribution (copy from CA server to Ansible control machine):

```yaml
- name: "copy keys from ca_root_node to ansible machine for distribution"
  fetch: src="{{ ca_certs_dir }}/{{ item.ssl_key }}" dest="{{ bootstrap_certs__cacert_keys_dir }}/{{ item.ssl_key }}" flat=yes
  with_items:
  - "{{ ca_node.ca_root_node }}"
  - "{{ ca_node.swarm.swarm-workers }}"
  - "{{ ca_node.swarm.swarm-managers }}"

- name: "copy certs from ca_root_node to ansible machine for distribution"
  fetch: src="{{ ca_certs_dir }}/{{ item.ssl_cert }}" dest="{{ bootstrap_certs__cacert_certs_dir }}/{{ item.ssl_cert }}" flat=yes
  with_items:
  - "{{ ca_node.ca_root_node }}"
  - "{{ ca_node.swarm.swarm-workers }}"
  - "{{ ca_node.swarm.swarm-managers }}"

- name: "copy ca.pem ca-priv-key.pem"
  fetch: src="{{ item.src }}" dest="{{ item.dest }}" flat=yes
  with_items:
  - "{{ bootstrap_certs__caroot_cert }}"
  - "{{ bootstrap_certs__caroot_key }}"
  - { src: "{{ ca_certs_dir }}/{{ bootstrap_certs__caroot_cert }}", dest: "{{ bootstrap_certs__cacert_certs_dir }}/{{ item }}" }
  - { src: "{{ ca_certs_dir }}/{{ bootstrap_certs__pki_caroot_key }}", dest: "{{ bootstrap_certs__cacert_keys_dir }}/{{ item }}" }
```

* Distribute the Certs & keys to the various nodes:

```yaml
- name: "Ensures {{ bootstrap_certs__cacert_local_cert_dir }} and {{ bootstrap_certs__cacert_local_key_dir }} dirs exist"
  file: path="{{ item }}" state=directory owner=root group=root mode=0750 recurse=yes
  with_items:
  - "{{ bootstrap_certs__cacert_local_cert_dir }}"
  - "{{ bootstrap_certs__cacert_local_key_dir }}"

- block:

   - name: "copy keys from ca_root_node to ansible machine for distribution"
     copy: src="{{ bootstrap_certs__cacert_keys_dir }}/{{ item.ssl_key }}" dest="{{ bootstrap_certs__cacert_local_key_dir }}/{{ item.ssl_key }}"
     with_items:
     - "{{ ca_node.ca_root_node }}"
     - "{{ ca_node.swarm.swarm-workers }}"
     - "{{ ca_node.swarm.swarm-managers }}"

   - name: "copy certs from ca_root_node to ansible machine for distribution"
     copy: src="{{ bootstrap_certs__cacert_certs_dir }}/{{ item.ssl_cert }}" dest="{{ bootstrap_certs__cacert_local_cert_dir }}/{{ item.ssl_cert }}"
     with_items:
     - "{{ ca_node.ca_root_node }}"
     - "{{ ca_node.swarm.swarm-workers }}"
     - "{{ ca_node.swarm.swarm-managers }}"

 when: inventory_hostname == "{{ item.commonName }}"

# Root CA key/cert

- name: "copy {{ bootstrap_certs__pki_caroot_key }} to {{ bootstrap_certs__cacert_local_key_dir }}"
  copy:
   src: "{{ bootstrap_certs__cacert_keys_dir }}/{{ item }}"
   dest: "{{ bootstrap_certs__cacert_local_key_dir }}/{{ item }}"
  with_items:
  - "{{ bootstrap_certs__pki_caroot_key }}"

- name: "copy {{ bootstrap_certs__caroot_cert }} to {{ bootstrap_certs__ca_local_cert_dir }}"
  copy:
   src: "{{ bootstrap_certs__cacert_certs_dir }}/{{ item }}"
   dest: "{{ bootstrap_certs__ca_local_cert_dir }}/{{ item }}"
  with_items:
  - "{{ bootstrap_certs__caroot_cert }}"
```

# Gotchas

*This role is still under development ...*

Currently running the following playbook will result in all the 6 steps unless you set the available vars to prevent them as seen in the main.yml above.

The supporting vars.yml are:

```yaml
# weather or not you wish to: 
# install and configure the root CA (from scratch)
ca_init: yes
# generate certs for nodes
bootstrap_certs__ca_certify_nodes: yes
# copy key to ansible control machine
ca_fetch_certs: yes
# force creating even if files exist on the node
ca_force_create: yes
# force creating of node certificates
ca_force_certify_nodes: yes
# distribute / copy keys from control machine to nodes
ca_distribute_keys: yes
```

An example playbook setup-ca-server.yml utilizing the CA role to setup the CA server:

```yaml
- hosts: caserver01
  become: yes
  vars:
   bootstrap_certs__ca_init: yes
   bootstrap_certs__ca_certify_nodes: yes
   bootstrap_certs__ca_fetch_certs: yes
   bootstrap_certs__ca_force_create: yes
   bootstrap_certs__ca_force_certify_nodes: yes
  roles:
   - role: bootstrap-cacerts
     tags: ca
```

Example deploy-nodes.yml for nodes needing certificates ...

```yaml
- hosts: ca-swarm-instances
  become: yes
  become_user: root
  roles:
    - role: deploy-cacerts
      tags: ca,core
```

**Go ahead and give a try** and tell me what you think (open an issue if needed ;)) 

# how to create keystore/truststore

For creating a keystore and truststore with self-signed certificates.

Role Variables
--------------

**ca_path: /tmp/testCA** \
**Default:** yes \
The directory where the Certificate Authority should exist.

**trusted_ca_path:** \
**Default:** no \
Path of trusted certificate authorities (certification files) that should be imported to the truststore.

**expiration_days: 365** \
**Default:** yes \
Expiration time in days of the certificates.

**common_name:** \
**Default:** no

**country:** \
**Default:** no

**state:** \
**Default:** no

**locality:** \
**Default:** no

**organization:** \
**Default:** no

**organizational_unit:** \
**Default:** no

**keystore_name: keystore** \
**Default:** yes

**truststore_name: truststore** \
**Default:** yes

**services:** \
**Default:** no \
List of services. Each service has a name, and a list of alternative names. See playbook example below.

**clean_up:** \
**Default:** yes \
If a clean up should be made before running. When a clean up occurrs, all the old certificates and keystores are removed.

Example Playbook
----------------

The following playbook creates and signs certificates with our provided configuration. CN, C, ST, L, O & ON should be set to whatever you want. In the services we can configure which services and alternative names that the certificates should work for.
```yaml
- hosts: localhost
  connection: local
  vars_prompt:
    - name: "keystore_password"
      prompt: "Please provide a password for the keystore"
  pre_tasks:
    - name: ensure pip is installed
      easy_install: { name: pip, state: latest }
      become: yes
  roles:
    - role: snieking.keystore_truststore
      trusted_ca_path: /my/trusted/ca-path/
      clean_up: no
      common_name: thecuriousdev.org
      country: SE
      state: Stockholm
      locality: Grondal
      organization: thecuriousdev
      organizational_unit: blog
      services:
        - name: testservice
          alt_names:
            - "DNS.1  = testservice"
            - "DNS.2  = localhost"
            - "IP.1   = 127.0.0.1"
```


# Going forward

*Issue #1:* Control the creating of the server kay only when the existing CA kay has expired, unless force create is defined … there is a mechanism in place which needs testing ...
*Issue #2:* Add support for more hosts / groups of nodes - currently supports only the ca.ca-server and ca.swarm.* node groups.

Hope you enjoyed this post at least as much as I enjoyed writing this role …

Comments and findings are welcome.
