
# Akamai EAA vpn client notes

## Issues / Solutions

### VPN does not connect

This occurred for me when there was an existing sshfs process that was not stopped which upon stopping the vpn client caused the sshfs process to hang.
This in turn prevented the vpn client from reconnecting.

The solution was to kill the sshfs process and eaa vpn reconnect worked without issue.

A better, more automated solution, would be to create an EAA vpn reconnect script to make sure sshfs mounts are disconnected first before reconnecting vpn.

## Reference

- https://github.com/akamai/cli-eaa/blob/master/bin/akamai-eaa
- 