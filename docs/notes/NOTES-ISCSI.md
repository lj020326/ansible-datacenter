

iscsi playbook

	centos:
	https://github.com/OndrejHome/ansible.iscsiadm
	
	ubuntu:
	https://github.com/debops/ansible-iscsi

To setup/reset iscsi client config

```bash
run-remote.sh ansible-playbook -v site.yml --tags bootstrap-iscsi-clientt
```

ISCSI setup/testing notes/history:

```bash
    ## run from admin.example.int
    git clone ssh://git@gitea.admin.dettonville.int:2222/infra/ansible.iscsiadm.git
    cd ansible.iscsiadm/

  379  ansible-playbook -i hosts setup-datastores.yml
  380  sudo apt-get update
  381  apt-get install software-properties-common
  382  apt-add-repository ppa:ansible/ansible
  384  apt-get install ansible
  385  which ansible-playbook
  387  ansible-playbook -i hosts setup-datastores.yml
  388  which ansible-galaxy
  389  ansible-galaxy install git+https://github.com/OndrejHome/ansible.iscsiadm.git
  390  which ansible-galaxy
  394  ssh-keygen -R mail.example.int -f ~/.ssh/known_hosts
  410  ansible-playbook -i hosts setup-datastores.yml
  411  ansible-galaxy install debops.iscsi
  413  git clone ssh://git@gitea.admin.dettonville.int:2222/infra/ansible-iscsi.git
  414  cd ansible-iscsi/
  418  cd ansible-iscsi/
  425  ansible-galaxy install debops.iscsi
  428  ansible-playbook -i hosts setup-datastores.yml
  429  ansible -i hosts all -a "grep ^root: /etc/shadow"
  430  ansible -i hosts all -a "grep ^root: /etc/shadow" -b
  431  ansible -i hosts all -a "grep ^root: /etc/shadow" -b -K
  432  ansible-playbook -i hosts setup-datastores.yml -K
  433  iscsiadm -m node
  434  iscsiadm --mode session -P 3 | grep -i -e attached -e target
  444  ansible-playbook -i hosts set-sudoer.yml -K
  445  ansible-playbook -i hosts set-sudoer.yml -b -K
  446  ansible -i hosts all -a "grep ^root: /etc/shadow"  -b
  447  ansible -i hosts ubuntu.service_iscsi -a "grep ^root: /etc/shadow"  -b
  452  cd ansible-iscsi/
  463  ansible-playbook -i hosts-static setup-iscsi-initiators.yml -K
  466  ansible-playbook -i hosts-static.yml setup-iscsi-initiators.yml -K
  471  git clone https://github.com/lj020326/ansible-datacenter.git
  472  cd ansible-datacenter/
  478  iscsiadm --mode session -P 3 | grep -i -e attached -e target
  506  cd ansible-datacenter/
  511  history | grep ansible >> NOTES.md 


## from node01

  247  systemctl status cloudstack-management.service
  248  systemctl | grep running
  249  systemctl list-unit-files | grep enabled | sort
  250  systemctl list-unit-files --state=enabled
  251  ll /etc/iscsi/
  252  cat /etc/iscsi/initiatorname.iscsi
  253  ll /srv/data/
  254  ps -ef | grep python

  317  tail -50f /var/spool/mail/root
  318  systemctl status webmin
  319  systemctl restart webmin
  320  systemctl status webmin
  322  cd /var/log/
  323  la
  324  tail -30f messages
  325  ip a
  326  netstat -tanp | grep LISTEN
  327  systemctl status firewalld
  328  systemctl disable firewalld
  329  systemctl stop firewalld

  349  cd /var/log/cloudstack/management/
  350  ll
  351  la
  352  ll
  353  la
  354  systemctl status cloudstack
  355  ll /etc/systemd/system
  356  ll /usr/lib/systemd/system/cloudstack-management.service
  357  systemctl status cloudstack-management
  358  systemctl restart cloudstack-management
  359  systemctl status cloudstack-management
  360  la
  361  systemctl status cloudstack-management
  362  emacs /usr/lib/systemd/system/cloudstack-management.service
  363  la
  364  tail -50f management-server.log
  365  la
  366  cd /var/log
  367  la
  368  tail -50f messages
  369  pwd
  370  cd /var/log/cloudstack/management/
  371  la
  372  pushd .
  373  cd ../..
  374  la
  375  cd tomcat/
  376  la
  377  popd
  378  ll
  379  cd ..
  380  ll
  381  cd ..
  382  ll
  383  id cloud
  384  chown -R cloud.cloud cloudstack/
  385  cd cloudstack/management/
  386  ll
  387  la
  388  systemctl restart cloudstack-management
  389  systemctl status cloudstack-management
  390  exit
  391  fg
  392  la
  393  tail -50f management-server.log
  394  exit
  395  ps -ef | grep cloud
  396  systemctl status cloudstack-management
  397  cd /var/log/cloudstack/management/
  398  la
  399  tail -50f management-server.log
  400  ps -ef | grep cloudstack
  401  netstat -anlp | grep 1305
  402  telnet localhost 8080
  403  systemctl status cloudstack-management
  404  history

  303  sudo su
  304  ll /data
  305  mount -a
  306  sudo su
  307  ll /var/lib
  308  ll /var/lib/git/
  309  ll /var/lib | grep git
  310  ll /data/
  311  mount -a
  312  sudo su
  313  exit
  314  sudo su
  315  exit
  316  cd /data/media/other/books/calibre_library_jasmin/
  317  ll
  318  sudo su
  319  exit
  320  sudo su
  321  exit
  322  ll /data
  323  mount -a
  324  sudo mount -a
  325  ll /data
  326  exit
  327  sudo su
  328  exit
  329  cd /var/lib
  330  ll | grep git
  331  ll /data
  332  cd git
  333  ll
  341  ll /data
  342  mount -a
  358  sudo su
  362  crontab -l
  372  chkconfig iscsi on
  373  cd /etc/iscsi/
  374  ll
  375  cd nodes/
  376  ll
  381  cdrepos 
  385  cdrepos
  386  ll
  387  ll sudoWork/
  407  cdansible
  409  systemctl list-unit-files | grep enabled | sort 
  422  netstat -tanp | grep LISTEN
  423  replay.sh 
  435  cdansible
  436  emacs bootstrap.yml 
  437  ansible-playbook -v -i inventory/hosts.ini bootstrap.yml
  444  ansible -i inventory/hosts.ini all -m ping -b -v
  445  ansible-playbook -v -i inventory/hosts.ini bootstrap.yml
  446  gitpull
  447  nslookup 2406:da00:ff00::6b17:d1f5
  448  ansible-playbook -v -i inventory/hosts.ini bootstrap.yml
  449  gitpull
  450  ansible-playbook -v -i inventory/hosts.ini bootstrap.yml
  451  gitpull
  452  ansible-playbook -v -i inventory/hosts.ini bootstrap.yml
  453  emacs bootstrap.yml 
  454  cdansible
  455  gitpull
  456  gitpull
  457  ansible-playbook -v -i inventory/hosts.ini bootstrap.yml
  458  ansible-playbook -v -i inventory/hosts.ini site.yml 
  459  D
  460  gitpull
  461  exit
  462  cdansible
  463  gitpull
  464  ll /home/
  465  ssh deployer@node01.example.int
  466  ssh-keygen -f "/home/administrator/.ssh/known_hosts" -R 192.168.0.15
  467  ssh deployer@node01.example.int
  468   ssh-keygen -f "/home/administrator/.ssh/known_hosts" -R node01.example.int
  469  ssh deployer@node01.example.int
  470  ansible-playbook -v -i inventory/hosts.ini bootstrap.yml
  471  ansible-playbook -v -i inventory/hosts.ini 
  472  ansible-playbook -vvv -i inventory/hosts.ini site.yml
  473  ssh deployer@node01.example.int
  474  ansible -i inventory.cfg all -a "grep ^root: /etc/shadow"
  475  ansible -i inventory/hosts.ini all -a "grep ^root: /etc/shadow"
  476  ansible -i inventory/hosts.ini all -a "grep ^root: /etc/shadow" -v
  477  ansible -i inventory/hosts.ini all -a "grep ^root: /etc/shadow" -vvv
  478  ansible -i inventory/hosts.ini all -a "grep ^root: /etc/shadow" -b -vvv
  479  cat ~/.ansible.cfg 
  480  history | grep ansible | grep boot
  481  ansible-playbook -vvv -i inventory/hosts.ini site.yml
  482  gitpull
  483  ansible-playbook -vvv -i inventory/hosts.ini site.yml
  484  ssh deployer@node01.example.int
  485  gitpull
  486  ansible-playbook -vvv -i inventory/hosts.ini site.yml
  487  ansible-playbook -vvv -i inventory/hosts.ini site.yml
  488  ssh deployer@node01.example.int
  489  ssh deployer@node01.example.int
  490  ll /home/
  491  ansible-playbook -vvv -i inventory/hosts.ini site.yml
  492  ansible -i inventory/hosts.ini all -a "grep ^root: /etc/shadow" -vvv
  493  ansible -i inventory/hosts.ini all -a "grep ^root: /etc/shadow" -b -vvv
  494  ssh deployer@node01.example.int
  495  ssh deployer@node01.example.int
  496  gitpull
  497  ansible-playbook -vvv -i inventory/hosts.ini site.yml
  498  ssh deployer@node01.example.int
  499  gitpull
  500  ansible-playbook -vvv -i inventory/hosts.ini site.yml
  501  cdansible
  502  history | tail -200 >> NOTES.md 


```

