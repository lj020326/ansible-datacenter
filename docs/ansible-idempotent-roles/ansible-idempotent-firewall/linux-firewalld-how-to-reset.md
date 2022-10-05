
# How to reset firewalld

There may be an occassion where you may simply want to reset the firewalld tables/chains/rules from the start.

In order to do so, delete the files containing the customized zone rules from `/etc/firewalld/zones`.

After that, reload `firewalld` with `firewall-cmd --complete-reload`, and it should start using the default settings. 

When you make changes to the zone rules, files will appear again in that directory.                                                                                                                                                                                       

As for `iptables`, you may reset all rules with `iptables -F`.

Rebooting works as well, unless you implemented some sort of persistency for iptables.

Beware that `firewalld` may be configured to use `iptables` as its backend, which means it will add or remove `iptables` rules itself, according to what you specified in its zone rules.                                                                                 
                                                                                                                                                                                                                                                                              
If using iptables and you trully want to delete everything:                                                                                                                                                                                                               
                                                                                                                                                                                                                                                                              
```                                                                                                                                                                                                                                                                       
rm -rf /etc/firewalld/zones                                                                                                                                                                                                                                               
## or                                                                                                                                                                                                                                                                     
rm -fr /usr/etc/firewalld/zones ## depending on your distro                                                                                                                                                                                                               
                                                                                                                                                                                                                                                                          
## AND                                                                                                                                                                                                                                                                    
iptables -X                                                                                                                                                                                                                                                               
iptables -F                                                                                                                                                                                                                                                               
iptables -Z                                                                                                                                                                                                                                                               
```                                                                                                                                                                                                                                                                       
                                                                                                                                                                                                                                                                              
After clearing out the settings then restart the service                                                                                                                                                                                                                  
                                                                                                                                                                                                                                                                              
```                                                                                                                                                                                                                                                                       
systemctl restart firewalld                                                                                                                                                                                                                                               
```                                                                                                                                                                                                                                                                       
                                                                                                                                                                                                                                                                              
and then you have a new set of rules and zones ;)                                                                                                                                                                                                                         


## Issues where resetting the firewalld may help

Example [issue](https://askubuntu.com/questions/1320012/firewalld-no-such-file-or-directory) that has occurred in the past and resetting the firewall has resolved:

```
internal:0:0-0: Error: No such file or directory                                                                                                                                                                                                                          
'python-nftables' failed: internal:0:0-0: Error: No such file or directory                                                                                                                                                                                                
```                                                                                                                                                                                                                                                                       
                                                                                                                                                                                                                                                                              
It is usually due to missing table or chain:                                                                                                                                                                                                                              
 
```output                                                                                                                                                                                                                                                                 
nft list tables                                                                                                                                                                                                                                                           
nft add table inet firewalld                                                                                                                                                                                                                                              
...                                                                                                                                                                                                                                                                       
```                                                                                                                                                                                                                                                                       
                                                                                                                                                                                                                                                                              
If still having issues, then reset the firewalld state the way mentioned in the prior section.

                                                                                                                                                                                                                                                                              
## Reference

* https://netfilter.org/projects/nftables/
* https://serverfault.com/questions/901220/reset-firewalld-rules-to-default
* https://firewalld.org/2019/09/libnftables-JSON
* https://unix.stackexchange.com/questions/537030/nftables-flush-delete-when-changing-or-creating-new-table
* https://www.theurbanpenguin.com/using-nftables-in-centos-8/
* https://wiki.nftables.org/wiki-nftables/index.php/Configuring_chains
* https://www.liquidweb.com/kb/how-to-install-nftables-in-ubuntu/
* https://firewalld.org/documentation/howto/add-a-service.html
* https://github.com/firewalld/firewalld/issues/673
                                                                                                                                                                                                                                                                              

