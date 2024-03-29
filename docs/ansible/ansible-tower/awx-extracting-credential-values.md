
# Extracting Credential Values

AWX stores a variety of secrets in the database that are either used for automation or are a result of automation. These secrets include:

-   all secret fields of all credential types (passwords, secret keys, authentication tokens, secret cloud credentials)
-   secret tokens and passwords for external services defined in AWX settings
-   "password" type survey fields entries

To encrypt secret fields, AWX uses AES in CBC mode with a 256-bit key for encryption, PKCS7 padding, and HMAC using SHA256 for authentication.

If necessary, credentials and encrypted settings can be extracted using the AWX shell:

```shell
$ ssh username@awxtower.example.int
$ sudo su
$ awx-manage shell_plus
>>> from awx.main.utils import decrypt_field
>>> cred = Credential.objects.get(name="my private key")
>>> print(decrypt_field(cred, "ssh_key_data"))
>>> cred = Credential.objects.get(name="AWX - Ansible Bitbucket")
>>> print(decrypt_field(cred, "private_key"))
-----BEGIN OPENSSH PRIVATE KEY-----
ZBBBBBtzc2gtZWQyNTUxOQAAACCFbVXWHUkG6kObWVqn2wzjnzoLW5m7nrnZFRB/y8XtBZ
y8XtBZZBBBBB/tzc2gtZWQyNTUxOQAAACCFbVXWHUkG6kObWVqn2wzjnzoLW5m7nrnZFRB
RRRECsYdBYUV+lJHQgbYfws+fGTtCAZFPD42SNBGQvsWtX74VtVdYdSQbqQ5tZWqfbDddf
OgtbmbueudkVEH/Lxe1EAAAAEUFuc2libGUgQml0YnVja2V0AQIDBA==
-----END OPENSSH PRIVATE KEY-----
>>>

```

## Reference

* https://en.euro-linux.com/docs/ansible-awx.php?p=credentials/extract_credentials
* 