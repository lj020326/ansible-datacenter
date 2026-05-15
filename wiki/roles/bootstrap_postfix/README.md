```markdown
---
title: Ansible Role for Postfix Bootstrap
original_path: roles/bootstrap_postfix/README.md
category: Ansible Roles
tags: [ansible, postfix, email, smtp]
---

# Ansible Role: bootstrap_postfix

Installs and configures Postfix on RedHat/CentOS or Debian/Ubuntu systems.

## Requirements

If you're using this role as an SMTP relay server, you will need to configure the relay settings separately and ensure that TCP port 25 is open in your server's firewall.

## Role Variables

Available variables are listed below along with their default values (see `defaults/main.yml`):

- **bootstrap_postfix__config_file**: `/etc/postfix/main.cf`
  - The path to the Postfix `main.cf` configuration file.
  
- **bootstrap_postfix__service_state**: `started`
  - The desired state of the Postfix service after this role runs.

- **bootstrap_postfix__service_enabled**: `true`
  - Whether to enable the Postfix service on system startup.

- **bootstrap_postfix__inet_interfaces**: `localhost`
  - Specifies which network interfaces Postfix will listen on.

- **bootstrap_postfix__inet_protocols**: `all`
  - The Internet protocols Postfix will attempt to use when making or accepting connections.

- **bootstrap_postfix__install**: `[postfix, mailutils, libsasl2-2, sasl2-bin, libsasl2-modules]`
  - List of packages to install.

- **bootstrap_postfix__hostname**: `{{ ansible_facts['fqdn'] }}`
  - Host name used for `myhostname` and in `mydestination`.

- **bootstrap_postfix__mailname**: `{{ ansible_facts['fqdn'] }}`
  - Mail name (in `/etc/mailname`) used for `myorigin`.

- **bootstrap_postfix__compatibility_level**:
  - Optional. Specifies the compatibility level for Postfix.

- **bootstrap_postfix__map_type**: `hash`
  - The default database type for use in `newaliases`, `postalias` and `postmap` commands.

- **bootstrap_postfix__aliases**: `[]`
  - Aliases to ensure are present in `/etc/aliases`.

- **bootstrap_postfix__virtual_aliases**: `[]`
  - Virtual aliases to ensure are present in `/etc/postfix/virtual`.

- **bootstrap_postfix__sender_canonical_maps**: `[]`
  - Sender address rewriting in `/etc/postfix/sender_canonical_maps` ([see](http://www.postfix.org/postconf.5.html#transport_maps)).

- **bootstrap_postfix__sender_canonical_maps_database_type**: `"{{ bootstrap_postfix__map_type }}"`
  - The database type for use in `bootstrap_postfix__sender_canonical_maps`.

- **bootstrap_postfix__recipient_canonical_maps**: `[]`
  - Recipient address rewriting in `/etc/postfix/recipient_canonical_maps` ([see](http://www.postfix.org/postconf.5.html#sender_dependent_relayhost_maps)).

- **bootstrap_postfix__recipient_canonical_maps_database_type**: `"{{ bootstrap_postfix__map_type }}"`
  - The database type for use in `bootstrap_postfix__recipient_canonical_maps`.

- **bootstrap_postfix__transport_maps**: `[]`
  - Transport mapping based on recipient address in `/etc/postfix/transport_maps` ([see](http://www.postfix.org/postconf.5.html#recipient_canonical_maps)).

- **bootstrap_postfix__transport_maps_database_type**: `"{{ bootstrap_postfix__map_type }}"`
  - The database type for use in `bootstrap_postfix__transport_maps`.

- **bootstrap_postfix__sender_dependent_relayhost_maps**: `[]`
  - Transport mapping based on sender address in `/etc/postfix/sender_dependent_relayhost_maps` ([see](http://www.postfix.org/postconf.5.html#recipient_canonical_maps)).

- **bootstrap_postfix__smtp_header_checks**: `[]`
  - Lookup tables for content inspection of primary non-MIME message headers in `/etc/postfix/header_checks` ([see](http://www.postfix.org/postconf.5.html#header_checks)).

- **bootstrap_postfix__smtp_header_checks_database_type**: `regexp`
  - The database type for use in `header_checks`.

- **bootstrap_postfix__generic**: `bootstrap_postfix__smtp_generic_maps`
  - **Deprecated**, use `bootstrap_postfix__smtp_generic_maps`.

- **bootstrap_postfix__smtp_generic_maps**: `[]`
  - Generic table address mapping in `/etc/postfix/generic` ([see](http://www.postfix.org/generic.5.html)).

- **bootstrap_postfix__smtp_generic_maps_database_type**: `"{{ bootstrap_postfix__map_type }}"`
  - The database type for use in `smtp_generic_maps`.

- **bootstrap_postfix__mydestination**: `["{{ bootstrap_postfix__hostname }}", 'localdomain', 'localhost', 'localhost.localdomain']`
  - Specifies what domains this machine will deliver locally, instead of forwarding to another machine.

- **bootstrap_postfix__mynetworks**: `['127.0.0.0/8', '[::ffff:127.0.0.0]/104', '[::1]/128']`
  - The list of "trusted" remote SMTP clients that have more privileges than "strangers".

- **bootstrap_postfix__relayhost**: `''` (no relay host)
  - Hostname to relay all email to.

- **bootstrap_postfix__relayhost_mxlookup**: `false` (not using mx lookup)
  - Lookup for MX record instead of A record for relayhost.

- **bootstrap_postfix__relayhost_port**: `587`
  - Relay port (on `bootstrap_postfix__relayhost`, if set).

- **bootstrap_postfix__relaytls**: `false`
  - Use TLS when sending with a relay host.

- **bootstrap_postfix__smtpd_client_restrictions**:
  - Optional. List of client restrictions ([see](http://www.postfix.org/postconf.5.html#smtpd_client_restrictions)).

- **bootstrap_postfix__smtpd_helo_restrictions**:
  - Optional. List of helo restrictions ([see](http://www.postfix.org/postconf.5.html#smtpd_helo_restrictions)).

- **bootstrap_postfix__smtpd_sender_restrictions**:
  - Optional. List of sender restrictions ([see](http://www.postfix.org/postconf.5.html#smtpd_sender_restrictions)).

## Backlinks

- [Ansible Roles Documentation](/ansible-roles)
```

This improved version includes a standardized YAML frontmatter, clear headings, and a "Backlinks" section for better navigation and context.