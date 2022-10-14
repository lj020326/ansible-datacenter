
# Configuring postfix to relay email through Zoho Mail

![](./img/1_VStGP97_hZc0yr6_upQ7Tg.png)

This has taken me quite some time to figure out.

First of all you need the Zoho email address you want to use when relaying emails through Zoho.

It has to be one of the email addresses you configured by using Zoho control panel. In my case I created one to use only to relay email.

Let’s say that this email address is application@example.com. It will have a password as well, say applicationpassword.

When configuring postfix, you edit many files. Let’s see them one by one.

## Generic

The file /etc/postfix/generic maps local users to email addresses.

If email is sent to a local user such root, the address will be replaced with the one you specify.

In my case I have a single line like:

root application@example.com

After editing this file remember to use the command:

postmap generic

## Password

The file /etc/postfix/password contains the passwords postfix has to use to connect to the smtp server.

It’s content will be something like:

smtp.zoho.com:587 application@example.com:applicationpassword

You need to do postmap password.

## tls\_policy

The file /etc/postfix/tls\_policy contains the policies to be used when sending encrypted emails by using the TLS protocol, the one I’m using in this case.

The file contains just this line:

smtp.zoho.com:587 encrypt

By doing so we force the use of TLS every time we send an email.

You need to do postmap tls\_policy.

## smtp\_header\_checks

The file /etc/postfix/smtp\_header\_checks contains rules to be used to rewrite the headers of the emails about to be sent.

This is the most important file in our case.

It rewrites the sender so that it always matches our Zoho account, application@example.com.

No more ‘Relaying disallowed’ errors!

This is its content:

1.  /^From:.\*/ REPLACE From: LOCALHOST System <application@emanuelesantanche.com>;

No need for postmap here.

You need to install the package postfix-pcre otherwise no rewriting will happen.

1.  **apt-get install** postfix-pcre

## Main.cf

This is the main configuration file postfix uses.

Replace yourhostname with the hostname of your server, the one where postfix is installed on and that is sending emails through Zoho.

1.  \# TLS parameters
2.  smtp\_tls\_policy\_maps = hash:/etc/postfix/tls\_policy
3.  smtpd\_tls\_cert\_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
4.  smtpd\_tls\_key\_file=/etc/ssl/private/ssl-cert-snakeoil.key
5.  smtpd\_use\_tls=yes
6.  smtpd\_tls\_session\_cache\_database = btree:${data\_directory}/smtpd\_scache
7.  smtp\_tls\_session\_cache\_database = btree:${data\_directory}/smtp\_scache
8.  smtp\_header\_checks = pcre:/etc/postfix/smtp\_header\_checks
9.  myhostname = yourhostname
10.  alias\_maps = hash:/etc/aliases
11.  alias\_database = hash:/etc/aliases
12.  mydestination = yourhostname, localhost.com, localhost
13.  relayhost = smtp.zoho.com:587
14.  smtp\_sasl\_auth\_enable = yes
15.  smtp\_sasl\_password\_maps = hash:/etc/postfix/password
16.  smtp\_sasl\_security\_options =
17.  smtp\_generic\_maps = hash:/etc/postfix/generic

## master.cf

In the file /etc/postfix/master.cf I uncommented this line:

1. smtps inet n — — — — smtpd


## References

* https://medium.com/@esantanche/configuring-postfix-to-relay-email-through-zoho-mail-890b54d5c445
* https://www.reddit.com/r/selfhosted/comments/7tt4go/postfix_not_working_with_zoho_authentication/
* 