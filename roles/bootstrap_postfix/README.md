# Ansible Role: bootstrap_postfix

Installs postfix on RedHat/CentOS or Debian/Ubuntu.

## Requirements

If you're using this as an SMTP relay server, you will need to do that on your own, and open TCP port 25 in your server firewall.

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

    bootstrap_postfix__config_file: /etc/postfix/main.cf

The path to the Postfix `main.cf` configuration file.

    bootstrap_postfix__service_state: started
    bootstrap_postfix__service_enabled: true

The state in which the Postfix service should be after this role runs, and whether to enable the service on startup.

    bootstrap_postfix__inet_interfaces: localhost
    bootstrap_postfix__inet_protocols: all

Options for values `inet_interfaces` and `inet_protocols` in the `main.cf` file.

 * `bootstrap_postfix__install` [default: `[postfix, mailutils, libsasl2-2, sasl2-bin, libsasl2-modules]`]: Packages to install
 * `bootstrap_postfix__hostname` [default: `{{ ansible_facts['fqdn'] }}`]: Host name, used for `myhostname` and in `mydestination`
 * `bootstrap_postfix__mailname` [default: `{{ ansible_facts['fqdn'] }}`]: Mail name (in `/etc/mailname`), used for `myorigin`

 * `bootstrap_postfix__compatibility_level` [optional]: With backwards compatibility turned on (the compatibility_level value is less than the Postfix built-in value), Postfix looks for settings that are left at their implicit default value, and logs a message when a backwards-compatible default setting is required (e.g. `2`, `Postfix >= 3.0`)

 * `bootstrap_postfix__default_database_type` [default: `hash`]: The default database type for use in `newaliases`, `postalias` and `postmap` commands
 * `bootstrap_postfix__aliases` [default: `[]`]: Aliases to ensure present in `/etc/aliases`
 * `bootstrap_postfix__virtual_aliases` [default: `[]`]: Virtual aliases to ensure present in `/etc/postfix/virtual`
 * `bootstrap_postfix__sender_canonical_maps` [default: `[]`]: Sender address rewriting in `/etc/postfix/sender_canonical_maps` ([see](http://www.postfix.org/postconf.5.html#transport_maps))
 * `bootstrap_postfix__sender_canonical_maps_database_type` [default: `"{{ bootstrap_postfix__default_database_type }}"`]: The database type for use in `bootstrap_postfix__sender_canonical_maps`
 * `bootstrap_postfix__recipient_canonical_maps` [default: `[]`]: Recipient address rewriting in `/etc/postfix/recipient_canonical_maps` ([see](http://www.postfix.org/postconf.5.html#sender_dependent_relayhost_maps))
 * `bootstrap_postfix__recipient_canonical_maps_database_type` [default: `"{{ bootstrap_postfix__default_database_type }}"`]: The database type for use in `bootstrap_postfix__recipient_canonical_maps`
 * `bootstrap_postfix__transport_maps` [default: `[]`]: Transport mapping based on recipient address `/etc/postfix/transport_maps` ([see](http://www.postfix.org/postconf.5.html#recipient_canonical_maps))
 * `bootstrap_postfix__transport_maps_database_type` [default: `"{{ bootstrap_postfix__default_database_type }}"`]: The database type for use in `bootstrap_postfix__transport_maps`
 * `bootstrap_postfix__sender_dependent_relayhost_maps` [default: `[]`]: Transport mapping based on sender address `/etc/postfix/sender_dependent_relayhost_maps` ([see](http://www.postfix.org/postconf.5.html#recipient_canonical_maps))
 * `bootstrap_postfix__smtp_header_checks` [default: `[]`]: Lookup tables for content inspection of primary non-MIME message headers `/etc/postfix/header_checks` ([see](http://www.postfix.org/postconf.5.html#header_checks))
 * `bootstrap_postfix__smtp_header_checks_database_type` [default: `regexp`]: The database type for use in `header_checks`
 * `bootstrap_postfix__generic` [default: `bootstrap_postfix__smtp_generic_maps`]: **Deprecated**, use `bootstrap_postfix__smtp_generic_maps`
 * `bootstrap_postfix__smtp_generic_maps` [default: `[]`]: Generic table address mapping in `/etc/postfix/generic` ([see](http://www.postfix.org/generic.5.html))
 * `bootstrap_postfix__smtp_generic_maps_database_type` [default: `"{{ bootstrap_postfix__default_database_type }}"`]: The database type for use in `smtp_generic_maps`

 * `bootstrap_postfix__mydestination` [default: `["{{ bootstrap_postfix__hostname }}", 'localdomain', 'localhost', 'localhost.localdomain']`]: Specifies what domains this machine will deliver locally, instead of forwarding to another machine
 * `bootstrap_postfix__mynetworks` [default: `['127.0.0.0/8', '[::ffff:127.0.0.0]/104', '[::1]/128']`]: The list of "trusted" remote SMTP clients that have more privileges than "strangers"
 * `bootstrap_postfix__inet_interfaces` [default: `all`]: Network interfaces to bind ([see](http://www.postfix.org/postconf.5.html#inet_interfaces))
 * `bootstrap_postfix__inet_protocols` [default: `all`]: The Internet protocols Postfix will attempt to use when making or accepting connections ([see](http://www.postfix.org/postconf.5.html#inet_protocols))

 * `bootstrap_postfix__relayhost` [default: `''` (no relay host)]: Hostname to relay all email to
 * `bootstrap_postfix__relayhost_mxlookup` [default: `false` (not using mx lookup)]: Lookup for MX record instead of A record for relayhost
 * `bootstrap_postfix__relayhost_port` [default: 587]: Relay port (on `bootstrap_postfix__relayhost`, if set)
 * `bootstrap_postfix__relaytls` [default: `false`]: Use TLS when sending with a relay host

 * `bootstrap_postfix__smtpd_client_restrictions` [optional]: List of client restrictions ([see](http://www.postfix.org/postconf.5.html#smtpd_client_restrictions))
 * `bootstrap_postfix__smtpd_helo_restrictions` [optional]: List of helo restrictions ([see](http://www.postfix.org/postconf.5.html#smtpd_helo_restrictions))
 * `bootstrap_postfix__smtpd_sender_restrictions` [optional]: List of sender restrictions ([see](http://www.postfix.org/postconf.5.html#smtpd_sender_restrictions))
 * `bootstrap_postfix__smtpd_recipient_restrictions` [optional]: List of recipient restrictions ([see](http://www.postfix.org/postconf.5.html#smtpd_recipient_restrictions))
 * `bootstrap_postfix__smtpd_relay_restrictions` [optional]: List of access restrictions for mail relay control ([see](http://www.postfix.org/postconf.5.html#smtpd_relay_restrictions))
 * `bootstrap_postfix__smtpd_data_restrictions` [optional]: List of data restrictions ([see](http://www.postfix.org/postconf.5.html#smtpd_data_restrictions))

 * `bootstrap_postfix__enable_original_recipient`[optional]: Enable/Disable the X-Original-To message header ([see](http://www.postfix.org/postconf.5.html#enable_original_recipient))

 * `bootstrap_postfix__sasl_auth_enable` [default: `true`]: Enable SASL authentication in the SMTP client
 * `bootstrap_postfix__sasl_user` [default: `postmaster@{{ ansible_domain }}`]: SASL relay username
 * `bootstrap_postfix__sasl_password` [default: `k8+haga4@#pR`]: SASL relay password **Make sure to change!**
 * `bootstrap_postfix__sasl_security_options` [default: `noanonymous`]: SMTP client SASL security options
 * `bootstrap_postfix__sasl_tls_security_option` [default: `noanonymous`]: SMTP client SASL TLS security options
 * `bootstrap_postfix__sasl_mechanism_filter` [default: `''`]: SMTP client SASL authentication mechanism filter ([see](http://www.postfix.org/postconf.5.html#smtp_sasl_mechanism_filter))

 * `bootstrap_postfix__smtp_tls_security_level` [default: `encrypt`]: The default SMTP TLS security level for the Postfix SMTP client ([see](http://www.postfix.org/postconf.5.html#smtp_tls_security_level))
 * `bootstrap_postfix__smtp_tls_wrappermode` [default: `false`]: Request that the Postfix SMTP client connects using the legacy SMTPS protocol instead of using the STARTTLS command ([see](http://www.postfix.org/postconf.5.html#smtp_tls_wrappermode))
 * `bootstrap_postfix__smtp_tls_note_starttls_offer` [default: `true`]: Log the hostname of a remote SMTP server that offers STARTTLS, when TLS is not already enabled for that server ([see](http://www.postfix.org/postconf.5.html#smtp_tls_note_starttls_offer))
 * `bootstrap_postfix__smtp_tls_cafile` [optional]: A file containing CA certificates of root CAs trusted to sign either remote SMTP server certificates or intermediate CA certificates (e.g. `/etc/ssl/certs/ca-certificates.crt`)

 * `bootstrap_postfix__smtpd_banner` [default: `$myhostname ESMTP $mail_name (Ubuntu)`]: Greeting banner **You MUST specify $myhostname at the start of the text. This is required by the SMTP protocol.**
 * `bootstrap_postfix__disable_vrfy_command` [default: `true`]: Disable the `SMTP VRFY` command. This stops some techniques used to harvest email addresses
 * `bootstrap_postfix__message_size_limit` [default: `10240000`]: The maximal size in bytes of a message, including envelope information

 * `bootstrap_postfix__smtpd_tls_cert_file` [default: `/etc/ssl/certs/ssl-cert-snakeoil.pem`]: Path to certificate file
 * `bootstrap_postfix__smtpd_tls_key_file` [default: `/etc/ssl/certs/ssl-cert-snakeoil.key`]: Path to key file

 * `bootstrap_postfix__raw_options` [default: `[]`]: List of lines (to pass extra (unsupported) configuration)

## Dependencies

* `debconf`
* `debconf-utils`

### Example(s)

A simple example that doesn't use SASL relaying:

```yaml
---
- hosts: all
  roles:
    - postfix
  vars:
    bootstrap_postfix__aliases:
      - user: root
        alias: you@yourdomain.org
```

A simple example with virtual aliases for mail forwarding that doesn't use SASL relaying:

```yaml
---
- hosts: all
  roles:
    - postfix
  vars:
    bootstrap_postfix__mydestination:
      - "{{ bootstrap_postfix__hostname }}"
      - '$mydomain'
      - localdomain
      - localhost
      - localhost.localdomain
    bootstrap_postfix__virtual_aliases:
      - virtual: webmaster@yourdomain.com
        alias: personal_email@gmail.com
      - virtual: billandbob@yourdomain.com
        alias: bill@gmail.com, bob@gmail.com
```

A simple example that rewrites the sender address:

```yaml
---
- hosts: all
  roles:
    - postfix
  vars:
    bootstrap_postfix__sender_canonical_maps:
      - pattern: root
        result: postmaster@yourdomain.org
```

Provide the relay host name if you want to enable relaying:

```yaml
---
- hosts: all
  roles:
    - postfix
  vars:
    bootstrap_postfix__aliases:
      - user: root
        alias: you@yourdomain.org
    bootstrap_postfix__relayhost: mail.yourdomain.org
```

Provide the relay domain name and use MX records if you want to enable relaying to DNS MX records of a domain:

```yaml
---
- hosts: all
  roles:
    - postfix
  vars:
    bootstrap_postfix__aliases:
      - user: root
        alias: you@yourdomain.org
    bootstrap_postfix__relayhost: yourdomain.org
    bootstrap_postfix__relayhost_mxlookup: true
```

Conditional relaying:

```yaml
---
- hosts: all
  roles:
    - postfix
  vars:
    bootstrap_postfix__transport_maps:
      - pattern: 'root@yourdomain.org'
        result: ':'
      - pattern: '*'
        result: "smtp:{{ ansible_lo['ipv4']['address'] }}:1025"
    bootstrap_postfix__sender_dependent_relayhost_maps:
      - pattern: 'logcheck@yourdomain.org'
        result: 'DUNNO'
      - pattern: 'pflogsumm@yourdomain.org'
        result: 'DUNNO'
      - pattern: '*'
        result: "smtp:{{ ansible_lo['ipv4']['address'] }}:1025"
```

For AWS SES support:

```yaml
---
- hosts: all
  roles:
    - postfix
  vars:
    bootstrap_postfix__aliases:
      - user: root
        alias: sesverified@yourdomain.org
    bootstrap_postfix__relayhost: email-smtp.us-east-1.amazonaws.com
    bootstrap_postfix__relaytls: true
    # AWS IAM SES credentials (not access key):
    bootstrap_postfix__sasl_user: AKIXXXXXXXXXXXXXXXXX
    bootstrap_postfix__sasl_password: ASDFXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

For MailHog support:

```yaml
---
- hosts: all
  roles:
    - postfix
  vars:
    bootstrap_postfix__aliases:
      - user: root
        alias: you@yourdomain.org
    bootstrap_postfix__relayhost: "{{ ansible_lo['ipv4']['address'] }}"
    bootstrap_postfix__relayhost_port: 1025
    bootstrap_postfix__sasl_auth_enable: false
```

For Gmail support:

```yaml
---
- hosts: all
  roles:
    - postfix
  vars:
    bootstrap_postfix__aliases:
      - user: root
        alias: you@yourdomain.org
    bootstrap_postfix__relayhost: smtp.gmail.com
    bootstrap_postfix__relaytls: true
    bootstrap_postfix__smtp_tls_cafile: /etc/ssl/certs/ca-certificates.crt
    bootstrap_postfix__sasl_user: 'foo'
    bootstrap_postfix__sasl_password: 'bar'
```

If you configure your Google account for extra security to use the 2-step verification, then
postfix won't send out emails anymore and you might notice error messages in the `/var/log/mail.log` file

To fix this issue, you need to visit the ([Authorizing applications & sites](http://www.google.com/accounts/IssuedAuthSubTokens?hide_authsub=1))
page under your Google Account settings. On this page enter the name of the application to be authorized (Postfix) and click on Generate button.
Set the `bootstrap_postfix__sasl_password` variable with the password generated by this page.

A simple example that shows how to add some raw config:

```yaml
---
- hosts: all
  roles:
    - postfix
  vars:
    bootstrap_postfix__raw_options:
      - |
        milter_default_action = accept
        milter_protocol = 6
        smtpd_milters = unix:opendkim/opendkim.sock unix:opendmarc/opendmarc.sock unix:spamass/spamass.sock unix:clamav/clamav-milter.ctl
        milter_connect_macros = "i j {daemon_name} v {if_name} _"
        policyd-spf_time_limit = 3600
```



## Dependencies

None.

## Example Playbook

```yaml
- hosts: all
  roles:
    - bootstrap_postfix
```

## Reference

* [ansible-postfix](https://github.com/Oefenweb/ansible-postfix/)!

