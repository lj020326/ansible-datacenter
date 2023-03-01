# bootstrap_linux_systemd

Allow to define systemd:
* [journald.conf](https://www.freedesktop.org/software/systemd/man/journald.conf.html);
* [tmpfiles](https://www.freedesktop.org/software/systemd/man/tmpfiles.d.html);
* set timezone via [systemd-timedatectl](https://www.freedesktop.org/software/systemd/man/timedatectl.html);
* [timesyncd](https://www.freedesktop.org/software/systemd/man/systemd-timesyncd.service.html)
support;
* set console settings via [vconsole.conf](https://www.freedesktop.org/software/systemd/man/vconsole.conf.html)
* [networkd](https://www.freedesktop.org/software/systemd/man/systemd-networkd.html)
support;
* [resolved](https://www.freedesktop.org/software/systemd/man/systemd-resolved.html)
support;
* [modules-load](https://www.freedesktop.org/software/systemd/man/modules-load.d.html)
support;

## Requirements

* Ansible 3.0.0+;

## Extra

* journald options is not validate and pass as-is. For all possible options
consult `man journald.conf(5)`;
* tmpfiles are validated by real time execution (online apply settings);
* udev rules syntax validated via external script;
* networkd address declaration may be simpe and complex:
  * simple: is just a one or many addresses and gateway:

  ```yaml
  systemd_networkd:
  - interfaces:
    - interface: 'eth0'
      type: 'ether'
      physaddr: '18:66:da:e6:be:88'
      address: '10.10.10.2/24'
      gateway: '10.10.10.1'
  ```

  * complex: you can declare more `ip` options:

  ```yaml
  systemd_networkd:
  - interfaces:
    - interface: 'eth0'
      type: 'ether'
      physaddr: '18:66:da:e6:be:88'
      ip:
      - address: '10.10.10.2/24'
        gateway: '10.10.10.1'
        preferred_lifetime: 'forever'
        scope: 'global'
  ```
* networkd can use shell-style globs for match devices. For example if your host
just need simple dhcp on ethernet interfaces you can define simple
'match any eth iface' like this:

  ```yaml
    ---
    systemd_networkd:
    - interfaces:
      - interface: 'ethernet'
        type: 'ether'
        dhcp: 'yes'
        match_override:
        - match_entry: 'Name'
          match_value: 'e*' # <--- any linux `ens*/enp*/eth*` device
  ```

## Example configuration

```yaml
---
# systemd-tmpfiles uses the configuration files from the above directories to
# describe the creation, cleaning and removal of volatile and temporary files
# and directories which usually reside in directories such as '/run' or '/tmp'.
# Volatile and temporary files and directories are those located in '/run'
# (and its alias '/var/run'), '/tmp', '/var/tmp', the API file systems such
# as '/sys' or '/proc', as well as some other directories below '/var'.
systemd_tmpfiles:
# This option allow to delete '/etc/tmpfiles.d/*.conf' files before deploy.
- drop_exists: 'true'
  create:
  - file_name: 'set_sda_scheduler'
    path: '/sys/block/sda/queue/scheduler'
    type: 'w'
    arg: 'noop'
  - file_name: 'example1'
    path: '/tmp/example1'
    type: 'd'
    mode: '0755'
    uid: 'root'
    gid: 'root'
    age: '10d'
  clean:
  - file_name: 'example2'
    path: '/tmp/example2'
    type: 'd'
    mode: '0755'
    uid: 'root'
    gid: 'root'
    age: '1m'
  remove:
  - file_name: 'example3'
    path: '/tmp/example3'
    type: 'r'

systemd_modules_load:
# This option allow to delete '/etc/modules-load.d/*.conf' files before deploy.
- drop_exists: 'true'
  modules_load:
  - file_name: '99-ipvs'
    modules:
    - 'ip_vs'
    - 'virtio_net'
  - file_name: 'facebook'
    modules:
    - 'tls'

systemd_timesyncd:
# Enable systemd-timesyncd or not.
- enable: 'true'
# Restart systemd-timesyncd after deploy or not.
  restart: 'true'
# Set this timezone.
  timezone: 'Asia/Yekaterinburg'
  timesyncd:
# A list of NTP server host names or IP addresses. During runtime this list is
# combined with any per-interface NTP servers acquired from systemd-networkd.
# systemd-timesyncd will contact all configured system or per-interface servers
# in turn until one is found that responds. When the empty string is assigned,
# the list of NTP servers is reset, and all assignments prior to this one will
# have no effect. This setting defaults to an empty list.
  - ntp:
    - '0.ru.pool.ntp.org'
    - '1.ru.pool.ntp.org'
# A list of NTP server host names or IP addresses to be used as the fallback
# NTP servers. Any per-interface NTP servers obtained from systemd-networkd
# take precedence over this setting, as do any servers set via 'ntp' above.
# This setting is hence only used if no other NTP server information is known.
# When the empty string is assigned, the list of NTP servers is reset, and all
# assignments prior to this one will have no effect. If this option is not
# given, a compiled-in list of NTP servers is used instead.
    fallback: ''
# Maximum acceptable root distance. Takes a time value (in seconds). Defaults
# to 5 seconds.
    root_distance_max_sec: '5'
# The minimum and maximum poll intervals for NTP messages. Each setting takes a
# time value (in seconds). PollIntervalMinSec= must not be smaller than 16
# seconds. 'poll_interval_max_sec' must be larger than 'poll_interval_min_sec'.
# 'poll_interval_min_sec' defaults to 32 seconds, and 'poll_interval_max_sec'
# defaults to 2048 seconds.
    poll_interval_min_sec: '32'
    poll_interval_max_sec: '2048'

systemd_journald_settings:
  Storage: 'persistent'
  SystemMaxUse: '10G'

systemd_udev:
- file_name: '10-persistent-net'
  rules:
  - 'ACTION=="add", SUBSYSTEM=="net", DRIVERS=="?*", ATTR{type}=="32", ATTR{address}=="?*00:02:c9:03:00:31:78:f2", NAME="mlx4_ib3"'
  - 'SUBSYSTEM=="net", ATTR{address}=="18:66:da:e6:be:88", NAME="gig0"'
- file_name: '90-otcash'
  rules:
  - 'ATTRS{idVendor}=="079b", ATTRS{idProduct}=="0028", GROUP="100", MODE="0660", SYMLINK+="ingenico"'
  - 'ATTRS{idVendor}=="abcd", ATTRS{idProduct}=="1980", GROUP="100", MODE="0660", SYMLINK+="rr02"'
  - 'ATTRS{idVendor}=="067b", ATTRS{idProduct}=="2303", GROUP="100", MODE="0660", SYMLINK+="m200"'
  - 'ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", GROUP="100", MODE="0660", SYMLINK+="m200"'

# The '/etc/vconsole.conf' file configures the virtual console, i.e. keyboard
# mapping and console font. It is applied at boot by udev using
# '90-vconsole.rules' file. You can safely mask this file if you want to avoid
# this kind of initialization.
systemd_vconsole:
# Configures the key mapping table for the keyboard.
- keymap: 'ru'
# The KEYMAP_TOGGLE= can be used to configure a second toggle keymap and is by
# default unset.
  keymap_toggle: 'dvorak'
# Configures the console font.
  font: 'cyr-sun16'
# Configures the console map.
  font_map: ''
# Configures the unicode font map.
  font_unimap: ''

systemd_resolved:
# Enable systemd-resolved or not.
- enable: 'true'
# Restart systemd-resolved after deploy or not.
  restart: 'true'
# '/run/systemd/resolve/resolv.conf' should not be used directly by
# applications, but only through a symlink from '/etc/resolv.conf'. If this
# mode of operation is used local clients that bypass any local DNS API will
# also bypass systemd-resolved and will talk directly to the known DNS servers.
  make_link: 'true'
  resolved:
# A list of IPv4 and IPv6 addresses to use as system DNS servers. DNS requests
# are sent to one of the listed DNS servers in parallel to suitable per-link
# DNS servers acquired from systemd-networkd.service or set at runtime by
# external applications. For compatibility reasons, if this setting is not
# specified, the DNS servers listed in '/etc/resolv.conf' are used instead, if
# that file exists and any servers are configured in it. This setting defaults
# to the empty list.
  - dns:
    - '8.8.8.8'
    - '1.1.1.1'
# A list of IPv4 and IPv6 addresses to use as the fallback DNS servers. Any
# per-link DNS servers obtained from systemd-networkd.service take precedence
# over this setting, as do any servers set via 'dns' above or /etc/resolv.conf.
# This setting is hence only used if no other DNS server information is known.
# If this option is not given, a compiled-in list of DNS servers is used
# instead.
    fallback_dns: '8.8.4.4'
# A list of domains. These domains are used as search suffixes when resolving
# single-label host names (domain names which contain no dot), in order to
# qualify them into fully-qualified domain names (FQDNs). Search domains are
# strictly processed in the order they are specified, until the name with the
# suffix appended is found. For compatibility reasons, if this setting is not
# specified, the search domains listed in '/etc/resolv.conf' are used instead,
# if that file exists and any domains are configured in it. This setting
# defaults to the empty list.
    domains: ''
# Takes a boolean argument or 'resolve'. Controls Link-Local Multicast Name
# Resolution support (RFC 4794) on the local host. If true, enables full LLMNR
# responder and resolver support. If false, disables both. If set to 'resolve',
# only resolution support is enabled, but responding is disabled. Note that
# systemd-networkd.service also maintains per-link LLMNR settings. LLMNR will be
# enabled on a link only if the per-link and the global setting is on.
    llmnr: ''
# Takes a boolean argument or 'resolve'. Controls Multicast DNS support
# (RFC 6762) on the local host. If true, enables full Multicast DNS responder
# and resolver support. If false, disables both. If set to 'resolve', only
# resolution support is enabled, but responding is disabled. Note that
# systemd-networkd.service also maintains per-link Multicast DNS settings.
# Multicast DNS will be enabled on a link only if the per-link and the global
# setting is on.
    multicast_dns: ''
# Takes a boolean argument or 'allow-downgrade'. If true all DNS lookups are
# DNSSEC-validated locally (excluding LLMNR and Multicast DNS). If the response
# to a lookup request is detected to be invalid a lookup failure is returned to
# applications. Note that this mode requires a DNS server that supports DNSSEC.
# If the DNS server does not properly support DNSSEC all validations will fail.
# If set to "allow-downgrade" DNSSEC validation is attempted, but if the server
# does not support DNSSEC properly, DNSSEC mode is automatically disabled. Note
# that this mode makes DNSSEC validation vulnerable to "downgrade" attacks,
# where an attacker might be able to trigger a downgrade to non-DNSSEC mode by
# synthesizing a DNS response that suggests DNSSEC was not supported. If set to
# false, DNS lookups are not DNSSEC validated. Note that DNSSEC validation
# requires retrieval of additional DNS data, and thus results in a small DNS
# look-up time penalty. DNSSEC requires knowledge of "trust anchors" to prove
# data integrity. The trust anchor for the Internet root domain is built into
# the resolver, additional trust anchors may be defined with
# dnssec-trust-anchors.d. Trust anchors may change at regular intervals, and
# old trust anchors may be revoked. In such a case DNSSEC validation is not
# possible until new trust anchors are configured locally or the resolver
# software package is updated with the new root trust anchor. In effect, when
# the built-in trust anchor is revoked and 'dnssec' is true, all further
# lookups will fail, as it cannot be proved anymore whether lookups are
# correctly signed, or validly unsigned. If 'dnssec' is set to
# 'allow-downgrade' the resolver will automatically turn off DNSSEC validation
# in such a case. Client programs looking up DNS data will be informed whether
# lookups could be verified using DNSSEC, or whether the returned data could
# not be verified (either because the data was found unsigned in the DNS, or
# the DNS server did not support DNSSEC or no appropriate trust anchors were
# known). In the latter case it is assumed that client programs employ a
# secondary scheme to validate the returned DNS data, should this be required.
# It is recommended to set 'dnssec' to true on systems where it is known that
# the DNS server supports DNSSEC correctly, and where software or trust anchor
# updates happen regularly. On other systems it is recommended to set 'dnssec'
# to 'allow-downgrade'. In addition to this global 'dnssec' setting
# systemd-networkd.service also maintains per-link 'dnssec' settings. For
# system DNS servers (see above), only the global 'dnssec' setting is in effect.
# For per-link DNS servers the per-link setting is in effect, unless it is
# unset in which case the global setting is used instead. Site-private DNS zones
# generally conflict with 'dnssec' operation, unless a negative (if the private
# zone is not signed) or positive (if the private zone is signed) trust anchor
# is configured for them. If 'allow-downgrade' mode is selected, it is
# attempted to detect site-private DNS zones using top-level domains (TLDs)
# that are not known by the DNS root server. This logic does not work in all
# private zone setups. Defaults to off.
    dnssec: 'false'
# Takes a boolean argument or 'opportunistic'. If true all connections to the
# server will be encrypted. Note that this mode requires a DNS server that
# supports DNS-over-TLS and has a valid certificate for it's IP. If the DNS
# server does not support DNS-over-TLS all DNS requests will fail. When set to
# 'opportunistic' DNS request are attempted to send encrypted with DNS-over-TLS.
# If the DNS server does not support TLS, DNS-over-TLS is disabled. Note that
# this mode makes DNS-over-TLS vulnerable to "downgrade" attacks, where an
# attacker might be able to trigger a downgrade to non-encrypted mode by
# synthesizing a response that suggests DNS-over-TLS was not supported. If set
# to 'false', DNS lookups are send over UDP. Note that DNS-over-TLS requires
# additional data to be send for setting up an encrypted connection, and thus
# results in a small DNS look-up time penalty. Note as the resolver is not
# capable of authenticating the server, it is vulnerable for
# "man-in-the-middle" attacks. Default is 'false'.
    dns_over_tls: 'false'
# Takes a boolean argument. If 'yes' (the default), resolving a domain name
# which already got queried earlier will return the previous result as long as
# it is still valid, and thus does not result in a new network request. Be
# aware that turning off caching comes at a performance penalty, which is
# particularly high when DNSSEC is used. Note that caching is turned off
# implicitly if the configured DNS server is on a host-local IP address (such
# as 127.0.0.1 or ::1), in order to avoid duplicate local caching.
    cache: 'true'
# Takes a boolean argument or one of 'udp' and 'tcp'. If 'udp' (the default), a
# DNS stub resolver will listen for UDP requests on address 127.0.0.53 port 53.
# If 'tcp', the stub will listen for TCP requests on the same address and port.
# If 'yes', the stub listens for both UDP and TCP requests. If 'no', the stub
# listener is disabled. Note that the DNS stub listener is turned off
# implicitly when its listening address and port are already in use.
    dns_stub_listener: 'udp'
# Takes a boolean argument. If 'true' (the default), the DNS stub resolver will
# read '/etc/hosts', and try to resolve hosts or address by using the entries
# in the file before sending query to DNS servers.
    read_etc_hosts: 'true'

systemd_networkd:
# Drop exists "\.(network|netdev|link)" profiles or not.
- drop_exists: 'true'
# Enable systemd-networkd or not.
  enable: 'true'
# Restart systemd-networkd after deploy or not.
  restart: 'true'
  networkd:
  - network:
# If set to 'yes', then systemd-networkd measures the traffic of each
# interface, and networkctl status INTERFACE shows the measured speed.
# Defaults to 'no'.
    - speed_meter: 'no'
# Specifies the time interval to calculate the traffic speed of each interface.
# If speed_meter is 'no', the value is ignored. Defaults to 10sec.
      speed_meter_interval: '10'
# When 'yes, systemd-networkd will remove rules that are not configured (except
# for rules with protocol "kernel"). When 'no', it will not remove any foreign
# rules. Defaults to yes.
      manage_foreign_routing_policy_rules: 'yes'
# When 'yes', systemd-networkd will remove routes that are not configured in
# .network files (except for routes with protocol 'kernel', 'dhcp' when
# 'keep_configuration' is 'true' or 'dhcp', and 'static' when
# 'keep_configuration' is 'true' or 'static'). When 'no', it will not remove
# any foreign routes, keeping them even if they are not configured in a .network
# file. Defaults to 'yes'.
      manage_foreign_routes: 'yes'
# This section configures the DHCP Unique Identifier (DUID) value used by DHCP
# protocol. DHCPv6 client protocol sends the DHCP Unique Identifier and the
# interface Identity Association Identifier (IAID) to a DHCP server when
# acquiring a dynamic IPv6 address.
    dhcp:
# Specifies how the DUID should be generated. The following values are
# understood:
# 'vendor' - the DUID value will be generated using "43793" as the vendor
# identifier (systemd) and hashed contents of machine-id. This is the default.
# 'uuid' - product UUID is used as a DUID value. If a system does not have valid
# product UUID, then an application-specific machine-id is used as a DUID value.
# 'link-layer-time', 'link-layer' - if is specified, then the MAC address of
# the interface is used as a DUID value. The value 'link-layer-time' can take
# value like '2018-01-23 12:34:56 UTC'. The default time value is
# "2000-01-01 00:00:00 UTC".
    - duid_type: 'vendor'
      value: '2000-01-01 00:00:00 UTC'
# Specifies the DHCP DUID value as a single newline-terminated, hexadecimal
# string, with each byte separated by ":". The DUID that is sent is composed of
# the DUID type specified by 'duid_type' and the value configured here. The
# DUID value specified here overrides the DUID that systemd-networkd.service
# generates from the machine ID. The configured DHCP DUID should conform to the
# specification in RFC 3315, RFC 6355. This specifies a 14 byte DUID, with the
# type DUID-EN ("00:02"), enterprise number 43793 ("00:00:ab:11"), and
# identifier value "f9:2a:c2:77:29:f9:5c:00".
      duid_raw_data: '00:00:ab:11:f9:2a:c2:77:29:f9:5c:00'
  interfaces:
  - interface: 'ethernet'
    type: 'ether'
    lldp_receive: 'true'
    lldp_transmit: 'true'
    dhcp: 'ipv4'
    match_override:
    - match_entry: 'Name'
      match_value: 'e*'
  - interface: 'vrf7'
    type: 'vrf'
    table: '7'
  - interface: 'vrf8'
    type: 'vrf'
    table: '8'
  - interface: 'Tunnel0'
    type: 'gre'
# A link name or a list of link names. When set, controls the behavior of the
# current link. When all links in the list are in an operational down state,
# the current link is brought down. When at least one link has carrier, the
# current interface is brought up.
    bind_carrier:
    - 'po1'
    address: '10.17.17.2/24'
# If set to 'true', the ARP (low-level Address Resolution Protocol) for this
# interface is enabled. When unset, the kernel's default will be used.
# For example, disabling ARP is useful when creating multiple MACVLAN or VLAN
# virtual interfaces atop a single lower-level physical interface, which will
# then only serve as a link/"bridge" device aggregating traffic to the same
# physical link and not participate in the network otherwise.
    arp: 'true'
# If set to 'true', the multicast flag on the device is enabled.
    multicast: 'true'
# Takes a boolean. If set to 'true', the driver retrieves all multicast packets
# from the network. This happens when multicast routing is enabled.
    all_multicast: 'true'
# A boolean. When 'yes', no attempts are made to bring up or configure matching
# links, equivalent to when there are no matching network files. Defaults to
# 'no'. This is useful for preventing later matching network files from
# interfering with certain interfaces that are fully controlled by other
# applications.
    unmanaged: 'false'
# A boolean. When 'true' (the default), the network is deemed required when
# determining whether the system is online when running
# "systemd-networkd-wait-online". When 'false', the network is ignored when
# checking for online state. The network will be brought up normally in all
# cases, but in the event that there is no address being assigned by DHCP or the
# cable is not plugged in, the link will simply remain offline and be skipped
# automatically by "systemd-networkd-wait-online" if
# "required_for_online: 'true'".
    required_for_online: 'false'
# A static local address for tunneled packets. It must be an address on another
# interface of this host.
    tun_local: '5.128.220.150'
# The remote endpoint of the tunnel.
    tun_remote: '5.128.220.250'
# The Type Of Service byte value for a tunnel interface.
    tun_tos: ''
# A fixed Time To Live on tunneled packets. Is a number in the range 1–255. 0
# is a special value meaning that packets inherit the TTL value. The default
# value for IPv4 tunnels is: inherit. The default value for IPv6 tunnels is 64.
    tun_ttl: '255'
# A boolean. When true, enables Path MTU Discovery on the tunnel.
    discover_path_mtu: ''
# Configures the 20-bit flow label (RFC 6437) field in the IPv6 header
# (RFC 2460), which is used by a node to label packets of a flow. It is only
# used for IPv6 tunnels. A flow label of zero is used to indicate packets that
# have not been labeled. It can be configured to a value in the range 0–0xFFFFF,
# or be set to 'inherit', in which case the original flowlabel is used.
    ipv6_flow_label: ''
# A boolean. When true, the Differentiated Service Code Point (DSCP) field will
# be copied to the inner header from outer header during the decapsulation of
# an IPv6 tunnel packet. DSCP is a field in an IP packet that enables different
# levels of service to be assigned to network traffic. Defaults to 'no'.
    copy_dscp: 'false'
# The Tunnel Encapsulation Limit option specifies how many additional levels of
# encapsulation are permitted to be prepended to the packet. For example, a
# Tunnel Encapsulation Limit option containing a limit value of zero means that
# a packet carrying that option may not enter another tunnel before exiting the
# current tunnel (RFC 2473). The valid range is 0–255 and 'none'. Defaults to 4.
    encapsulation_limit: '4'
# Parameter specifies the same key to use in both directions ("input_key" and
# "output_key"). The key is either a number or an IPv4 address-like dotted
# quad. It is used as mark-configured SAD/SPD entry as part of the lookup key
# (both in data and control path) in ip xfrm (framework used to implement
# IPsec protocol). See ip-xfrm — transform configuration for details. It is
# only used for VTI/VTI6 tunnels.
    key: ''
# Parameter specifies the key to use for input. The format is same as 'key'. It
# is only used for VTI/VTI6 tunnels.
    input_key: ''
# Parameter specifies the key to use for output. The format is same as 'key'. It
# is only used for VTI/VTI6 tunnels.
    output_key: ''
# An "ip6tnl" tunnel can be in one of three modes 'ip6ip6' for IPv6 over IPv6,
# 'ipip6' for IPv4 over IPv6 or 'any' for either.
    mode: ''
# A boolean. When true tunnel does not require .network file. Created as
# "tunnel@NONE". Defaults to 'false'.
    independent: 'true'
# Takes a boolean. If set to 'true', the loopback interface 'lo' is used as the
# underlying device of the tunnel interface. Default is 'false'.
    assign_to_loopback: 'false'
# A boolean. When true allows tunnel traffic on ip6tnl devices where the remote
# endpoint is a local host address. Defaults to unset.
    allow_local_remote: ''
#
# tuntap special settings:
#
# Takes a boolean argument. Configures whether all packets are queued at the
# device (enabled), or a fixed number of packets are queued at the device and
# the rest at the "qdisc". Defaults to 'false'.
    one_queue: 'false'
# Takes a boolean argument. Configures whether to use multiple file descriptors
# (queues) to parallelize packets sending and receiving. Defaults to 'no'.
    multi_queue: 'false'
# Takes a boolean argument. Configures whether packets should be prepended with
# four extra bytes (two flag bytes and two protocol bytes). If disabled, it
# indicates that the packets will be pure IP packets. Defaults to "no".
    packet_info: 'false'
# Takes a boolean argument. Configures IFF_VNET_HDR flag for a tap device. It
# allows sending and receiving larger Generic Segmentation Offload (GSO)
# packets. This may increase throughput significantly. Defaults to 'no'.
    vnet_header: 'false'
# User to grant access to the /dev/net/tun device.
    user: ''
# Group to grant access to the /dev/net/tun device.
    group: ''
  - interface: 'dummy0'
    type: 'dummy'
    bridge:
# The name of bridge.
    - name: 'br1'
      bridge_vlan:
# The VLAN ID allowed on the port. This can be either a single ID or a range.
# VLAN IDs are valid from 1 to 4094.
      - vlan: '1-32'
# The VLAN ID specified here will be used to untag frames on egress.
# Configuring 'egress_untagged' implicates the use of 'vlan' above and will
# enable the VLAN ID for ingress as well. This can be either a single ID or a
# range.
        egress_untagged: '42'
# The Port VLAN ID specified here is assigned to all untagged frames at ingress.
# 'pvid' can be used only once. Configuring 'pvid' implicates the use of 'vlan'
# above and will enable the VLAN ID for ingress as well.
        pvid: '42'
      - vlan: '100-200'
      - egress_untagged: '300-400'
  - interface: 'dummy1'
    type: 'dummy'
    bridge:
    - name: 'br1'
# A boolean. Controls whether the bridge should flood traffic for which an FDB
# entry is missing and the destination is unknown through this port. Defaults
# to on.
      unicast_flood: 'true'
# A boolean. Configures whether traffic may be sent back out of the port on
# which it was received. By default, this flag is 'false', and the bridge will
# not forward traffic back out of the receiving port.
      hair_pin: 'false'
# A boolean. Configures whether STP Bridge Protocol Data Units will be
# processed by the bridge port. Defaults to yes.
      use_bpdu: 'yes'
# A boolean. This flag allows the bridge to immediately stop multicast traffic
# on a port that receives an IGMP Leave message. It is only used with IGMP
# snooping if enabled on the bridge. Defaults to off.
      fast_leave: 'off'
# A boolean. Configures whether a given port is allowed to become a root port.
# Only used when STP is enabled on the bridge. Defaults to on.
      allow_port_to_be_root: 'true'
# Sets the "cost" of sending packets of this interface. Each port in a bridge
# may have a different speed and the cost is used to decide which link to use.
# Faster interfaces should have lower costs. It is an integer value between
# 1 and 65535.
      cost: ''
# Sets the "priority" of sending packets on this interface. Each port in a
# bridge may have a different priority which is used to decide which link to
# use. Lower value means higher priority. It is an integer value between
# 0 to 63. Networkd does not set any default meaning the kernel default value
# of 32 is used.
      priority: ''
  - interface: 'dummy2'
    type: 'dummy'
    macvlans:
    - name: 'macvlan2'
      mode: 'bridge'
  - interface: 'br1'
    type: 'bridge'
    address: '10.18.18.2/24'
    bridging_opts:
# Specifies the number of seconds between two hello packets sent out by the
# root bridge and the designated bridges. Hello packets are used to communicate
# information about the topology throughout the entire bridged local area
# network.
    - hello_time: ''
# Specifies the number of seconds of maximum message age. If the last seen
# (received) hello packet is more than this number of seconds old, the bridge
# in question will start the takeover procedure in attempt to become the Root
# Bridge itself.
      max_age: ''
# Specifies the number of seconds spent in each of the Listening and Learning
# states before the Forwarding state is entered.
      forward_delay: ''
# This specifies the number of seconds a MAC Address will be kept in the
# forwarding database after having a packet received from this MAC Address.
      ageing_time: ''
# The priority of the bridge. An integer between 0 and 65535. A lower value
# means higher priority. The bridge having the lowest priority will be elected
# as root bridge.
      prio: ''
# A 16-bit bitmask represented as an integer which allows forwarding of link
# local frames with 802.1D reserved addresses (01:80:C2:00:00:0X). A logical
# AND is performed between the specified bitmask and the exponentiation of 2^X,
# the lower nibble of the last octet of the MAC address. For example, a value
# of 8 would allow forwarding of frames addressed to 01:80:C2:00:00:03
# (802.1X PAE).
      group_forward_mask: ''
# This specifies the default port VLAN ID of a newly attached bridge port. Set
# this to an integer in the range 1–4094 or 'none' to disable the PVID.
      default_pvid: ''
# A boolean. This setting controls the IFLA_BR_MCAST_QUERIER option in the
# kernel. If enabled, the kernel will send general ICMP queries from a zero
# source address. This feature should allow faster convergence on startup, but
# it causes some multicast-aware switches to misbehave and disrupt forwarding
# of multicast packets. When unset, the kernel's default setting applies.
      multicast_querier: ''
# A boolean. This setting controls the IFLA_BR_MCAST_SNOOPING option in the
# kernel. If enabled, IGMP snooping monitors the Internet Group Management
# Protocol (IGMP) traffic between hosts and multicast routers. When unset, the
# kernel's default setting applies.
      multicast_snooping: ''
# A boolean. This setting controls the IFLA_BR_VLAN_FILTERING option in the
# kernel. If enabled, the bridge will be started in VLAN-filtering mode. When
# unset, the kernel's default setting applies.
      vlan_filtering: 'true'
# A boolean. This enables the bridge's Spanning Tree Protocol (STP). When unset,
# the kernel's default setting applies.
      stp: 'false'
  - interface: 'ten0'
    type: 'ether'
# Hardware persistent MAC address. Used to match this interface.
    physaddr: '3c:fd:fe:aa:5e:f8'
    bond: 'po1'
# A list of policies by which the interface's alternative names should be set.
# Each of the policies may fail, and all successful policies are used. The
# available policies are 'database', 'onboard', 'slot', 'path', and 'mac'. If
# the kernel does not support the alternative names, then this setting will be
# ignored.
    altname_policy: ''
# The alternative interface name to use. If the kernel does not support the
# alternative names, then this setting will be ignored.
    altname: 'tengigabitethernet0'
# The speed to set for the device, the value is rounded down to the nearest
# Mbps. The usual suffixes K, M, G, are supported and are understood to the base
# of 1000.
# Controls support for Ethernet LLDP packet reception. LLDP is a link-layer
# protocol commonly implemented on professional routers and bridges which
# announces which physical port a system is connected to, as well as other
# related data. Accepts a boolean or the special value 'routers-only'.
# When 'true', incoming LLDP packets are accepted and a database of all LLDP
# neighbors maintained. If 'routers-only' is set only LLDP data of various
# types of routers is collected and LLDP data about other types of devices
# ignored (such as stations, telephones and others). If 'false', LLDP reception
# is disabled. Defaults to 'routers-only'. LLDP is only available on Ethernet
# links.
    lldp_receive: 'true'
# Controls support for Ethernet LLDP packet emission. Accepts a boolean
# parameter or the special values 'nearest-bridge', 'non-tpmr-bridge' and
# 'customer-bridge'. Defaults to 'false', which turns off LLDP packet emission.
# If not false, a short LLDP packet with information about the local system is
# sent out in regular intervals on the link. The LLDP packet will contain
# information about the local host name, the local machine ID
# (as stored in machine-id(5)) and the local interface name, as well as the
# pretty hostname of the system (as set in machine-info(5)). LLDP emission is
# only available on Ethernet links. Note that this setting passes data suitable
# for identification of host to the network and should thus not be enabled on
# untrusted networks, where such identification data should not be made
# available. Use this option to permit other systems to identify on which
# interfaces they are connected to this system. The three special values
# control propagation of the LLDP packets. The 'nearest-bridge' setting permits
# propagation only to the nearest connected bridge, 'non-tpmr-bridge' permits
# propagation across Two-Port MAC Relays, but not any other bridges, and
# 'customer-bridge' permits propagation until a customer bridge is reached. For
# details about these concepts, see IEEE 802.1AB-2009. Note that configuring
# this setting to 'true' is equivalent to 'nearest-bridge', the recommended and
# most restricted level of propagation.
    lldp_transmit: 'true'
  - interface: 'ten1'
    type: 'ether'
    physaddr: '3c:fd:fe:aa:5e:f9'
    bond: 'po1'
    altname: 'tengigabitethernet1'
    lldp_receive: 'true'
    lldp_transmit: 'true'
# Takes a boolean. Specifies the new active slave. The option is only valid for
# following modes: 'active-backup', 'balance-alb' and 'balance-tlb'. Defaults is
# 'false'.
    active_slave: 'false'
# Takes a boolean. Specifies which slave is the primary device. The specified
# device will always be the active slave while it is available. Only when the
# primary is off-line will alternate devices be used. This is useful when one
# slave is preferred over another, e.g. when one slave has higher throughput
# than another. The option is only valid for following modes: 'active-backup',
# 'balance-alb' and 'balance-tlb'. Defaults is false.
    primary_slave: 'false'
  - interface: 'fo1'
    type: 'ether'
    physaddr: 'e8:65:d4:e8:5c:68'
    speed: '40G'
# The duplex mode to set for the device. The accepted values are 'half' and
# 'full'.
    duplex: 'full'
# If set, automatic negotiation of transmission parameters is enabled.
# Autonegotiation is a procedure by which two connected ethernet devices choose
# common transmission parameters, such as speed, duplex mode, and flow control.
# When unset, the kernel's default will be used. Note that if autonegotiation
# is enabled, speed and duplex settings are read-only. If autonegotiation
# is disabled, speed and duplex settings are writable if the driver supports
# multiple link modes.
    autoneg: ''
# The Wake-on-LAN policy to set for the device. The supported values are:
# * phy - wake on PHY activity;
# * unicast - wake on unicast messages;
# * multicast - wake on multicast messages;
# * broadcast - wake on broadcast messages;
# * arp - wake on ARP;
# * magic - wake on receipt of a magic packet;
# * secureon - enable secureon(tm) password for MagicPacket(tm);
# * off - never wake (the default);
    won: 'off'
# The port option is used to select the device port. The supported values are:
# * tp - an Ethernet interface using Twisted-Pair cable as the medium.
# * aui - Attachment Unit Interface (AUI). Normally used with hubs.
# * bnc - an Ethernet interface using BNC connectors and co-axial cable.
# * mii - an Ethernet interface using a Media Independent Interface (MII).
# * fibre - an Ethernet interface using Optical Fibre as the medium.
    port: ''
# This sets what speeds and duplex modes of operation are advertised for
# autonegotiation.
    negotiation: '100000baselr4-er4-full'
# If set to 'true', the hardware offload for checksumming of ingress network
# packets is enabled. When unset, the kernel's default will be used.
    eth_rx: 'false'
# If set to 'true', the hardware offload for checksumming of egress network
# packets is enabled. When unset, the kernel's default will be used.
    eth_tx: 'false'
# If set to 'true', the TCP Segmentation Offload (TSO) is enabled. When unset,
# the kernel's default will be used.
    eth_tso: 'false'
# If set to 'true', the TCP6 Segmentation Offload (tx-tcp6-segmentation) is
# enabled. When unset, the kernel's default will be used.
    eth_tso6: 'false'
# If set to 'true', the Generic Segmentation Offload (GSO) is enabled. When
# unset, the kernel's default will be used.
    eth_gso: 'false'
# If set to 'true', the Generic Receive Offload (GRO) is enabled. When unset,
# the kernel's default will be used.
    eth_gro: 'false'
# If set to 'true', the Large Receive Offload (LRO) is enabled. When unset, the
# kernel's default will be used.
    eth_lro: 'false'
# Sets the number of receive channels (a number between 1 and 4294967295).
    eth_rx_channels: ''
# Sets the number of transmit channels (a number between 1 and 4294967295).
    eth_tx_channels: ''
# Sets the number of other channels (a number between 1 and 4294967295).
    eth_other_channels: ''
# Sets the number of combined set channels (a number between 1 and 4294967295).
    eth_combined_channels: ''
# Specifies the NIC receive ring buffer size. When unset, the kernel's default
# will be used.
    eth_rx_ring: ''
# Specifies the NIC transmit ring buffer size. When unset, the kernel's default
# will be used.
    eth_tx_ring: ''
  - interface: 'po1'
    type: 'bond'
    mtu: '9000'
# A boolean. Allows networkd to configure a specific link even if it has no
# carrier (plugged-in cable). Defaults to false.
    skip_no_carrier: 'true'
# A boolean. Allows networkd to retain both the static and dynamic
# configuration of the interface even if its carrier is lost. Default is
# 'false'.
    ignore_carrier_loss: 'false'
    bonding_options:
# Specifies one of the bonding policies. The default is 'balance-rr'
# (round robin). Possible values are 'balance-rr', 'active-backup',
# 'balance-xor', 'broadcast', '802.3ad', 'balance-tlb', and 'balance-alb'.
    - mode: '802.3ad'
# Selects the transmit hash policy to use for slave selection in balance-xor,
# 802.3ad, and tlb modes. Possible values are 'layer2', 'layer3+4', 'layer2+3',
# 'encap2+3', and 'encap3+4'.
      xmit_hash_policy: 'layer2+3'
# Specifies the rate with which link partner transmits Link Aggregation
# Control Protocol Data Unit packets in 802.3ad mode. Possible values are
# 'slow', which requests partner to transmit LACPDUs every 30 seconds, and
# 'fast', which requests partner to transmit LACPDUs every second. The default
# value is 'slow'.
      lacp_rate: 'fast'
# Specifies the frequency that Media Independent Interface link monitoring will
# occur. A value of zero disables MII link monitoring. This value is rounded
# down to the nearest millisecond. The default value is 0.
      miimon: '0.1'
# Specifies the delay before a link is enabled after a link up status has been
# detected. This value is rounded down to a multiple of MIIMonitorSec. The
# default value is 0.
      updelay: ''
# Specifies the delay before a link is disabled after a link down status has
# been detected. This value is rounded down to a multiple of MIIMonitorSec.
# The default value is 0.
      downdelay: ''
# Specifies the number of seconds between instances where the bonding driver
# sends learning packets to each slave peer switch. The valid range is
# 1–0x7fffffff; the default value is 1. This option has an effect only for the
# balance-tlb and balance-alb modes.
      lp_interval: ''
# Specifies the 802.3ad aggregation selection logic to use. Possible values are
# 'stable', 'bandwidth' and 'count'.
      ad_select: ''
# Specifies whether the active-backup mode should set all slaves to the same
# MAC address at the time of enslavement or, when enabled, to perform special
# handling of the bond's MAC address in accordance with the selected policy.
# The default policy is none. Possible values are 'none', 'active' and 'follow'.
      fail_over_mac: ''
# Specifies whether or not ARP probes and replies should be validated in any
# mode that supports ARP monitoring, or whether non-ARP traffic should be
# filtered (disregarded) for link monitoring purposes. Possible values are
# 'none', 'active', 'backup' and 'all'.
      arp_validate: ''
# Specifies the ARP link monitoring frequency in milliseconds. A value of 0
# disables ARP monitoring. The default value is 0.
      arp_interval: ''
# Specifies the IP addresses to use as ARP monitoring peers when ARPIntervalSec
# is greater than 0. These are the targets of the ARP request sent to determine
# the health of the link to the targets. Specify these values in IPv4 dotted
# decimal format. At least one IP address must be given for ARP monitoring to
# function. The maximum number of targets that can be specified is 16. The
# default value is no IP addresses.
      arp_ip_target: ''
# Specifies the quantity of ARPIPTargets that must be reachable in order for
# the ARP monitor to consider a slave as being up. This option affects only
# active-backup mode for slaves with ARPValidate enabled. Possible values are
# 'any' and 'all'.
      arp_all_targets: ''
# Specifies the reselection policy for the primary slave. This affects how the
# primary slave is chosen to become the active slave when failure of the active
# slave or recovery of the primary slave occurs. This option is designed to
# prevent flip-flopping between the primary slave and other slaves. Possible
# values are 'always', 'better' and 'failure'.
      primary_reselect: ''
# Specifies the number of IGMP membership reports to be issued after a failover
# event. One membership report is issued immediately after the failover,
# subsequent packets are sent in each 200ms interval. The valid range is 0–255.
# Defaults to 1. A value of 0 prevents the IGMP membership report from being
# issued in response to the failover event.
      resend_igmp: ''
# Specify the number of packets to transmit through a slave before moving to
# the next one. When set to 0, then a slave is chosen at random.
# The valid range is 0–65535. Defaults to 1. This option only has effect when
# in balance-rr mode.
      packets_per_slave: ''
# Specify the number of peer notifications (gratuitous ARPs and unsolicited
# IPv6 Neighbor Advertisements) to be issued after a failover event. As soon as
# the link is up on the new slave, a peer notification is sent on the bonding
# device and each VLAN sub-device. This is repeated at each link monitor
# interval ('ARPIntervalSec' or 'MIIMonitorSec', whichever is active) if the
# number is greater than 1. The valid range is 0–255. The default value is 1.
# These options affect only the active-backup mode.
      num_grat_arp: ''
# A boolean. Specifies that duplicate frames (received on inactive ports)
# should be dropped when false, or delivered when true. Normally, bonding will
# drop duplicate frames (received on inactive ports), which is desirable for
# most users. But there are some times it is nice to allow duplicate frames
# to be delivered. The default value is false (drop duplicate frames received
# on inactive ports).
      all_slaves_active: ''
# Specifies the minimum number of links that must be active before asserting
# carrier. The default value is 0.
      min_links: ''
    vlans:
    - name: 'vlan2'
      vlan_id: '2'
      mtu: '1504'
# A static IPv4 or IPv6 address and its prefix length, separated by a '/'
# character. Specify this key more than once to configure several addresses.
# The format of the address must be as described in inet_pton(3).
      address:
      - '10.10.10.2/24'
      - '10.10.11.2/24'
# A DNS server address, which must be in the format described in inet_pton(3).
# This setting is read by systemd-resolved.service(8).
      dns:
      - '8.8.8.8'
      - '8.8.4.4'
# Takes a boolean argument. If 'true', this link's configured DNS servers are
# used for resolving domain names that do not match any link's configured
# 'domains'. If 'false', this link's configured DNS servers are never used for
# such domains, and are exclusively used for resolving names that match at
# least one of the domains configured on this link. If not specified defaults
# to an automatic mode: queries not matching any link's configured domains will
# be routed to this link if it has no routing-only domains configured.
      dns_default_route: ''
# An NTP server address. This option may be specified more than once. This
# setting is read by systemd-timesyncd.service(8).
      ntp:
      - '0.europe.pool.ntp.org'
      - '1.europe.pool.ntp.org'
# Configures IP packet forwarding for the system. If enabled, incoming packets
# on any network interface will be forwarded to any other interfaces according
# to the routing table. Takes a boolean, or the values 'ipv4' or 'ipv6', which
# only enable IP packet forwarding for the specified address family. This
# controls the "net.ipv4.ip_forward" and "net.ipv6.conf.all.forwarding" sysctl
# options of the network interface. Default is 'false'.
# Note: this setting controls a global kernel option, and does so one way only:
# if a network that has this setting enabled is set up the global setting is
# turned on. However, it is never turned off again, even after all networks
# with this setting enabled are shut down again.
      ip_forward: 'false'
# Configures IP masquerading for the network interface. If enabled, packets
# forwarded from the network interface will be appear as coming from the local
# host. Takes a boolean argument. Default is 'false'.
      ip_masquerade: 'false'
    - name: 'vlan3'
      vlan_id: '3'
      address: '82.200.50.2/30'
# The gateway address, which must be in the format described in inet_pton(3).
      gateway: '82.200.50.1'
      dns: '8.8.8.8'
      ntp: '0.europe.pool.ntp.org'
      macaddr: '10:c3:7b:4f:58:a4'
    - name: 'vlan4'
      vlan_id: '4'
# Accepts 'yes', 'no', 'ipv4', or 'ipv6'. Defaults to 'no'.
      dhcp: 'yes'
# Takes a boolean or one of 'static', 'dhcp-on-stop', 'dhcp'. When 'static',
# systemd-networkd will not drop static addresses and routes on starting up
# process. When set to 'dhcp-on-stop', systemd-networkd will not drop
# addresses and routes on stopping the daemon. When 'dhcp', the addresses and
# routes provided by a DHCP server will never be dropped even if the DHCP lease
# expires. This is contrary to the DHCP specification, but may be the best
# choice if, e.g., the root filesystem relies on this connection. The setting
# 'dhcp' implies 'dhcp-on-stop', and 'true' implies 'dhcp' and 'static'.
# Defaults to 'dhcp-on-stop'.
      keep_configuration: 'dhcp-on-stop'
# This section configures the DHCPv4 and DHCP6 client, if it is enabled with
# the 'dhcp' setting described above.
      dhcp_client:
# When 'true' (the default), the DNS servers received from the DHCP server will
# be used and take precedence over any statically configured ones.
      - use_dns: 'false'
# When 'true', the routes to the DNS servers received from the DHCP server will
# be configured. When 'use_dns' is disabled, this setting is ignored. Defaults
# to 'false'.
        routes_to_dns: 'false'
# When 'true' (the default), the NTP servers received from the DHCP server will
# be used by systemd-timesyncd and take precedence over any statically
# configured ones.
        use_ntp: 'false'
# When 'true' (the default), the SIP servers received from the DHCP server will
# be saved at the state files and can be read via
# sd_network_link_get_sip_servers() function.
        use_sip: 'true'
# When 'true', the interface maximum transmission unit from the DHCP server will
# be used on the current link. Defaults to false.
        use_mtu: 'true'
# Takes a boolean argument. When true, the options sent to the DHCP server will
# follow the RFC 7844 (Anonymity Profiles for DHCP Clients) to minimize
# disclosure of identifying information. Defaults to false. This option should
# only be set to true when 'macaddr_policy ' is set to "random". Note that this
# configuration will overwrite others. In concrete, the following variables
# will be ignored: 'send_hostname', 'client_identifier', 'use_routes',
# 'send_hostname', 'use_mtu', 'vendor_class_identifier', 'use_timezone'.
        anonymize: 'false'
# When true (the default), the machine's hostname will be sent to the DHCP
# server.
        send_hostname: 'true'
# When true (the default), the hostname received from the DHCP server will be
# set as the transient hostname of the system.
        use_hostname: 'false'
# Use this value for the hostname which is sent to the DHCP server, instead of
# machine's hostname.
        hostname: ''
# Takes a boolean argument, or the special value 'route'. When true, the domain
# name received from the DHCP server will be used as DNS search domain over this
# link, similar to the effect of the 'domains' setting. If set to 'route', the
# domain name received from the DHCP server will be used for routing DNS
# queries only, but not for searching, similar to the effect of the 'domains'
# setting when the argument is prefixed with "~". Defaults to false.
# It is recommended to enable this option only on trusted networks, as setting
# this affects resolution of all host names, in particular of single-label
# names. It is generally safer to use the supplied domain only as routing
# domain, rather than as search domain, in order to not have it affect local
# resolution of single-label names. When set to true, this setting corresponds
# to the domain option in resolv.conf(5).
        use_domains: 'false'
# When true (the default), the static routes will be requested from the DHCP
# server and added to the routing table with a metric of 1024, and a scope of
# "global", "link" or "host", depending on the route's destination and gateway.
# If the destination is on the local host, e.g., 127.x.x.x, or the same as the
# link's own address, the scope will be set to "host". Otherwise if the gateway
# is null (a direct route), a "link" scope will be used. For anything else,
# scope defaults to "global".
        use_routes: 'true'
# When true, the timezone received from the DHCP server will be set as timezone
# of the local system. Defaults to "no".
        use_timezone: 'no'
# The DHCPv4 client identifier to use. Either 'mac' to use the MAC address of
# the link or 'duid' (the default) to use an RFC4361-compliant Client ID.
        client_identifier: 'duid'
# The vendor class identifier used to identify vendor type and configuration.
        vendor_class_identifier: ''
# A DHCPv4 client can use 'user_class' option to identify the type or category
# of user or applications it represents. The information contained in this
# option is a string that represents the user class of which the client is a
# member. Each class sets an identifying string of information to be used by
# the DHCP service to classify clients.
        user_class: ''
# Specifies how many times the DHCPv4 client configuration should be attempted.
# Takes a number or 'infinity' (the default). Note that the time between
# retries is increased exponentially, so the network will not be overloaded
# even if this number is high.  
        max_attempts: 'infinity'
# If 'vendor', then the DUID value will be generated using "43793" as the
# vendor identifier (systemd) and hashed contents of machine-id(5). This is the
# default if 'duid_type' is not specified.
# 'link-layer-time', 'link-layer', 'uuid', those values are parsed and can be
# used to set the DUID type field, but DUID contents must be provided using
# 'duid_raw_data'. In all cases, 'duid_raw_data' can be used to override the
# actual DUID value that is used.
        duid_type: 'vendor'
# Specifies the DHCP DUID value as a single newline-terminated, hexadecimal
# string, with each byte separated by ":". The DUID that is sent is composed of
# the DUID type specified by 'duid_type' and the value configured here.
# The DUID value specified here overrides the DUID that systemd-networkd
# generates using the machine-id from the /etc/machine-id file. To configure
# DUID per-network, see systemd.network(5). The configured DHCP DUID should
# conform to the specification in RFC 3315, RFC 6355.
#
# Example:
# - duid_type: 'vendor'
#   duid_raw_data: '00:00:ab:11:f9:2a:c2:77:29:f9:5c:00'
# This specifies a 14 byte DUID, with the type DUID-EN ("00:02"), enterprise
# number 43793 ("00:00:ab:11"), and identifier value "f9:2a:c2:77:29:f9:5c:00".
        duid_raw_data: ''
# The DHCP Identity Association Identifier (IAID) for the interface, a 32-bit
# unsigned integer.
        iaid: ''
# Request the server to use broadcast messages before the IP address has been
# configured. This is necessary for devices that cannot receive RAW packets, or
# that cannot receive packets at all before an IP address has been configured.
# On the other hand, this must not be enabled on networks where broadcasts are
# filtered out.
        request_broadcast: 'false'
# Set the routing metric for routes specified by the DHCP server.
        route_metric: ''
# The table identifier for DHCP routes (a number between 1 and 4294967295, or 0
# to unset). When used in combination with 'vrf' the VRF's routing table is
# used unless this parameter is specified.
        route_table: ''
# Specifies the MTU for the DHCP routes.
        route_mtu: ''
# Allow setting custom port for the DHCP client to listen on.
        listen_port: ''
# A boolean. The DHCPv6 client can obtain configuration parameters from a
# DHCPv6 server through a rapid two-message exchange (solicit and reply). When
# the rapid commit option is enabled by both the DHCPv6 client and the DHCPv6
# server, the two-message exchange is used, rather than the default four-method
# exchange (solicit, advertise, request, and reply). The two-message exchange
# provides faster client configuration and is beneficial in environments in
# which networks are under a heavy load. See RFC 3315 for details.
# Defaults to 'true'.
# When 'true', the DHCPv4 client sends a DHCP release packet when it stops.
# Defaults to 'false'.
        send_release: 'false'
# When 'true', DHCPv4 clients receives IP address from DHCP server. After new
# IP is received, DHCPv4 performs IPv4 Duplicate Address Detection. If duplicate
# use of IP is detected the DHCPv4 client rejects the IP by sending a
# DHCPDECLINE packet DHCP clients try to obtain an IP address again. Defaults is
# None.
        send_decline: ''
# A list of IPv4 addresses. DHCP offers from servers in the list are rejected.
        blacklist:
        - '10.10.10.1'
        - '10.10.10.2'
# List of DHCP options to request.
        request_options:
        - '31'
        - '6'
# Send an arbitrary option in the DHCPv4 request. Takes a DHCP option number,
# data type and data separated with a colon ('option:type:value'). The option
# number must be an integer in the range 1..254. The type takes one of 'uint8',
# 'uint16', 'uint32', 'ipv4address', or 'string'. Special characters in the
# data string may be escaped using C-style escapes. This setting can be
# specified multiple times. If an empty string is specified, then all options
# specified earlier are cleared. Defaults is None.
        send_option: ''
        rapid_commit: 'true'
# Takes a boolean that enforces DHCPv6 stateful mode when the
# "Other information" bit is set in Router Advertisement messages. By default
# setting only the 'O' bit in Router Advertisements makes DHCPv6 request
# network information in a stateless manner using a two-message Information
# Request and Information Reply message exchange. RFC 7084, requirement WPD-4,
# updates this behavior for a Customer Edge router so that stateful DHCPv6
# Prefix Delegation is also requested when only the 'O' bit is set in Router
# Advertisements. This option enables such a CE behavior as it is impossible to
# automatically distinguish the intention of the 'O' bit otherwise. By default
# this option is set to 'false', enable it if no prefixes are delegated when the
# device should be acting as a CE router.
        force_dhcp_v6_pd_other_information: 'false'
# Takes an IPv6 address with prefix length as 'address'. Specifies the DHCPv6
# client for the requesting router to include a prefix-hint in the DHCPv6
# solicitation. Prefix ranges 1-128. Defaults to unset.
        prefix_delegation_hint: ''
    - name: 'vlan5'
      vlan_id: '5'
      address: '172.16.16.2/24'
# Configures the pool of addresses to hand out. The pool is a contiguous
# sequence of IP addresses in the subnet configured for the server address,
# which does not include the subnet nor the broadcast address.
      dhcp_server:
# Takes the offset of the pool from the start of subnet, or zero to use the
# default value.
      - pool_offset: '2'
# Takes the number of IP addresses in the pool or zero to use the default value.
# By default, the pool starts at the first address after the subnet address and
# takes up the rest of the subnet, excluding the broadcast address. If the pool
# includes the server address (the default), this is reserved and not handed
# out to clients.
        pool_size: '100'
# Control the default and maximum DHCP lease time in seconds to pass to clients.
# These settings take time values in seconds or another common time unit,
# depending on the suffix. The default lease time is used for clients that did
# not ask for a specific lease time. If a client asks for a lease time longer
# than the maximum lease time, it is automatically shortened to the specified
# time. The default lease time defaults to 1h, the maximum lease time to 12h.
# Shorter lease times are beneficial if the configuration data in DHCP leases
# changes frequently and clients shall learn the new settings with shorter
# latencies. Longer lease times reduce the generated DHCP network traffic.
        default_lease_time: '3600'
        max_lease_time: '43200'
# Configures whether the DHCP leases handed out to clients shall contain DNS
# server information. The 'push_dns' setting takes a boolean argument and
# defaults to "yes". The DNS servers to pass to clients may be configured with
# the 'dns' option (only ipv4). If the 'push_dns' option is enabled but no
# servers configured, the servers are automatically propagated from an "uplink"
# interface that has appropriate servers set. The "uplink" interface is
# determined by the default route of the system with the highest priority. Note
# that this information is acquired at the time the lease is handed out, and
# does not take uplink interfaces into account that acquire DNS or NTP server
# information at a later point. DNS server propagation does not take
# /etc/resolv.conf into account. Also, note that the leases are not refreshed
# if the uplink network configuration changes. To ensure clients regularly
# acquire the most current uplink DNS server information, it is thus advisable
# to shorten the DHCP lease time via 'max_lease_time' described above.
        push_dns: 'true'
        dns: '172.16.16.1'
# Similar to the 'push_dns' and 'dns' settings described above, these settings
# configure whether and what NTP server information shall be emitted as part of
# the DHCP lease. The same syntax, propagation semantics and defaults apply as
# for 'push_dns' and 'dns'.
        push_ntp: 'true'
        ntp: '172.16.16.1'
# Similar to the 'push_dns' and 'dns' settings described above, these settings
# configure whether and what SIP server information shall be emitted as part of
# the DHCP lease. The same syntax, propagation semantics and defaults apply as
# for 'push_dns' and 'dns'.
        push_sip: 'true'
        sip: '172.16.16.1'
# This setting configures whether the DHCP lease should contain the router
# option. The same syntax, propagation semantics and defaults apply as for
# 'push_dns'.
        push_router: 'true'
# Configures whether the DHCP leases handed out to clients shall contain
# timezone information. The 'push_timezone' setting takes a boolean argument
# and defaults to 'yes'. The 'timezone' setting takes a timezone string
# (such as "Europe/Berlin" or "UTC") to pass to clients. If no explicit
# timezone is set, the system timezone of the local host is propagated, as
# determined by the /etc/localtime symlink.
        push_timezone: 'yes'
        timezone: 'UTC'
# Send an arbitrary option in the DHCPv4 request. Takes a DHCP option number,
# data type and data separated with a colon ('option:type:value'). The option
# number must be an integer in the range 1..254. The type takes one of 'uint8',
# 'uint16', 'uint32', 'ipv4address', or 'string'. Special characters in the
# data string may be escaped using C-style escapes. This setting can be
# specified multiple times. If an empty string is specified, then all options
# specified earlier are cleared. Defaults is None.
        send_option: ''
# Enables link-local address autoconfiguration. Accepts 'yes', 'no', 'ipv4', or
# 'ipv6'. Defaults to 'ipv6'.
      link_local_adressing: 'ipv6'
# A boolean. When true, sets up the route needed for non-IPv4LL hosts to
# communicate with IPv4LL-only hosts. Defaults to false.
      ipv4_llroute: 'false'
# Takes a boolean. If set to 'true', sets up the default route bound to the
# interface. Defaults to 'false'. This is useful when creating routes on
# point-to-point interfaces. This is equivalent to e.g. the following.
# "ip route add default dev veth99".
      default_route_on_device: 'false'
# An IPv6 address with the top 64 bits unset. When set, indicates the 64-bit
# interface part of SLAAC IPv6 addresses for this link. Note that the token is
# only ever used for SLAAC, and not for DHCPv6 addresses, even in the case DHCP
# is requested by router advertisement. By default, the token is autogenerated.
      ipv6_token: ''
# A boolean or 'resolve'. When true, enables Link-Local Multicast Name
# Resolution on the link. When set to 'resolve', only resolution is enabled, but
# not host registration and announcement. Defaults to true. This setting is read
# by systemd-resolved.service(8).
      llmnr: 'true'
# A boolean or 'resolve'. When true, enables Multicast DNS support on the link.
# When set to 'resolve', only resolution is enabled, but not host or service
# registration and announcement. Defaults to false. This setting is read by
# systemd-resolved.service(8).
      multicast_dns: 'false'
# Takes a boolean or 'opportunistic'. When 'true', enables DNS-over-TLS support
# on the link. When set to 'opportunistic', compatibility with non-DNS-over-TLS
# servers is increased, by automatically turning off DNS-over-TLS servers in
# this case. This option defines a per-interface setting for resolved
# 'dns_over_tls' option. Defaults to 'false'.
      dns_over_tls: 'false'
# A boolean or 'allow-downgrade'. When true, enables DNSSEC DNS validation
# support on the link. When set to 'allow-downgrade', compatibility with
# non-DNSSEC capable networks is increased, by automatically turning off DNSSEC
# in this case. This option defines a per-interface setting for
# resolved.conf(5)'s global 'dnssec' option. Defaults to false. This setting is
# read by systemd-resolved.service(8).
      dnssec: 'false'
# A space-separated list of DNSSEC negative trust anchor domains. If specified
# and DNSSEC is enabled, look-ups done via the interface's DNS server will be
# subject to the list of negative trust anchors, and not require authentication
# for the specified domains, or anything below it. Use this to disable DNSSEC
# authentication for specific private domains, that cannot be proven valid
# using the Internet DNS hierarchy. Defaults to the empty list. This setting is
# read by systemd-resolved.service(8).
      dnssec_negative_trust_anchors: ''
    - name: 'vlan66'
      vlan_id: '66'
      ip:
      - address: '100.100.100.2/24'
# The peer address in a point-to-point connection.
        peer: ''
# The broadcast address, which must be in the format described in inet_pton(3).
# This key only applies to IPv4 addresses. If it is not given, it is derived
# from the 'address' key.
        broadcast: ''
# An address label.
        label: '1.6'
# Allows the default "preferred lifetime" of the address to be overridden. Only
# three settings are accepted: 'forever' or 'infinity' which is the default and
# means that the address never expires, and '0' which means that the address is
# considered immediately "expired" and will not be used, unless explicitly
# requested. A setting of '0' is useful for addresses which are added to be
# used only by a specific application, which is then configured to use them
# explicitly.
        preferred_lifetime: 'forever'
# The scope of the address, which can be 'global', 'link' or 'host' or an
# unsigned integer ranges 0 to 255. Defaults to 'global'.
        scope: 'global'
# Takes a boolean argument. Designates this address the "home address" as
# defined in RFC 6275. Supported only on IPv6. Defaults to false.
        home_address: 'false'
# Takes a boolean argument. Do not perform Duplicate Address Detection
# RFC 4862 when adding this address. Supported only on IPv6. Defaults to false.
        duplicate_detection: 'false'
# Takes a boolean argument, Defaults to false. If true the kernel manage temporary addresses
# created from this one as template on behalf of Privacy Extensions RFC 3041.
# For this to become active, the use_tempaddr sysctl setting has to be set to a
# value greater than zero. The given address needs to have a prefix length of
# 64. This flag allows to use privacy extensions in a manually configured
# network, just like if stateless auto-configuration was active.
        manage_temporary_address: 'false'
# When 'true' (the default), the prefix route for the address is automatically
# added.
        add_prefix_route: 'false'
# Takes a boolean argument. Joining multicast group on ethernet level via ip
# maddr command would not work if we have an Ethernet switch that does IGMP
# snooping since the switch would not replicate multicast packets on ports that
# did not have IGMP reports for the multicast addresses. Linux vxlan interfaces
# created via ip link add vxlan or networkd's netdev kind vxlan have the group
# option that enables then to do the required join. By extending ip address
# command with option "autojoin" we can get similar functionality for
# openvswitch (OVS) vxlan interfaces as well as other tunneling mechanisms that
# need to receive multicast traffic. Defaults to 'no'.
        autojoin: 'false'
      ip_rule:
# Specifies the type of service to match a number between 0 to 255.
      - tos: ''
# Specifies the source address prefix to match. Possibly followed by a slash
# and the prefix length.
        from: '100.100.100.1'
# Specifies the destination address prefix to match. Possibly followed by a
# slash and the prefix length.
        to: ''
# Specifies the iptables firewall mark value to match (a number between 1 and 4294967295).
        fwmark: ''
# Specifies the routing table identifier to lookup if the rule selector matches.
# The table identifier for a route (a number between 1 and 4294967295).
        table: '100'
# Specifies the priority of this rule. Priority is an unsigned integer. Higher
# number means lower priority, and rules get processed in order of increasing
# number.
        prio: ''
# Specifies incoming device to match. If the interface is loopback, the rule
# only matches packets originating from this host.
        iif: ''
# Specifies the outgoing device to match. The outgoing interface is only
# available for packets originating from local sockets that are bound to a
# device.
        oif: ''
# Specifies the source IP port or IP port range match in forwarding information
# base (FIB) rules. A port range is specified by the lower and upper port
# separated by a dash.
        sport: ''
# Specifies the destination IP port or IP port range match in forwarding
# information base (FIB) rules. A port range is specified by the lower and
# upper port separated by a dash.
        dport: ''
# Specifies the IP protocol to match in forwarding information base (FIB) rules.
# Takes IP protocol name such as 'tcp', 'udp' or 'sctp', or IP protocol number
# such as '6' for 'tcp' or '17' for 'udp'.
        ip_proto: ''
# A boolean. Specifies wheather the rule to be inverted. Defaults to 'false'.
        invert_rule: 'false'
# Takes a special value 'ipv4', 'ipv6', or 'both'. By default, the address
# family is determined by the address specified in 'to' or 'from'. If neither
# 'to' or 'from' are specified, then defaults to 'ipv4'.
        family: 'ipv4'
# Takes a username, a user ID, or a range of user IDs separated by a dash.
# Defaults is None.
        user: ''
# Takes a number N in the range 0-128 and rejects routing decisions that have a
# prefix length of N or less. Defaults is None.
        suppress_prefix_length: ''
      - from: 'all'
        fwmark: '200'
        table: '200'
      ip_route:
# Takes the gateway address or special value '_dhcp'. If '_dhcp', then the
# gateway address provided by DHCP (or in the IPv6 case, provided by IPv6 RA)
# is used.
      - gateway: '100.100.100.1'
# Option tells the kernel that it does not have to check if the gateway is
# reachable directly by the current machine (i.e., the kernel does not need to
# check if the gateway is attached to the local network), so that we can insert
# the route in the kernel table without it being complained about. A boolean,
# defaults to 'no'.
        gateway_on_link: 'false'
# The destination prefix of the route. Possibly followed by a slash and the
# prefix length. If omitted, a full-length host route is assumed.
        destination: '0.0.0.0/0'
# The source prefix of the route. Possibly followed by a slash and the prefix
# length. If omitted, a full-length host route is assumed.
        source: ''
# The metric of the route (an unsigned integer).
        metric: ''
# Specifies the route preference as defined in RFC4191 for Router Discovery
# messages. Which can be one of 'low' the route has a lowest priority, 'medium'
# the route has a default priority or 'high' the route has a highest priority.
        ipv6_prefer: ''
# The scope of the route, which can be 'global', 'link' or 'host'.
# Defaults to 'global'.
        scope: 'global'
# The preferred source address of the route. The address must be in the format
# described in inet_pton(3).
        prefer_source: ''
# The table identifier for the route (a number between 1 and 4294967295, or 0
# to unset).
        table: '100'
# The protocol identifier for the route. Takes a number between 0 and 255 or
# the special values 'kernel', 'boot', 'static', 'ra' and 'dhcp'. Defaults to
# 'static'.
        protocol: 'static'
# The Type identifier for special route types, which can be 'unicast' route to
# a destination network address which describes the path to the destination,
# 'blackhole' packets are discarded silently, 'unreachable' packets are
# discarded and the ICMP message host unreachable is generated, 'prohibit'
# packets are discarded and the ICMP message communication administratively
# prohibited is generated. Defaults to 'unicast'.
        type: 'unicast'
# The TCP initial congestion window is used during the start of a TCP
# connection. During the start of a TCP session, when a client requests a
# resource, the server's initial congestion window determines how many data
# bytes will be sent during the initial burst of data. Takes a size in bytes
# etween 1 and 4294967295 (2^32 - 1). The usual suffixes K, M, G are supported
# and are understood to the base of 1024. Defaults to unset.
        initial_congestion_window: ''
# The TCP initial advertised receive window is the amount of receive data (in
# bytes) that can initally be buffered at one time on a connection. The sending
# host can send only that amount of data before waiting for an acknowledgment
# and window update from the receiving host. Takes a size in bytes between 1
# and 4294967295 (2^32 - 1). The usual suffixes K, M, G are supported and are
# understood to the base of 1024. Defaults to unset.
        initial_advertised_receive_window: ''
# Takes a boolean. When 'true' enables TCP quick ack mode for the route. When
# unset, the kernel's default will be used.
        quick_ack: ''
# Takes a boolean. When 'true' enables TCP fastopen without a cookie on a
# per-route basis. When unset, the kernel's default will be used.
        fast_open_no_cookie: ''
# Takes a boolean. When 'true' enables TTL propagation at Label Switched Path
# (LSP) egress. When unset, the kernel's default will be used.
        ttl_propagate: ''
# The maximum transmission unit in bytes to set for the route. The usual
# suffixes K, M, G, are supported and are understood to the base of 1024.
# Note that if IPv6 is enabled on the interface, and the MTU is chosen below
# '1280' (the minimum MTU for IPv6) it will automatically be increased to this
# value.
        mtu_bytes: ''
# Used to set IP service type to 'CS6' (network control) or 'CS4' (Realtime).
# Defaults to 'CS6'.
        ip_service_type: 'CS6'
      - destination: '192.168.10.1/32'
# Multipath routing is the technique of using multiple alternative paths
# through a network. Takes gateway address. Optionally, takes a network
# interface name or index, and a weight in range of 1-256 for this multipath
# route.
        multi_path_route:
        - gateway: '149.10.124.59'
          iface: 'dummy98'
          weight: '10'
        - gateway: '149.10.124.60'
          iface: 'dummy98'
          weight: '5'
    - name: 'vlan6'
      vlan_id: '6'
      address: '192.168.5.10/24'
      gateway: '192.168.5.1'
# Nexthop is used to manipulate entries in the kernel's nexthop tables
      ip_next_hop:
# The id of the nexthop. If unspecified or '0' then automatically chosen by
# kernel
      - id: '1'
        gateway: '192.168.5.1'
    - name: 'vlan7'
      vlan_id: '7'
# The name of the VRF to add the link to
      vrf: 'vrf7'
      address: '100.200.200.1/24'
    - name: 'vlan8'
      vlan_id: '8'
      vrf: 'vrf8'
      address: '100.200.200.1/24'
    - name: 'vlan9'
      vlan_id: '9'
      address: '101.201.201.1/24'
# A 'neighbors' section adds a permanent, static entry to the neighbor table
# (IPv6) or ARP table (IPv4) for the given hardware address on the links
# matched for the network
      neighbors:
# The IP address of the neighbor
      - address: '101.201.201.2'
# The link layer address (MAC address or IP address) of the neighbor
        link_layer_address: '6c:62:6d:92:37:82'
      - address: '2001:db8:0:f102::17'
        link_layer_address: '2a00:ffde:4567:edde::4988'
    - name: 'vlan10'
      vlan_id: '10'
      address: '100.202.202.1/24'
# Manages the traffic control queueing discipline (qdisc).
      qdisc:
# Specifies the parent Queueing Discipline (qdisc). Takes one of 'clsact' or
# 'ingress'. This is mandatory.
      - parent: 'clsact'
# Specifies the major number of unique identifier of the qdisc, known as the
# handle. Takes a number in hexadecimal ranges 1 to ffff. Default is None.
        handle: '1:0'
# Manages the queueing discipline (qdisc) of the network emulator (netem). It
# can be used to configure the kernel packet scheduler and simulate packet
# delay and loss for UDP or TCP applications, or limit the bandwidth usage of a
# particular service to simulate internet connections.
      qdisc_netem:
# Specifies the parent Queueing Discipline (qdisc). Takes one of 'root',
# 'clsact', 'ingress' or a class id. The class id takes the major and minor
# number in hexadecimal ranges 1 to ffff separated with a colon ('major:minor').
# Defaults to 'root'.
      - parent: '2:30'
# Specifies the major number of unique identifier of the qdisc, known as the
# handle. Takes a number in hexadecimal ranges 1 to ffff. Default is None.
        handle: '0030'
# Specifies the fixed amount of delay to be added to all packets going out of
# the interface. Default is None.
        delay_sec: '50ms'
# Specifies the chosen delay to be added to the packets outgoing to the network
# interface. Default is None.
        delay_jitter_sec: '10ms'
# Specifies the maximum number of packets the qdisc may hold queued at a time.
# An unsigned integer ranges 0 to 4294967294. Default is '1000'.
        packet_limit: '100'
# Specifies an independent loss probability to be added to the packets outgoing
# from the network interface. Takes a percentage value, suffixed with '%'.
# Default is None.
        loss_rate: '20%'
# Specifies that the chosen percent of packets is duplicated before queuing
# them. Takes a percentage value, suffixed with '%'. Defaults to unset.
        duplicate_rate: ''
# Manages the queueing discipline (qdisc) of token bucket filter (tbf).
      qdsic_tbf:
      - parent: '2:35'
        handle: '0035'
# Specifies the latency parameter, which specifies the maximum amount of time a
# packet can sit in the Token Bucket Filter (TBF). Default is None.
        latency_sec: '70msec'
# Takes the number of bytes that can be queued waiting for tokens to become
# available. When the size is suffixed with K, M, or G, it is parsed as
# Kilobytes, Megabytes, or Gigabytes, respectively, to the base of 1000.
# Default is None.
        limit_size: ''
# Specifies the size of the bucket. This is the maximum amount of bytes that
# tokens can be available for instantaneous transfer. When the size is suffixed
# with K, M, or G, it is parsed as Kilobytes, Megabytes, or Gigabytes,
# respectively, to the base of 1000. Default is None.
        burst: '5K'
# Specifies the device specific bandwidth. When suffixed with K, M, or G, the
# specified bandwidth is parsed as Kilobits, Megabits, or Gigabits,
# respectively, to the base of 1000. Defaults to unset.
        rate: '1G'
# The Minimum Packet Unit (MPU) determines the minimal token usage (specified
# in bytes) for a packet. When suffixed with K, M, or G, the specified size is
# parsed as Kilobytes, Megabytes, or Gigabytes, respectively, to the base of
# 1000. Defaults to zero.
        mpu: ''
# Takes the maximum depletion rate of the bucket. When suffixed with K, M, or
# G, the specified size is parsed as Kilobits, Megabits, or Gigabits,
# respectively, to the base of 1000. Default is None.
        peak_rate: '100G'
# Specifies the size of the peakrate bucket. When suffixed with K, M, or G, the
# specified size is parsed as Kilobytes, Megabytes, or Gigabytes, respectively,
# to the base of 1000. Default is None.
        mtu: '1M'
# Manages the queueing discipline (qdisc) of Proportional Integral
# controller-Enhanced (PIE).
      qdisc_pie:
      - parent: 'root'
        handle: '3a'
# Specifies the hard limit on the queue size in number of packets. When this
# limit is reached, incoming packets are dropped. An unsigned integer ranges 1
# to 4294967294. Defaults to unset and kernel's default is used.
        packet_limit: '200000'
# Manages the queueing discipline (qdisc) of stochastic fair blue (sfb).
      qdisc_sfb:
      - parent: '2:39'
        handle: '0039'
# Specifies the hard limit on the queue size in number of packets. When this
# limit is reached, incoming packets are dropped. An unsigned integer ranges 1
# to 4294967294. Defaults to unset and kernel's default is used.
        packet_limit: '200000'
# Manages the queueing discipline (qdisc) of stochastic fairness queueing (sfq).
      qdisc_sfq:
      - parent: '2:36'
        handle: '0036'
# Specifies the interval in seconds for queue algorithm perturbation. Defaults
# is None.
        perturb: '5sec'
# Manages the queueing discipline (qdisc) of Byte limited Packet First In First
# Out (bfifo).
      qdisc_bfifo:
      - parent: '2:3a'
        handle: '003a'
# Specifies the hard limit on the FIFO size in bytes. The size limit (a buffer
# size) to prevent it from overflowing in case it is unable to dequeue packets
# as quickly as it receives them. When this limit is reached, incoming packets
# are dropped. When suffixed with K, M, or G, the specified size is parsed as
# Kilobytes, Megabytes, or Gigabytes, respectively, to the base of 1024.
# Defaults to unset and kernel's default is used.
        limit_size: '1M'
# Manages the queueing discipline (qdisc) of Packet First In First Out (pfifo).
      qdisc_pfifo:
      - parent: '2:37'
        handle: '0037'
# Specifies the hard limit on the FIFO size in number of packets. The size
# limit (a buffer size) to prevent it from overflowing in case it is unable to
# dequeue packets as quickly as it receives them. When this limit is reached,
# incoming packets are dropped. An unsigned integer ranges 0 to 4294967294.
# Defaults to unset and kernel's default is used.
        packet_limit: '100000'
# Manages the queueing discipline (qdisc) of Packet First In First Out Head
# Drop (pfifo_head_drop).
      qdisc_pfifo_head_drop:
      - parent: '2:3b'
        handle: '003b'
        packet_limit: '100000'
# Manages the queueing discipline (qdisc) of Packet First In First Out Fast
# (pfifo_fast).
      qdisc_pfifo_fast:
      - parent: '2:3c'
        handle: '003c'
# Manages the queueing discipline (qdisc) of Common Applications Kept Enhanced
# (CAKE).
      qdisc_cake:
      - parent: 'root'
        handle: '3a'
# Specifies that bytes to be addeded to the size of each packet. Bytes may be
# negative. Takes an integer ranges -64 to 256. Defaults to unset and kernel's
# default is used.
        overhead: '128'
# Specifies the shaper bandwidth. When suffixed with K, M, or G, the specified
# size is parsed as Kilobits, Megabits, or Gigabits, respectively, to the base
# of 1000. Defaults to unset and kernel's default is used.
        bandwidth: '500M'
# Manages the queueing discipline (qdisc) of Deficit Round Robin Scheduler
# (DRR).
      qdisc_drr:
      - parent: 'root'
        handle: '0002'
# Manages the traffic control class of Deficit Round Robin Scheduler (DRR).
      qdisc_drr_class:
      - parent: 'root'
# Specifies the major and minur number of unique identifier of the class, known
# as the class ID. Each number is in hexadecimal ranges 1 to ffff. Defaults to
# unset.
        classid: '0002:0030'
# Specifies the amount of bytes a flow is allowed to dequeue before the
# scheduler moves to the next class. An unsigned integer ranges 1 to 4294967294.
# Defaults to the MTU of the interface.
        quantum: '2000'
# Manages the queueing discipline (qdisc) of Generic Random Early Detection
# (GRED).
      qdisc_gred:
      - parent: '2:38'
        handle: '0038'
# Specifies the number of virtual queues. Takes a integer in the range 1-16.
# Defaults to unset and kernel's default is used.
        queues: '12'
# Specifies the number of default virtual queue. This must be less than
# 'virtual_queues'. Defaults to unset and kernel's default is used.
        default_queue: '10'
# Takes a boolean. It turns on the RIO-like buffering scheme. Defaults to unset
# and kernel's default is used.
        generic_rio: 'true'
# Manages the queueing discipline (qdisc) of controlled delay (CoDel).
      qdisc_codel:
      - parent: '2:33'
        handle: '0033'
# Specifies the hard limit on the queue size in number of packets. When this
# limit is reached, incoming packets are dropped. An unsigned integer ranges 0
# to 4294967294. Defaults to unset and kernel's default is used.
        packet_limit: '2000'
# Takes a timespan. Specifies the acceptable minimum standing/persistent queue
# delay. Defaults to unset and kernel's default is used.
        target: '10ms'
# Takes a timespan. This is used to ensure that the measured minimum delay does
# not become too stale. Defaults to unset and kernel's default is used.
        interval: '50ms'
# Takes a boolean. This can be used to mark packets instead of dropping them.
# Defaults to unset and kernel's default is used.
        ecn: 'yes'
# Takes a timespan. This sets a threshold above which all packets are marked
# with ECN Congestion Experienced (CE). Defaults to unset and kernel's default
# is used.
        ce_threshold: '100ms'
# Manages the queueing discipline (qdisc) of fair queuing controlled delay
# (FQ-CoDel).
      qdisc_fq_codel:
      - parent: '2:34'
        handle: '0034'
# Specifies the hard limit on the real queue size. When this limit is reached,
# incoming packets are dropped. Defaults to unset and kernel's default is used.
        packet_limit: '20480'
# Specifies the limit on the total number of bytes that can be queued in this
# FQ-CoDel instance. When suffixed with K, M, or G, the specified size is
# parsed as Kilobytes, Megabytes, or Gigabytes, respectively, to the base of
# 1024. Defaults to unset and kernel's default is used.
        memory_limit: '64M'
# Specifies the number of flows into which the incoming packets are classified.
# Defaults to unset and kernel's default is used.
        flows: '2048'
# Takes a timespan. Specifies the acceptable minimum standing/persistent queue
# delay. Defaults to unset and kernel's default is used.
        target: '10ms'
# Takes a timespan. This is used to ensure that the measured minimum delay does
# not become too stale. Defaults to unset and kernel's default is used.
        interval: '200ms'
# Specifies the number of bytes used as 'deficit' in the fair queuing
# algorithmtimespan. When suffixed with K, M, or G, the specified size is
# parsed as Kilobytes, Megabytes, or Gigabytes, respectively, to the base of
# 1024. Defaults to unset and kernel's default is used.
        quantum: '1400'
# Takes a boolean. This can be used to mark packets instead of dropping them.
# Defaults to unset and kernel's default is used.
        ecn: 'true'
# Takes a timespan. This sets a threshold above which all packets are marked
# with ECN Congestion Experienced (CE). Defaults to unset and kernel's default
# is used.
        ce_threshold: '100ms'
# Manages the queueing discipline (qdisc) of fair queue traffic policing (FQ).
      qdisc_fq:
      - parent: '2:32'
        handle: '0032'
# Specifies the hard limit on the real queue size. When this limit is reached,
# incoming packets are dropped. Defaults to unset and kernel's default is used.
        packet_limit: '1000'
# Specifies the hard limit on the maximum number of packets queued per flow.
# Defaults to unset and kernel's default is used.
        flow_limit: '200'
# Specifies the credit per dequeue RR round, i.e. the amount of bytes a flow is
# allowed to dequeue at once. When suffixed with K, M, or G, the specified size
# is parsed as Kilobytes, Megabytes, or Gigabytes, respectively, to the base of
# 1024. Defaults to unset and kernel's default is used.
        quantum: '1500'
# Specifies the initial sending rate credit, i.e. the amount of bytes a new
# flow is allowed to dequeue initially. When suffixed with K, M, or G, the
# specified size is parsed as Kilobytes, Megabytes, or Gigabytes, respectively,
# to the base of 1024. Defaults to unset and kernel's default is used.
        initial_quantum: '13000'
# Specifies the maximum sending rate of a flow. When suffixed with K, M, or G,
# the specified size is parsed as Kilobits, Megabits, or Gigabits, respectively,
# to the base of 1000. Defaults to unset and kernel's default is used.
        maximum_rate: '1M'
# Specifies the size of the hash table used for flow lookups. Defaults to unset
# and kernel's default is used.
        buckets: '512'
# Takes an unsigned integer. For packets not owned by a socket, fq is able to
# mask a part of hash and reduce number of buckets associated with the traffic.
# Defaults to unset and kernel's default is used.
        orphan_mask: '511'
# Takes a boolean, and enables or disables flow pacing. Defaults to unset and
# kernel's default is used.
        pacing: 'true'
# Takes a timespan. This sets a threshold above which all packets are marked
# with ECN Congestion Experienced (CE). Defaults to unset and kernel's default
# is used.
        ce_threshold: '100ms'
# Manages the queueing discipline (qdisc) of trivial link equalizer (teql).
      qdisc_teql:
      - parent: '2:31'
        handle: '0031'
# Specifies the interface ID 'N' of teql. Defaults to '0'.
        id: '1'
# Manages the queueing discipline (qdisc) of Hierarchy Token Bucket (htb).
      qdisc_htb:
      - parent: 'root'
        handle: '0002'
# Takes the minor id in hexadecimal of the default class. Unclassified traffic
# gets sent to the class. Defaults to unset.
        default: '30'
# Takes an unsigned integer. The DRR quantums are calculated by dividing the
# value configured in 'rate' by 'r2q'.
        r2q: '10'
# Manages the traffic control class of Hierarchy Token Bucket (htb).
      qdisc_htb_class:
# Specifies the parent Queueing Discipline (qdisc). Takes one of 'root', or a
# qdisc id. The qdisc id takes the major and minor number in hexadecimal ranges
# 1 to ffff separated with a colon ("major:minor"). Defaults to 'root'.
      - parent: 'root'
# Specifies the major and minur number of unique identifier of the class, known
# as the class ID. Each number is in hexadecimal ranges 1 to ffff. Default is
# None.
        classid: '0002:0030'
# Specifies the priority of the class. In the round-robin process, classes with
# the lowest priority field are tried for packets first. This setting is
# mandatory.
        prio: '1'
# Specifies how many bytes to serve from leaf at once. When suffixed with K, M,
# or G, the specified size is parsed as Kilobytes, Megabytes, or Gigabytes,
# respectively, to the base of 1024.
        quantum: '1000'
# Specifies the maximum packet size we create. When suffixed with K, M, or G,
# the specified size is parsed as Kilobytes, Megabytes, or Gigabytes,
# respectively, to the base of 1024.
        mtu: '1500'
# Takes an unsigned integer which specifies per-packet size overhead used in
# rate computations. When suffixed with K, M, or G, the specified size is
# parsed as Kilobytes, Megabytes, or Gigabytes, respectively, to the base of
# 1024.
        overhead: ''

# Specifies the maximum rate this class and all its children are guaranteed.
# When suffixed with K, M, or G, the specified size is parsed as Kilobits,
# Megabits, or Gigabits, respectively, to the base of 1000. This setting is
# mandatory.
        rate: '1M'
# Specifies the maximum rate at which a class can send, if its parent has
# bandwidth to spare. When suffixed with K, M, or G the specified size is
# parsed as Kilobits, Megabits, or Gigabits, respectively, to the base of 1000.
# When unset, the value specified with Rate= is used.
        ceil: '0.5M'
# Specifies the maximum bytes burst which can be accumulated during idle period.
# When suffixed with K, M, or G, the specified size is parsed as Kilobytes,
# Megabytes, or Gigabytes, respectively, to the base of 1024.
        burst: '15k'
# Specifies the maximum bytes burst for ceil which can be accumulated during
# idle period. When suffixed with K, M, or G, the specified size is parsed as
# Kilobytes, Megabytes, or Gigabytes, respectively, to the base of 1024.
        cburst: ''
      - parent: 'root'
        classid: '0002:0031'
        prio: '1'
        rate: '1M'
        ceil: '0.5M'
      - parent: 'root'
        classid: '0002:0032'
        prio: '1'
        rate: '1M'
        ceil: '0.5M'
      - parent: 'root'
        classid: '0002:0033'
        prio: '1'
        rate: '1M'
        ceil: '0.5M'
      - parent: 'root'
        classid: '0002:0034'
        prio: '1'
        rate: '1M'
        ceil: '0.5M'
      - parent: 'root'
        classid: '0002:0035'
        prio: '1'
        rate: '1M'
        ceil: '0.5M'
      - parent: 'root'
        classid: '0002:0036'
        prio: '1'
        rate: '1M'
        ceil: '0.5M'
      - parent: 'root'
        classid: '0002:0037'
        prio: '1'
        rate: '1M'
        ceil: '0.5M'
      - parent: 'root'
        classid: '0002:0038'
        prio: '1'
        rate: '1M'
        ceil: '0.5M'
      - parent: 'root'
        classid: '0002:0039'
        prio: '1'
        rate: '1M'
        ceil: '0.5M'
      - parent: 'root'
        classid: '0002:003a'
        prio: '1'
        rate: '1M'
        ceil: '0.5M'
      - parent: 'root'
        classid: '0002:003b'
        prio: '1'
        rate: '1M'
        ceil: '0.5M'
      - parent: 'root'
        classid: '0002:003c'
        prio: '1'
        rate: '1M'
        ceil: '0.5M'
# Manages the queueing discipline (qdisc) of Heavy Hitter Filter (hhf).
      qdisc_hhf:
      - parent: 'root'
        handle: '3a'
# Specifies the hard limit on the queue size in number of packets. When this
# limit is reached, incoming packets are dropped. An unsigned integer ranges 0
# to 4294967294. Defaults to unset and kernel's default is used.
        packet_limit: '1022'
    - name: 'vlan11'
      vlan_id: '11'
      macvlans:
      - name: 'macvlan11'
        address: '10.20.30.1/24'
        mode: 'bridge'
```

## Reference

* https://github.com/k0ste/ansible-role-systemd_helper.git
