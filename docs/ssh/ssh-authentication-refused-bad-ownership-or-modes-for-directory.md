
# SSH Authentication Refused: Bad Ownership or Modes for Directory

If you get this error in your logs when trying to set up public key authenticated automatic logins, or while trying to SSH into your account, after setting up the public key the issue is related to permissions.

Tailing the system log (CentOS/RedHat: _/var/log/secure_, Debian/Ubuntu: _/var/log/auth.log_) on the target machine will be useful:

```
tail -f /var/log/secure
Dec 26 12:30:38 server sshd[3503454]: Authentication refused: bad ownership or modes for directory /home/user/.ssh
```

As you can see – _bad ownership or modes for directory /home/user/.ssh_.

SSH does not like it if your home or _~/.ssh_ directories have group write permissions. Your home directory should be writable only by you, ~/.ssh should be 700, and authorized_keys should be 600 :

```shell
chmod go-w /home/user
chmod 700 /home/user/.ssh
chmod 600 /home/user/.ssh/authorized_keys
```

So fixing permissions is the way to go and have this error resolved.

## Reference

- https://chemicloud.com/kb/article/ssh-authentication-refused-bad-ownership-or-modes-for-directory/
