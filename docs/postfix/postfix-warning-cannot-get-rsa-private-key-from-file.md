
# Postfix "warning: cannot get RSA private key from file"

I just followed [this tutorial](http://workaround.org/ispmail/squeeze/) to set up a postfix mailserver with dovecot and mysql as backend for virtual users.

Now I got the most parts working, I can connect to POP3(S) and IMAP(S).

Using

```
echo TEST-MAIL | mail myaccount@hotmail.com
```

works fine, when I log into my hotmail account it shows the email.

It also works in reverse hence my MX entry for **example.com** finally has been propagated, so I am being able to receive emails sent from **myaccount@hotmail.com** to **myvirtualuser@example.com** and view them in Thunderbird using STARTTLS via IMAP.

Doing a bit more research after I got the error message "**5.7.1 : Relay access denied**" when trying to send mails to **myaccount@hotmail.com** using Thunderbird being logged into **myvirtualuser@example.com**, I figured out that my server was acting as an "Open Mail Relay", which - ofcourse - is a bad thing.

Digging more into the optional parts of the tutorial like [this comment](http://workaround.org/comment/2536) and [the other turorial](http://workaround.org/ispmail/squeeze/postfix-smtp-auth), I decided to complete these steps as well to be able to send mails via **myvirtualuser@example.com** through Mozilla Thunderbird, not getting the error message "**5.7.1 : Relay access denied**" anymore (as common mailservers reject open relayed emails).

But now I ran into an error trying to get postfix working with SMTPS, in **/var/log/mail.log** it reads

```
Sep 28 17:29:34 domain postfix/smtpd[20251]: warning: cannot get RSA private key from file /etc/ssl/certs/postfix.pem: disabling TLS support
Sep 28 17:29:34 domain postfix/smtpd[20251]: warning: TLS library problem: 20251:error:0906D06C:PEM routines:PEM_read_bio:no start line:pem_lib.c:650:Expecting: ANY PRIVATE KEY:
Sep 28 17:29:34 domain postfix/smtpd[20251]: warning: TLS library problem: 20251:error:140B0009:SSL routines:SSL_CTX_use_PrivateKey_file:PEM lib:ssl_rsa.c:669:
```

That error is logged right after I try to send a mail from my newly installed mailserver using SMTP SSL/TLS via port 465 in Thunderbird. Thunderbird then tells me a timeout occured.

Google has a few results concerning that problem, yet I couldn't get it working with any of those. I would link some of them here but as a new user I am only allowed to use two hyperlinks.

My **/etc/postfix/master.cf** looks like

```
smtp      inet  n       -       -       -       -       smtpd
smtps     inet  n       -       -       -       -       smtpd
   -o smtpd_tls_wrappermode=yes
   -o smtpd_sasl_auth_enable=yes
```

and **nmap** tells me

```
PORT     STATE SERVICE
[...]
465/tcp  open  smtps
[...]
```

my **/etc/postfix/main.cf** looks like

```
smtpd_banner = $myhostname ESMTP $mail_name (Debian/GNU)
biff = no
append_dot_mydomain = no
readme_directory = no
#smtpd_tls_cert_file = /etc/ssl/certs/postfix.pem            #default postfix generated
#smtpd_tls_key_file = /etc/ssl/private/ssl-cert-snakeoil.key #default postfix generated
smtpd_tls_cert_file = /etc/ssl/certs/postfix.pem
smptd_tls_key_file = /etc/ssl/private/postfix.pem
smtpd_use_tls = yes
smtpd_tls_session_cache_database = btree:${data_directory}/smtpd_scache
smtp_tls_session_cache_database = btree:${data_directory}/smtp_scache
smtpd_sasl_type = dovecot
smtpd_sasl_path = private/auth
smptd_sasl_auth_enable = yes
smtpd_recipient_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination

myhostname = example.com
alias_maps = hash:/etc/aliases
alias_database = hash:/etc/aliases
myorigin = /etc/mailname
mydestination = localhost.com, localhost
relayhost =
mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128
mailbox_size_limit = 0
recipient_delimiter = +
inet_interfaces = all
virtual_mailbox_domains = mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf
virtual_mailbox_maps = mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf
virtual_alias_maps = mysql:/etc/postfix/mysql-virtual-alias-maps.cf
virtual_transport = dovecot
dovecot_destination_recipient_limit = 1
mailbox_command = /usr/lib/dovecot/deliver
```

The \*.pem files were created like described in the tutorial above, using

```
Postfix
To create a certificate to be used by Postfix use:

openssl req -new -x509 -days 3650 -nodes -out /etc/ssl/certs/postfix.pem -keyout /etc/ssl/private/postfix.pem

Do not forget to set the permissions on the private key so that no unauthorized people can read it:

chmod o= /etc/ssl/private/postfix.pem

You will have to tell Postfix where to find your certificate and private key because by default it will look for a dummy certificate file called "ssl-cert-snakeoil":

postconf -e smtpd_tls_cert_file=/etc/ssl/certs/postfix.pem
postconf -e smtpd_tls_key_file=/etc/ssl/private/postfix.pem
```

I think I don't have to include **/etc/dovecot/dovecot.conf** here, as login via imaps and pop3s works fine according to the logs. Only problem is making postfix properly use the self-generated, self-signed certificates.

Any help appreciated!

**_EDIT:_** I just tried [this different tutorial](http://www.e-rave.nl/create-a-self-signed-ssl-key-for-postfix) on generating a self-signed certificate for postfix, still getting the same error. I really don't know what else to test.

I also did check for the SSL libraries, but all seems to be fine:

```
  root@domain:~# ldd /usr/sbin/postfix
    linux-vdso.so.1 =>  (0x00007fff91b25000)
    libpostfix-global.so.1 => /usr/lib/libpostfix-global.so.1 (0x00007f6f8313d000)
    libpostfix-util.so.1 => /usr/lib/libpostfix-util.so.1 (0x00007f6f82f07000)
    libssl.so.0.9.8 => /usr/lib/libssl.so.0.9.8 (0x00007f6f82cb1000)
    libcrypto.so.0.9.8 => /usr/lib/libcrypto.so.0.9.8 (0x00007f6f82910000)
    libsasl2.so.2 => /usr/lib/libsasl2.so.2 (0x00007f6f826f7000)
    libdb-4.8.so => /usr/lib/libdb-4.8.so (0x00007f6f8237c000)
    libnsl.so.1 => /lib/libnsl.so.1 (0x00007f6f82164000)
    libresolv.so.2 => /lib/libresolv.so.2 (0x00007f6f81f4e000)
    libc.so.6 => /lib/libc.so.6 (0x00007f6f81beb000)
    libdl.so.2 => /lib/libdl.so.2 (0x00007f6f819e7000)
    libz.so.1 => /usr/lib/libz.so.1 (0x00007f6f817d0000)
    libpthread.so.0 => /lib/libpthread.so.0 (0x00007f6f815b3000)
    /lib64/ld-linux-x86-64.so.2 (0x00007f6f83581000)
```

After following _Ansgar Wiechers_ instructions its finally working.

`postconf -n` contained the lines as it should. The certificate/key check via openssl did show that both files are valid.

So it indeed has been a permissions problem! Didn't know that chown'ing the /etc/ssl/\*/postfix.pem files to postfix:postfix is not enough for postfix to read the files.

## Solution for postfix certificate permissions

The content of `main.cf` does not necessarily represent your active Postfix configuration. Check the output of `postconf -n` for the following two parameters:

```
smtpd_recipient_restrictions = 
  permit_mynetworks, 
  permit_sasl_authenticated, 
  reject_unauth_destination
mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128
```

If `$mynetworks` is restricted to localhost and `$smtpd_recipient_restrictions` shows `permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination` as the first three restrictions, then you are not an open relay.

Verify that `/etc/ssl/private/postfix.pem` contains a valid key and `/etc/ssl/certs/postfix.pem` contains a valid certificate:

```
openssl rsa -in /etc/ssl/private/postfix.pem -check -noout
openssl x509 -in /etc/ssl/certs/postfix.pem -text -noout
```

You also need to check if Postfix can access the file. On my server, the permissions on `/etc/ssl/private` are

```
drwx--x---  2 root ssl-cert  4096 Aug 03 01:55 private/
```

Thus simply `chown`ing the key file won't do you any good, because the directory permissions prevent Postfix from accessing any file in it.

Try simplifying your setup. Put certificate and key into a single file:

```
cat /etc/ssl/*/postfix.pem > /etc/postfix/server.pem
chmod 640 /etc/postfix/server.pem
chown postfix:postfix /etc/postfix/server.pem
```

and change your `main.cf` like this:

```
smtpd_tls_cert_file = /etc/postfix/server.pem
smtpd_tls_key_file = $smtpd_tls_cert_file
```

Restart Postfix and see if the server can access the key.

## Reference

* https://serverfault.com/questions/433003/postfix-warning-cannot-get-rsa-private-key-from-file
