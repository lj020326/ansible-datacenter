title: Zoho SMTP Postfix Relay Guide
original_path: roles/bootstrap_postfix/zoho_smtp_postfix_relay.md
category: Email Configuration
tags: [Postfix, Zoho, SMTP, Email Relay, Server Alerts]
---

# Zoho SMTP Postfix Relay Guide

This guide will walk you through the steps to configure your server to send email alerts using Zoho's SMTP service.

## Prerequisites

- Root or sudo access to your server
- A Zoho email account with SMTP access

## Configuration Steps

### 1. Create and Edit SASL Password File

Open the SASL password file for editing:

```shell
sudo nano /etc/postfix/sasl_passwd
```

Add your SMTP server, email address, and password (ideally an application-specific password generated in your Zoho control panel):

```ini
smtp.zoho.com email@domain.com:password
```

### 2. Hash the Password File and Set Permissions

Hash the password file and set proper permissions:

```shell
sudo postmap hash:/etc/postfix/sasl_passwd
sudo chmod 600 /etc/postfix/sasl_passwd
```

### 3. Edit Postfix Main Configuration

Edit `/etc/postfix/main.cf` and add the following lines:

```ini
relayhost = smtp.zoho.com:465
smtp_use_tls = yes
smtp_sasl_auth_enable = yes
smtp_sasl_security_options = noanonymous
smtp_tls_wrappermode = yes
smtp_tls_security_level = encrypt
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_tls_CAfile = /etc/ssl/certs/Entrust_Root_Certification_Authority.pem
smtp_tls_session_cache_database = btree:/var/lib/postfix/smtp_tls_session_cache
smtp_tls_session_cache_timeout = 3600s
```

### 4. Create Sender Canonical File (Optional)

If you need to rewrite the sender address, create `/etc/postfix/sender_canonical` and add:

```ini
/.+ email@domain.com
```

### 5. Create SMTP Header Checks File (Optional)

If you need to modify email headers, create `/etc/postfix/smtp_header_checks` and add:

```ini
/^From:.*/ REPLACE From: email@domain.com
```

You can customize the sender name if needed:

```ini
/^From:.*/ REPLACE From: System Admin <email@domain.com>
```

### 6. Reload Postfix and Send Test Message

Reload Postfix and send a test message:

```shell
sudo postfix reload
echo "test message" | mail -s "test subject" recipient@example.com
```

Check your logs in `/var/log/syslog` and `/var/log/mail.info` if you encounter issues.

## References

- [Postfix Header Checks](https://www.postfix.org/header_checks.5.html)
- [Configuring Postfix to Relay Email Through Zoho Mail](https://medium.com/@esantanche/configuring-postfix-to-relay-email-through-zoho-mail-890b54d5c445)
- [Zoho Postfix SMTP Relay](https://bradford.la/2018/zoho-postfix-smtp-relay/)

## Troubleshooting

If you encounter specific issues, consider these steps:

1. Check file permissions for Postfix configuration files
2. Ensure the `libsasl2-modules` package is installed
3. Restart the Postfix service after making changes
4. Consult the Postfix logs for error messages

## Notes

Some steps in this guide are marked as optional. You only need to configure them if your specific use case requires address rewriting or header modifications.