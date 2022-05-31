
# Approach to maintaining Linux Package State

## Additive/Incremental Approach

One common approach used to manage linux packages with ansible is to add the necessary linux packages by the respective role/play.

For this demonstration, it will be assumed that the linux package role performs a simple task to install linux packages using the [linux package module](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/package_module.html) as follows.

Using the following inventory example.

./inventory/linux.ini:
```ini

[linux]
linuxhost001
linuxhost002
linuxhost003
...
linuxhost999

[webserver]
linuxhost023
linuxhost044
linuxhost080
linuxhost088

[nameserver]
linuxhost053


```


