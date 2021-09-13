ppp
===

The `ppp` image ships with the
[ppp meta package](https://git.alpinelinux.org/aports/tree/main/ppp)
installed that pulls in several subpackages. Most notably the subpackage
`ppp-daemon` provides
[Paul's PPP Package](https://ppp.samba.org/).

The subpackage `ppp-pppoe` provides the `rp-pppoe.so` kernel module and the
binary `pppoe-discovery`.

To allow pre-configuration of network devices the [ifupdown-ng
package](https://git.alpinelinux.org/aports/tree/main/ifupdown-ng) is
installed.

> [ifupdown-ng](https://github.com/ifupdown-ng/ifupdown-ng) is a network device
> manager that is largely compatible with Debian ifupdown, BusyBox ifupdown and
> Cumulus Networks' ifupdown2.

By default, the environment variable `IFUPDOWN_NG_IFACES` in the `ppp` image
points to the default `ifupdown-ng` configuration file path
`/etc/network/interfaces`. On container startup the
[`docker-entrypoint.sh`](./docker-entrypoint.sh) script is executed which
applies the configuration in the file `IFUPDOWN_NG_IFACES` points to (if it
exists). You can point `IFUPDOWN_NG_IFACES` to one of the example
configurations in [/etc/network/](./etc/network). However, you can also [bind
mount](https://docs.docker.com/storage/bind-mounts/) a custom configuration to
`/etc/network/interfaces` which will be applied on startup.

Usage
-----

### `pppd`

A simple way to get started is spawning a container that runs `pppd`:

```
$ docker run  --cap-add=NET_ADMIN --device /dev/ppp:/dev/ppp -ti ppp pppd call default nodetach maxfail 1 maxconnect 5

Plugin rp-pppoe.so loaded.
RP-PPPoE plugin version 3.8p compiled against pppd 2.4.8
Send PPPOE Discovery V1T1 PADI session 0x0 length 12
 dst ff:ff:ff:ff:ff:ff  src 02:42:ac:11:00:02
 [service-name] [host-uniq  01 00 00 00]
Send PPPOE Discovery V1T1 PADI session 0x0 length 12
 dst ff:ff:ff:ff:ff:ff  src 02:42:ac:11:00:02
 [service-name] [host-uniq  01 00 00 00]
Send PPPOE Discovery V1T1 PADI session 0x0 length 12
 dst ff:ff:ff:ff:ff:ff  src 02:42:ac:11:00:02
 [service-name] [host-uniq  01 00 00 00]
Timeout waiting for PADO packets
Unable to complete PPPoE Discovery
```

In another terminal window, you can inspect the `PPPoE` discovery `PADI`s on
the docker bridge:

```
$ sudo tcpdump -vneli docker0 pppoed

tcpdump: listening on docker0, link-type EN10MB (Ethernet), capture size 262144 bytes
18:46:03.689540 02:42:ac:11:00:02 > ff:ff:ff:ff:ff:ff, ethertype PPPoE D (0x8863), length 32: PPPoE PADI [Service-Name] [Host-Uniq 0x01000000]
18:46:08.695125 02:42:ac:11:00:02 > ff:ff:ff:ff:ff:ff, ethertype PPPoE D (0x8863), length 32: PPPoE PADI [Service-Name] [Host-Uniq 0x01000000]
18:46:18.699044 02:42:ac:11:00:02 > ff:ff:ff:ff:ff:ff, ethertype PPPoE D (0x8863), length 32: PPPoE PADI [Service-Name] [Host-Uniq 0x01000000]
```

Note, `pppd` reads the system default options options from the
`/etc/ppp/options` file. The `call default` option instructs `pppd` to read
some additional provider specific options from the file
`/etc/ppp/peers/default`. The following options are passed directly to `pppd`:

- `nodetach`:
  > Don't detach from the controlling terminal. Without this option, if a
  > serial device other than the terminal on the standard input is specified,
  > pppd will fork to become a background process.
- `maxfail n`:
  > Terminate after n consecutive failed connection attempts. A value of 0
  > means no limit. The default value is 10.
- `maxconnect n`:
  > Terminate the connection when it has been available for network traffic for
  > n seconds (i.e. n seconds after the first network control protocol comes
  > up).

For a complete list of available option consult [the pppd man
page](https://ppp.samba.org/pppd.html).

### `pppoe-discovery`

Maybe even simpler than `pppd` is starting a dockerized `pppoe-discovery`:

```
$ docker run  --cap-add=NET_ADMIN --device /dev/ppp:/dev/ppp -ti ppp pppoe-discovery

Timeout waiting for PADO packets
```

Sniffing on the docker bridge reveals pretty similar results:

```
$ sudo tcpdump -vneli docker0 pppoed

tcpdump: listening on docker0, link-type EN10MB (Ethernet), capture size 262144 bytes
18:56:11.629395 02:42:ac:11:00:02 > ff:ff:ff:ff:ff:ff, ethertype PPPoE D (0x8863), length 24: PPPoE PADI [Service-Name]
18:56:16.633966 02:42:ac:11:00:02 > ff:ff:ff:ff:ff:ff, ethertype PPPoE D (0x8863), length 24: PPPoE PADI [Service-Name]
18:56:21.637221 02:42:ac:11:00:02 > ff:ff:ff:ff:ff:ff, ethertype PPPoE D (0x8863), length 24: PPPoE PADI [Service-Name]
```

### ifupdown-ng

The `ppp` image ships with `ifupdown-ng` so you can apply a network device
configuration on container startup. The easiest way to do so is pointing
`IFUPDOWN_NG_IFACES` to one of the example files. For instance, to create a
vlan interface on startup you can point the variable to
[`/etc/network/interfaces.vlan`](./etc/network/interfaces.vlan):

```
$ docker run --rm -ti --cap-add=NET_ADMIN -e IFUPDOWN_NG_IFACES=/etc/network/interfaces.vlan ppp ip a

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0.50@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN qlen 1000
    link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff
1007: eth0@if1008: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue state UP
    link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.2/16 brd 172.17.255.255 scope global eth0
       valid_lft forever preferred_lft forever
```

This might be helpful if your access concentrator expects VLAN tagged traffic.
For instance, to run a tagged `PPPoE` discovery you can run the following command:

```
$ docker run --rm -ti --cap-add=NET_ADMIN -e IFUPDOWN_NG_IFACES=/etc/network/interfaces.vlan ppp pppoe-discovery -I eth0.50

Timeout waiting for PADO packets
```

A `tcpdump` on the docker bridge shows that the `PADI` packets have been
tagged:

```
$ sudo tcpdump -vneli docker0 pppoed && pppoes

tcpdump: listening on docker0, link-type EN10MB (Ethernet), capture size 262144 bytes
22:57:52.921506 02:42:ac:11:00:02 > ff:ff:ff:ff:ff:ff, ethertype 802.1Q (0x8100), length 28: vlan 50, p 0, ethertype PPPoE D, PPPoE PADI [Service-Name]
22:57:57.926085 02:42:ac:11:00:02 > ff:ff:ff:ff:ff:ff, ethertype 802.1Q (0x8100), length 28: vlan 50, p 0, ethertype PPPoE D, PPPoE PADI [Service-Name]
22:58:02.931302 02:42:ac:11:00:02 > ff:ff:ff:ff:ff:ff, ethertype 802.1Q (0x8100), length 28: vlan 50, p 0, ethertype PPPoE D, PPPoE PADI [Service-Name]
```

In a similar way, stacked VLAN tags can be added to the discovery using the
[interfaces.qinq](./etc/network/interfaces.qinq) configuration file:

```
$ docker run --rm -ti --cap-add=NET_ADMIN -e IFUPDOWN_NG_IFACES=/etc/network/interfaces.qinq ppp /bin/bash -c "ip a; printf '\n\n'; pppoe-discovery -I eth0.50.100"

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0.50@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN qlen 1000
    link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff
3: eth0.50.100@eth0.50: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN qlen 1000
    link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff
1037: eth0@if1038: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue state UP
    link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.2/16 brd 172.17.255.255 scope global eth0
       valid_lft forever preferred_lft forever


Timeout waiting for PADO packets
```

```
$ sudo tcpdump -vneli docker0 vlan

tcpdump: listening on docker0, link-type EN10MB (Ethernet), capture size 262144 bytes
23:17:36.021473 02:42:ac:11:00:02 > ff:ff:ff:ff:ff:ff, ethertype 802.1Q-QinQ (0x88a8), length 32: vlan 50, p 0, ethertype 802.1Q, vlan 100, p 0, ethertype PPPoE D, PPPoE PADI [Service-Name]
23:17:41.025467 02:42:ac:11:00:02 > ff:ff:ff:ff:ff:ff, ethertype 802.1Q-QinQ (0x88a8), length 32: vlan 50, p 0, ethertype 802.1Q, vlan 100, p 0, ethertype PPPoE D, PPPoE PADI [Service-Name]
23:17:46.029358 02:42:ac:11:00:02 > ff:ff:ff:ff:ff:ff, ethertype 802.1Q-QinQ (0x88a8), length 32: vlan 50, p 0, ethertype 802.1Q, vlan 100, p 0, ethertype PPPoE D, PPPoE PADI [Service-Name]
```

The [`interfaces.ppp`](./etc/network/interfaces.ppp) example configuration
shows how a `ppp` device can be brought up on startup with `ifupdown-ng`. Such
connection will be retained until either client or server terminate the
connection. The session establishment can be demonstrated in conjunction with a
[`rp-pppoe`](../rp-pppoe) container:

First, start a `pppoe-server` in a separate terminal window:

```
$ docker run --cap-add=NET_ADMIN --device /dev/ppp:/dev/ppp --rm -ti rp-pppoe
```

Then start a `ppp` container with the `interfaces.ppp` configuration. The
following output from the client stdout displays:

1. A PPPoE session is established
2. A new interface `ppp0` was created
3. The `pppoe-server` can be pinged
4. Calling `ifdown` with `interfaces.ppp` will terminate the session

```
$ docker run --rm -ti --cap-add=NET_ADMIN --device /dev/ppp:/dev/ppp -e IFUPDOWN_NG_IFACES=/etc/network/interfaces.ppp ppp /bin/bash

Plugin rp-pppoe.so loaded.
RP-PPPoE plugin version 3.8p compiled against pppd 2.4.8
bash-5.1# Send PPPOE Discovery V1T1 PADI session 0x0 length 12
 dst ff:ff:ff:ff:ff:ff  src 02:42:ac:11:00:03
 [service-name] [host-uniq  19 00 00 00]
Recv PPPOE Discovery V1T1 PADO session 0x0 length 52
 dst 02:42:ac:11:00:03  src 02:42:ac:11:00:02
 [AC-name ea3bfeb50234] [service-name] [AC-cookie  13 64 36 c8 b4 74 5c 6e cc fd f3 38 a1 9f cb 88 01 00 00 00] [host-uniq  19 00 00 00]
Send PPPOE Discovery V1T1 PADR session 0x0 length 36
 dst 02:42:ac:11:00:02  src 02:42:ac:11:00:03
 [service-name] [host-uniq  19 00 00 00] [AC-cookie  13 64 36 c8 b4 74 5c 6e cc fd f3 38 a1 9f cb 88 01 00 00 00]
Recv PPPOE Discovery V1T1 PADS session 0x1 length 12
 dst 02:42:ac:11:00:03  src 02:42:ac:11:00:02
 [service-name] [host-uniq  19 00 00 00]
PADS: Service-Name: ''
PPP session is 1
Connected to 02:42:ac:11:00:02 via interface eth0
using channel 1
Using interface ppp0
Connect: ppp0 <--> eth0
sent [LCP ConfReq id=0x1 <mru 1492> <magic 0xe697e586>]
rcvd [LCP ConfReq id=0x1 <mru 1492> <magic 0x210aed8d>]
sent [LCP ConfAck id=0x1 <mru 1492> <magic 0x210aed8d>]
sent [LCP ConfReq id=0x1 <mru 1492> <magic 0xe697e586>]
rcvd [LCP ConfAck id=0x1 <mru 1492> <magic 0xe697e586>]
peer from calling number 02:42:AC:11:00:02 authorized
sent [IPCP ConfReq id=0x1 <addr 172.17.0.3>]
rcvd [LCP EchoReq id=0x0 magic=0x210aed8d]
sent [LCP EchoRep id=0x0 magic=0xe697e586]
rcvd [CCP ConfReq id=0x1 <deflate 15> <deflate(old#) 15> <bsd v1 15>]
sent [CCP ConfReq id=0x1]
sent [CCP ConfRej id=0x1 <deflate 15> <deflate(old#) 15> <bsd v1 15>]
rcvd [IPCP ConfReq id=0x1 <compress VJ 0f 01> <addr 10.0.0.1>]
sent [IPCP ConfRej id=0x1 <compress VJ 0f 01>]
rcvd [IPCP ConfNak id=0x1 <addr 10.67.15.1>]
sent [IPCP ConfReq id=0x2 <addr 10.67.15.1>]
rcvd [CCP ConfAck id=0x1]
rcvd [CCP ConfReq id=0x2]
sent [CCP ConfAck id=0x2]
rcvd [IPCP ConfReq id=0x2 <addr 10.0.0.1>]
sent [IPCP ConfAck id=0x2 <addr 10.0.0.1>]
rcvd [IPCP ConfAck id=0x2 <addr 10.67.15.1>]
not replacing existing default route via 172.17.0.1 with metric -1
local  IP address 10.67.15.1
remote IP address 10.0.0.1
Script /etc/ppp/ip-up started (pid 39)
Script /etc/ppp/ip-up finished (pid 39), status = 0x0


bash-5.1# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: ppp0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1492 qdisc fq_codel state UNKNOWN qlen 3
    link/ppp
    inet 10.67.15.1 peer 10.0.0.1/32 scope global ppp0
       valid_lft forever preferred_lft forever
1059: eth0@if1060: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue state UP
    link/ether 02:42:ac:11:00:03 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.3/16 brd 172.17.255.255 scope global eth0
       valid_lft forever preferred_lft forever


bash-5.1# ping -c3 10.0.0.1
PING 10.0.0.1 (10.0.0.1): 56 data bytes
64 bytes from 10.0.0.1: seq=0 ttl=64 time=0.496 ms
64 bytes from 10.0.0.1: seq=1 ttl=64 time=0.715 ms
64 bytes from 10.0.0.1: seq=2 ttl=64 time=0.952 ms

--- 10.0.0.1 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.496/0.721/0.952 ms


bash-5.1# ifdown -afi /etc/network/interfaces.ppp
Terminating on signal 15
Connect time 0.9 minutes.
Sent 252 bytes, received 252 bytes.
Script /etc/ppp/ip-down started (pid 76)
sent [LCP TermReq id=0x2 "User request"]
Script /etc/ppp/ip-down finished (pid 76), status = 0x0
rcvd [LCP TermAck id=0x2]
Connection terminated.
Send PPPOE Discovery V1T1 PADT session 0x1 length 32
 dst 02:42:ac:11:00:02  src 02:42:ac:11:00:03
 [host-uniq  19 00 00 00] [AC-cookie  13 64 36 c8 b4 74 5c 6e cc fd f3 38 a1 9f cb 88 01 00 00 00]
Sent PADT
```
