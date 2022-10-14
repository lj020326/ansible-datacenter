
# Guide: Zoho SMTP Postfix Relay

I’d like my server to send me email alerts when services have issues. This guide will walk you through the steps to use Zoho email to achieve this.

```shell
$ sudo nano /etc/postfix/sasl_passwd
```

Add your smtp server, email address, and password (ideally an application-specific password generated in your Zoho control panel):

```shell
smtp.zoho.com email@address.com:password
```

Now hash your postfix password and set proper permissions on the original:

```shell
$ sudo postmap hash:/etc/postfix/sasl_passwd
$ sudo chmod 600 /etc/postfix/sasl_passwd
```

Now, edit `/etc/postfix/main.cf` and add the following lines:

```ini
relayhost = smtp.zoho.com:465
smtp_use_tls = yes
smtp_sasl_auth_enable = yes
smtp_sasl_security_options =
smtp_tls_wrappermode = yes
smtp_tls_security_level = encrypt
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_tls_CAfile = /etc/ssl/certs/Entrust_Root_Certification_Authority.pem
smtp_tls_session_cache_database = btree:/var/lib/postfix/smtp_tls_session_cache
smtp_tls_session_cache_timeout = 3600s
sender_canonical_classes = envelope_sender, header_sender
sender_canonical_maps = regexp:/etc/postfix/sender_canonical
smtp_header_checks = regexp:/etc/postfix/smtp_header_checks
```

Create `/etc/postfix/sender_canonical` and put in your Zoho email address:

Create `/etc/postfix/smtp_header_checks` and put in your Zoho email address

```
/From:.*/ REPLACE From: email@address.com
```

Optionally, if you want to customize the name that the email is coming from, try:

```
/From:.*/ REPLACE From: Dumbledore <email@address.com>
```

**Update 1 Jan 2021** - After rebuilding my Proxmox server with the latest version (6.3), I couldn’t proceed to the next step until I repaired folder permissions, deleted a stuck `master.lock` file, installed `libsasl2-modules`, and restarted the postfix service - for other distros, ymmv:

```shell
$ sudo postfix set-permissions
$ sudo rm /var/lib/postfix/master.lock
$ sudo apt install libsasl2-modules
$ sudo systemctl restart postfix
```

Finally, reload postfix and send a test message:

```shell
$ sudo postfix reload
$ echo "test message" | mail -s "test subject" another@email.com
```

Voila! If you have issues, check your logs in `/var/log/syslog` and `/var/log/mail.info`

### Resources[Permalink](https://bradford.la/2018/zoho-postfix-smtp-relay/#resources "Permalink")

## References

* https://bradford.la/2018/zoho-postfix-smtp-relay/
* 
