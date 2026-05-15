```markdown
---
title: Guide to Configuring Zoho SMTP Postfix Relay
original_path: roles/bootstrap_postfix/DEBUGGING.md
category: Configuration Guides
tags: [Postfix, Zoho, Email Alerts, SMTP]
---

# Guide: Zoho SMTP Postfix Relay

This guide will walk you through setting up your server to send email alerts using Zoho's SMTP service.

## Step 1: Configure SASL Password File

Edit the `/etc/postfix/sasl_passwd` file:

```shell
$ sudo nano /etc/postfix/sasl_passwd
```

Add your SMTP server, email address, and password (ideally an application-specific password generated in your Zoho control panel):

```ini
smtp.zoho.com:587 email@address.com:password
```

Hash the Postfix password and set proper permissions:

```shell
$ sudo postmap hash:/etc/postfix/sasl_passwd
$ sudo chmod 600 /etc/postfix/sasl_passwd
```

## Step 2: Update Main Configuration File

Edit `/etc/postfix/main.cf` and add the following lines:

```ini
relayhost = [smtp.zoho.com]:587
smtp_use_tls = yes
smtp_sasl_auth_enable = yes
smtp_sasl_security_options =
smtp_tls_wrappermode = no
smtp_tls_security_level = encrypt
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt
smtp_tls_session_cache_database = btree:/var/lib/postfix/smtp_tls_session_cache
smtp_tls_session_cache_timeout = 3600s
sender_canonical_classes = envelope_sender, header_sender
sender_canonical_maps = regexp:/etc/postfix/sender_canonical
smtp_header_checks = regexp:/etc/postfix/smtp_header_checks
```

## Step 3: Configure Sender Canonical Mapping

Create `/etc/postfix/sender_canonical` and add your Zoho email address:

```shell
/.+/    email@address.com
```

## Step 4: Configure SMTP Header Checks

Create `/etc/postfix/smtp_header_checks` and add the following line to replace the `From` header:

```ini
/^From:.*/ REPLACE From: email@address.com
```

Optionally, customize the name that the email is coming from:

```ini
## /^From:.*/ REPLACE From: LOCALHOST System <email@address.com>;
## /^From:.*/ REPLACE From: Dumbledore <email@address.com>
```

## Step 5: Troubleshooting

After rebuilding your server with a new version, you may need to repair folder permissions, delete a stuck `master.lock` file, install `libsasl2-modules`, and restart the Postfix service:

```shell
$ sudo postfix set-permissions
$ sudo rm /var/lib/postfix/master.lock
$ sudo apt install libsasl2-modules
$ sudo systemctl restart postfix
```

## Step 6: Test Configuration

Reload Postfix and send a test message:

```shell
$ sudo postfix reload
$ echo "test message" | mail -s "test subject" recipient@example.com
```

Verify header rewriting:

```shell
$ postmap -fq "From: root <root@media01>" pcre:/etc/postfix/smtp_header_checks 
REPLACE From: admin@dettonville.com
$ postmap -fq "From: root+jenkins@media01" pcre:/etc/postfix/smtp_header_checks 
REPLACE From: admin+jenkins@dettonville.com
```

## References

- [Postfix Header Checks](https://www.postfix.org/header_checks.5.html)
- [Plesk Knowledge Base - Rewriting Headers in Outgoing Mail Messages](https://www.plesk.com/kb/support/how-to-rewrite-headers-in-outgoing-mail-messages/)
- [Configuring Postfix to Relay Email Through Zoho Mail](https://medium.com/@esantanche/configuring-postfix-to-relay-email-through-zoho-mail-890b54d5c445)
- [Bradford.la - Zoho Postfix SMTP Relay](https://bradford.la/2018/zoho-postfix-smtp-relay/)
- [ServerFault - Forcing the From Address When Postfix Relays Over SMTP](https://serverfault.com/questions/147921/forcing-the-from-address-when-postfix-relays-over-smtp)
- [Marcelog GitHub - Configure Postfix Forward Email Regex Subject Transport Relay](https://marcelog.github.io/articles/configure_postfix_forward_email_regex_subject_transport_relay.html)
- [JustAnswer - Using Postfix 2.7 Want Rewrite Header Fields](https://www.justanswer.com/computer-programming/3ic33-i-m-using-postfix-2-7-want-rewrite-header-fields.html)
- [Regex101](https://regex101.com/r/khjXs0/1)
- [Plesk Talk - How to Add Email Header Check for Less Spam with Postfix and SpamAssasin](https://talk.plesk.com/threads/how-to-add-email-header-check-for-less-spam-with-postfix-and-spamassasin.359842/)

## Backlinks

- [Postfix Configuration Documentation](https://www.postfix.org/documentation.html)
- [Zoho Mail Help Center](https://help.zoho.com/portal/en/kb/zoho-mail/)
```

This improved version includes a clean and professional structure with proper headings, an updated YAML frontmatter, and a "Backlinks" section for additional resources.