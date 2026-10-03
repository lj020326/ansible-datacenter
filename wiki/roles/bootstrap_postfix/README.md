---
title: Ansible Role: bootstrap_postfix
original_path: roles/bootstrap_postfix/README.md
source_type: legacy_markdown
category: Ansible
tags:
  - Ansible
  - Postfix
  - SMTP
  - Email
harvested_date: '2026-08-07T18:07:09.395952+00:00'
---

# Ansible Role: bootstrap_postfix

Installs Postfix on RedHat/CentOS or Debian/Ubuntu systems.

## Requirements

If you're using this as an SMTP relay server, you will need to configure that on your own, and open TCP port 25 in your server firewall.

## Role Variables

Available variables are listed below, along with their default values (see `defaults/main.yml`):

### Basic Configuration

- `bootstrap_postfix__config_file: /etc/postfix/main.cf`
  The path to the Postfix `main.cf` configuration file.

- `bootstrap_postfix__service_state: started`
- `bootstrap_postfix__service_enabled: true`
  The state in which the Postfix service should be after this role runs, and whether to enable the service on startup.

- `bootstrap_postfix__inet_interfaces: localhost`
- `bootstrap_postfix__inet_protocols: all`
  Options for values `inet_interfaces` and `inet_protocols` in the `main.cf` file.

### Package Installation

- `bootstrap_postfix__install: [postfix, mailutils, libsasl2-2, sasl2-bin, libsasl2-modules]`
  Packages to install.

### Host and Mail Configuration

- `bootstrap_postfix__hostname: {{ ansible_facts['fqdn'] }}`
  Host name, used for `myhostname` and in `mydestination`.

- `bootstrap_postfix__mailname: {{ ansible_facts['fqdn'] }}`
  Mail name (in `/etc/mailname`), used for `myorigin`.

### Compatibility and Map Types

- `bootstrap_postfix__compatibility_level: [optional]`
  With backwards compatibility turned on (the compatibility_level value is less than the Postfix built-in value), Postfix looks for settings that are left at their implicit default value, and logs a message when a backwards-compatible default setting is required (e.g., `2` for Postfix >= 3.0).

- `bootstrap_postfix__map_type: hash`
  The default database type for use in `newaliases`, `postalias`, and `postmap` commands.

### Aliases and Virtual Aliases

- `bootstrap_postfix__aliases: []`
  Aliases to ensure present in `/etc/aliases`.

- `bootstrap_postfix__virtual_aliases: []`
  Virtual aliases to ensure present in `/etc/postfix/virtual`.

### Canonical Maps

- `bootstrap_postfix__sender_canonical_maps: []`
  Sender address rewriting in `/etc/postfix/sender_canonical_maps` ([see](http://www.postfix.org/postconf.5.html#transport_maps)).

- `bootstrap_postfix__sender_canonical_maps_database_type: "{{ bootstrap_postfix__map_type }}"`
  The database type for use in `bootstrap_postfix__sender_canonical_maps`.

- `bootstrap_postfix__recipient_canonical_maps: []`
  Recipient address rewriting in `/etc/postfix/recipient_canonical_maps` ([see](http://www.postfix.org/postconf.5.html#sender_dependent_relayhost_maps)).

- `bootstrap_postfix__recipient_canonical_maps_database_type: "{{ bootstrap_postfix__map_type }}"`
  The database type for use in `bootstrap_postfix__recipient_canonical_maps`.

### Transport Maps

- `bootstrap_postfix__transport_maps: []`
  Transport mapping based on recipient address `/etc/postfix/transport_maps` ([see](http://www.postfix.org/postconf.5.html#recipient_canonical_maps)).

- `bootstrap_postfix__transport_maps_database_type: "{{ bootstrap_postfix__map_type }}"`
  The database type for use in `bootstrap_postfix__transport_maps`.

- `bootstrap_postfix__sender_dependent_relayhost_maps: []`
  Transport mapping based on sender address `/etc/postfix/sender_dependent_relayhost_maps` ([see](http://www.postfix.org/postconf.5.html#recipient_canonical_maps)).

### Header Checks

- `bootstrap_postfix__smtp_header_checks: []`
  Lookup tables for content inspection of primary non-MIME message headers `/etc/postfix/header_checks` ([see](http://www.postfix.org/postconf.5.html#header_checks)).

- `bootstrap_postfix__smtp_header_checks_database_type: regexp`
  The database type for use in `header_checks`.

### Generic Maps

- `bootstrap_postfix__generic: bootstrap_postfix__smtp_generic_maps`
  **Deprecated**, use `bootstrap_postfix__smtp_generic_maps`.

- `bootstrap_postfix__smtp_generic_maps: []`
  Generic table address mapping in `/etc/postfix/generic` ([see](http://www.postfix.org/generic.5.html)).

- `bootstrap_postfix__smtp_generic_maps_database_type: "{{ bootstrap_postfix__map_type }}"`
  The database type for use in `smtp_generic_maps`.

### Destination and Network Configuration

- `bootstrap_postfix__mydestination: ["{{ bootstrap_postfix__hostname }}", 'localdomain', 'localhost', 'localhost.localdomain']`
  Specifies what domains this machine will deliver locally, instead of forwarding to another machine.

- `bootstrap_postfix__mynetworks: ['127.0.0.0/8', '[::ffff:127.0.0.0]/104', '[::1]/128']`
  The list of "trusted" remote SMTP clients that have more privileges than "strangers".

- `bootstrap_postfix__inet_interfaces: all`
  Network interfaces to bind ([see](http://www.postfix.org/postconf.5.html#inet_interfaces)).

- `bootstrap_postfix__inet_protocols: all`
  The Internet protocols Postfix will attempt to use when making or accepting connections ([see](http://www.postfix.org/postconf.5.html#inet_protocols)).

### Relay Configuration

- `bootstrap_postfix__relayhost: ''` (no relay host)
  Hostname to relay all email to.

- `bootstrap_postfix__relayhost_mxlookup: false` (not using mx lookup)
  Lookup for MX record instead of A record for relayhost.

- `bootstrap_postfix__relayhost_port: 587`
  Relay port (on `bootstrap_postfix__relayhost`, if set).

- `bootstrap_postfix__relaytls: false`
  Use TLS when sending with a relay host.

### Restrictions

- `bootstrap_postfix__smtpd_client_restrictions: [optional]`
  List of client restrictions ([see](http://www.postfix.org/postconf.5.html#smtpd_client_restrictions)).

- `bootstrap_postfix__smtpd_helo_restrictions: [optional]`
  List of helo restrictions ([see](http://www.postfix.org/postconf.5.html#smtpd_helo_restrictions)).

- `bootstrap_postfix__smtpd_sender_restrictions: [optional]`
  List of sender restrictions ([see](http://www.postfix.org/postconf.5.html#smtpd_sender_restrictions)).

## Backlinks

[List of related pages or documents that reference this page]