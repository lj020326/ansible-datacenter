
# Notes for updating DNS resolver settings on MAC OS

## Adding dns entries
Add DNS entry(s) to /etc/resolver/

For example, to add a DNS entry for the domain example.int

Create file called example.int in /etc/resolver/

```ini
domain example.int
port 5300
nameserver 10.100.100.21.5300

```

## Configure mDNSResponder to allow addition of dns entries

Unload the system default config:

```
sudo launchctl unload -w /System/Library/LaunchDaemons/mDNSResponder.plist
```

Copy that file to /Library/LaunchDaemons/mDNSResponder.plist, modify it as you like, then make sure its ownership and permissions are correct (owned by root, not writable by anybody but owner). Then:

```
sudo launchctl load -w /Library/LaunchDaemons/mDNSResponder.plist
```

In other words, if you want to override the default, you have to tell launchd not to load it and to load yours instead.


## Verifying entries

```shell
sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder
sudo networksetup -listallnetworkservices
scutil --dns

## ref: https://superuser.com/questions/1400250/how-to-query-macos-dns-resolver-from-terminal
scutil -W -r mail.example.int
dscacheutil -q host -a name mail.example.int
dns-sd -q mail.example.int
dns-sd -G v4v6 mail.example.int

dig @10.100.100.21 -p 5300 mail.example.int
dig @localhost -p 5300 mail.example.int

## https://apple.stackexchange.com/questions/382310/how-can-i-get-macos-to-use-the-correct-search-domain-from-dhcp
ipconfig getpacket en0

```

## References

* https://superuser.com/questions/1400250/how-to-query-macos-dns-resolver-from-terminal
* https://developer.apple.com/forums/thread/17944
* https://verynomagic.com/2015/07/multiple-dns-resolvers-in-os-x.html
* https://vninja.net/2020/02/06/macos-custom-dns-resolvers/
* https://apple.stackexchange.com/questions/382310/how-can-i-get-macos-to-use-the-correct-search-domain-from-dhcp
* https://discussions.apple.com/thread/4602419
* https://www.manpagez.com/man/5/resolver/
* https://www.lifewire.com/flush-dns-cache-on-a-mac-5209298
* https://apple.stackexchange.com/questions/366914/using-scutil-to-set-dns-for-specific-domains
* https://support.apple.com/guide/remote-desktop/about-networksetup-apdd0c5a2d5/mac
* https://apple.stackexchange.com/questions/74639/do-etc-resolver-files-work-in-mountain-lion-for-dns-resolution
* https://cleanbrowsing.org/guides/manually-change-dns-on-a-mac-terminal/
* https://vrandombites.co.uk/macos/macos-multiple-resolver-configs/
* https://rakhesh.com/powershell/vpn-client-over-riding-dns-on-macos/
