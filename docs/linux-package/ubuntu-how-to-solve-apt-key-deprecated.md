
# How to solve apt-key deprecated?

## Question

I'm using Ubuntu 20.10 and I'm trying to get the latest signature-key and when I do that I get these lines:

```
root@kubernetes-worker:/home/jonteyh# curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  2537  100  2537    0     0  14016      0 --:--:-- --:--:-- --:--:-- 14094
Warning: apt-key is deprecated. Manage keyring files in trusted.gpg.d instead (see apt-key(8)).
OK
```

I get a warning message here that `apt-key` is deprecated. How do I solve this?

Is there some way I should remove the file `trusted.gpg.d` or edit it?

## Solution

It looks like `apt-key` is deprecated from @Terrance. Read this link [https://www.linuxuprising.com/2021/01/apt-key-is-deprecated-how-to-add.html](https://www.linuxuprising.com/2021/01/apt-key-is-deprecated-how-to-add.html)

In that link it states that Debian will be ending `apt-key` as of April 2022. For now `apt-key` still works as shown in the output in the question where it stated `OK` which means that the key was imported.

In the future it is recommended to do the `signed-by` with the repositories that you are adding.

_All of this answer is from the link reworded._

First, download the key in question:

**For ASCII type keys do it in this form:**

```
wget -O- <https://example.com/key/repo-key.gpg> | gpg --dearmor | sudo tee /usr/share/keyrings/<myrepository>-archive-keyring.gpg
```

or

```
curl <https://example.com/key/repo-key.gpg> | gpg --dearmor > /usr/share/keyrings/<myrepository>-archive-keyring.gpg
```

**For non-ASCII type keys do it in this form:**

```
wget -O- <https://example.com/key/repo-key.gpg> | sudo tee /usr/share/keyrings/<myrepository-archive-keyring.gpg>
```

Or you can get your keys from a keyserver like so:

```
sudo gpg --no-default-keyring --keyring /usr/share/keyrings/<myrepository>-archive-keyring.gpg --keyserver <hkp://keyserver.ubuntu.com:80> --recv-keys <fingerprint>
```

All keys will be stored in `/usr/share/keyrings/` folder. You can use those keys when you add your repo with the `signed-by` option to your sources.list file:

```
deb [signed-by=/usr/share/keyrings/<myrepository>-archive-keyring.gpg] <https://repository.example.com/debian/ stable main>
```

Or you can add the `arch=amd64` in the same fashion:

```
deb [arch=amd64 signed-by=/usr/share/keyrings/<myrepository>-archive-keyring.gpg] <https://repository.example.com/debian/ stable main>
```

Also, using `curl WEBSITE | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/FILE.gpg` is better than `curl WEBSITE | sudo gpg --dearmour > /etc/apt/trusted.gpg.d/FILE.gpg`. I found that using > causes permission errors sometimes. 

Finally, confirm that the /etc/apt/trusted.gpg is correct format.

```shell
$ file /etc/apt/trusted.gpg
/etc/apt/trusted.gpg: OpenPGP Public Key Version 4, Created Thu Feb 28 05:33:17 2002, DSA (1024 bits); User ID; Signature; OpenPGP Certificate
```

If not Public Key Version 4, the solution is simple:

- erase the file (well, move it somewhere else for backup)
- re-add the **trusted** keys

If this is helpful give thanks to @Terrance

## Examples

### Add Docker gpg 

to keyring:
```shell
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker.gpg
```

add trusted key to apt repo configuration:
```shell
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu jammy stable" > /etc/apt/sources.list.d/docker.list
```


### Add Webmin gpg to keyring

```shell
curl -fsSL https://download.webmin.com/jcameron-key.asc | sudo gpg --dearmor -o /usr/share/keyrings/webmin.gpg
```

add trusted key to apt repo configuration:
```shell
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/webmin.gpg] https://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list
```

## Reference

- https://askubuntu.com/questions/1328806/how-to-solve-apt-key-deprecated
- https://unix.stackexchange.com/questions/583266/the-keys-in-the-keyring-etc-apt-trusted-gpg-are-ignored-as-the-file-has-an-un
- https://9to5answer.com/the-key-s-in-the-keyring-etc-apt-trusted-gpg-are-ignored-as-the-file-has-an-unsupported-filetype
- 