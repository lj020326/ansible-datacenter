
Ensures that mod awstats is installed (using apt) on apache.

### Role variables

List of default variables available in the inventory:

```YAML
awstats_enabled: yes                       # Enable module

# Package states: present or installed or latest
awstats_pkg_state: present
# Repository states: present or absent
#awstats_repository_state: present

apache_directory : "apache2"
apache_conf_path: "/etc/{{ apache_directory }}"
apache_log_path: "/var/log/{{ apache_directory }}"
#apache_log_path: "${APACHE_LOG_DIR}"

awstats_conf_path: "/etc/awstats"
#awstats_conf_file: "awstats.conf.local"
awstats_domain: "home.nabla.mobi"
awstats_conf_file: "awstats.{{ awstats_sitedomain }}.conf"
#awstats_logfile: "{{ apache_log_path }}/other_vhosts_access.log"
#awstats_logfile: "zip -cd {{ apache_log_path }}/other_vhosts_access.log.*.gz |"
awstats_logfile: "zip -cd {{ apache_log_path }}/other_vhosts_access.log.*.gz |"
awstats_sitedomain: "{{ awstats_domain }}"

apache_awstats_enabled: yes
apache_create_vhosts: yes

apache_vhosts_awstats:
  - {servername: "localhost", serveradmin: "alban.andrieu@nabla.mobi", documentroot: "/usr/lib/cgi-bin"}
```


### Detailed usage guide

Describe how to use in more detail...

### Testing
```shell
$ ansible-galaxy install bootstrap_awstats
$ vagrant up
```
