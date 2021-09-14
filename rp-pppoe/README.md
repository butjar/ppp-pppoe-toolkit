rp-pppoe
========

The `rp-pppoe` image builds on top of [`ppp`](../ppp). It installs the
[rp-pppoe package](https://git.alpinelinux.org/aports/tree/main/rp-pppoe) on
top of `ppp` and provides some reasonable default configuration in the
[pppoe-server-options](./etc/ppp/pppoe-server-options) that work with the
`pppd` configuration of the base image out-of-the-box.

`rp-pppoe` packages [RP-PPPoE](https://dianne.skoll.ca/projects/rp-pppoe/):
> RP-PPPoE is a free PPPoE client, relay and server for Linux.

The `pppoe-server` binary can be used in conjunction with `pppd` to test server
and client configurations.

> Note that pppoe-server is meant mainly for testing PPPoE clients. It is not a
> high-performance server meant for production use.

Usage
-----

### `pppoe-server`

By default, a `rp-pppoe` container executes `pppoe-server` in foreground (`-F`
argument is passed). You can simply start a dockerized `pppoe-server`:

```
$ docker run --cap-add=NET_ADMIN --device /dev/ppp:/dev/ppp --rm -ti butjar/rp-pppoe
```

Following the [pppd usage example](../ppp/README.md#pppd) you can than
establish a dockerized ppp session from another terminal window:

```
$ docker run  --cap-add=NET_ADMIN --device /dev/ppp:/dev/ppp -ti butjar/ppp pppd call default nodetach maxfail 1 maxconnect 5

Plugin rp-pppoe.so loaded.
RP-PPPoE plugin version 3.8p compiled against pppd 2.4.8
Send PPPOE Discovery V1T1 PADI session 0x0 length 12
 dst ff:ff:ff:ff:ff:ff  src 02:42:ac:11:00:03
 [service-name] [host-uniq  01 00 00 00]
Recv PPPOE Discovery V1T1 PADO session 0x0 length 52
 dst 02:42:ac:11:00:03  src 02:42:ac:11:00:02
 [AC-name 72fce88bb555] [service-name] [AC-cookie  f4 d9 01 74 43 dc 1c 72 b1 2f db a0 7a 7a 0a 72 01 00 00 00] [host-uniq  01 00 00 00]
Send PPPOE Discovery V1T1 PADR session 0x0 length 36
 dst 02:42:ac:11:00:02  src 02:42:ac:11:00:03
 [service-name] [host-uniq  01 00 00 00] [AC-cookie  f4 d9 01 74 43 dc 1c 72 b1 2f db a0 7a 7a 0a 72 01 00 00 00]
Recv PPPOE Discovery V1T1 PADS session 0x1 length 12
 dst 02:42:ac:11:00:03  src 02:42:ac:11:00:02
 [service-name] [host-uniq  01 00 00 00]
PADS: Service-Name: ''
PPP session is 1
Connected to 02:42:ac:11:00:02 via interface eth0
using channel 1
Using interface ppp0
Connect: ppp0 <--> eth0
sent [LCP ConfReq id=0x1 <mru 1492> <magic 0xd1f69953>]
rcvd [LCP ConfReq id=0x1 <mru 1492> <magic 0x7e287049>]
sent [LCP ConfAck id=0x1 <mru 1492> <magic 0x7e287049>]
sent [LCP ConfReq id=0x1 <mru 1492> <magic 0xd1f69953>]
rcvd [LCP ConfAck id=0x1 <mru 1492> <magic 0xd1f69953>]
peer from calling number 02:42:AC:11:00:02 authorized
sent [IPCP ConfReq id=0x1 <addr 172.17.0.3>]
rcvd [LCP EchoReq id=0x0 magic=0x7e287049]
sent [LCP EchoRep id=0x0 magic=0xd1f69953]
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
Script /etc/ppp/ip-up started (pid 7)
Script /etc/ppp/ip-up finished (pid 7), status = 0x0
Connect time expired
Connect time 0.1 minutes.
Sent 0 bytes, received 0 bytes.
Script /etc/ppp/ip-down started (pid 8)
sent [LCP TermReq id=0x2 "Connect time expired"]
rcvd [LCP TermAck id=0x2]
Connection terminated.
Send PPPOE Discovery V1T1 PADT session 0x1 length 32
 dst 02:42:ac:11:00:02  src 02:42:ac:11:00:03
 [host-uniq  01 00 00 00] [AC-cookie  f4 d9 01 74 43 dc 1c 72 b1 2f db a0 7a 7a 0a 72 01 00 00 00]
Sent PADT
Script /etc/ppp/ip-down finished (pid 8), status = 0x0
```

The `maxconnect` option will force `pppd` to shutdown the session after 5
seconds.

By default the `debug` option in `/etc/ppp/options` is enabled, producing
verbose pppd logs. Under the hood `rp-pppoe` uses `pppd` for session
establishment an retention. Therefore, the system wide default options also
apply for `pppoe-server`. The verbose `stdout` of the `rp-pppoe` container
looks the following:

```
$ docker run --cap-add=NET_ADMIN --device /dev/ppp:/dev/ppp --rm -ti butjar/rp-pppoe

using channel 1
Using interface ppp0
Connect: ppp0 <--> /dev/pts/1
sent [LCP ConfReq id=0x1 <mru 1492> <magic 0x7e287049>]
rcvd [LCP ConfAck id=0x1 <mru 1492> <magic 0x7e287049>]
rcvd [LCP ConfReq id=0x1 <mru 1492> <magic 0xd1f69953>]
sent [LCP ConfAck id=0x1 <mru 1492> <magic 0xd1f69953>]
sent [LCP EchoReq id=0x0 magic=0x7e287049]
sent [CCP ConfReq id=0x1 <deflate 15> <deflate(old#) 15> <bsd v1 15>]
sent [IPCP ConfReq id=0x1 <compress VJ 0f 01> <addr 10.0.0.1>]
rcvd [LCP EchoRep id=0x0 magic=0xd1f69953]
rcvd [IPCP ConfReq id=0x1 <addr 172.17.0.3>]
sent [IPCP ConfNak id=0x1 <addr 10.67.15.1>]
rcvd [CCP ConfReq id=0x1]
sent [CCP ConfAck id=0x1]
rcvd [CCP ConfRej id=0x1 <deflate 15> <deflate(old#) 15> <bsd v1 15>]
sent [CCP ConfReq id=0x2]
rcvd [IPCP ConfRej id=0x1 <compress VJ 0f 01>]
sent [IPCP ConfReq id=0x2 <addr 10.0.0.1>]
rcvd [IPCP ConfReq id=0x2 <addr 10.67.15.1>]
sent [IPCP ConfAck id=0x2 <addr 10.67.15.1>]
rcvd [CCP ConfAck id=0x2]
rcvd [IPCP ConfAck id=0x2 <addr 10.0.0.1>]
local  IP address 10.0.0.1
remote IP address 10.67.15.1
Script /etc/ppp/ip-up started (pid 9)
Script /etc/ppp/ip-up finished (pid 9), status = 0x0
rcvd [LCP TermReq id=0x2 "Connect time expired"]
LCP terminated by peer (Connect time expired)
Connect time 0.1 minutes.
Sent 0 bytes, received 0 bytes.
Script /etc/ppp/ip-down started (pid 10)
sent [LCP TermAck id=0x2]
Script /etc/ppp/ip-down finished (pid 10), status = 0x0
PADT: Generic-Error:
PADT: Generic-Error: tCr/۠zz
r
Terminating on signal 15
Connection terminated.
pppoe: read (asyncReadFromPPP): Session 1: I/O error
Modem hangup
Waiting for 1 child processes...
  script /usr/sbin/pppoe -n -I eth0 -e 1:02:42:ac:11:00:03 -S '', pid 8
Script /usr/sbin/pppoe -n -I eth0 -e 1:02:42:ac:11:00:03 -S '' finished (pid 8), status = 0x1
```

When sniffing the docker bridge during the session establishment, the entire
PPPoE handshake can be watched:

```
$ sudo tcpdump -vneli docker0 pppoed && pppoes

tcpdump: listening on docker0, link-type EN10MB (Ethernet), capture size 262144 bytes
21:34:27.877313 02:42:ac:11:00:03 > ff:ff:ff:ff:ff:ff, ethertype PPPoE D (0x8863), length 32: PPPoE PADI [Service-Name] [Host-Uniq 0x01000000]
21:34:27.877395 02:42:ac:11:00:02 > 02:42:ac:11:00:03, ethertype PPPoE D (0x8863), length 72: PPPoE PADO [AC-Name "72fce88bb555"] [Service-Name] [AC-Cookie 0xF4D9017443DC1C72B12FDBA07A7A0A7201000000] [Host-Uniq 0x01000000]
21:34:27.877583 02:42:ac:11:00:03 > 02:42:ac:11:00:02, ethertype PPPoE D (0x8863), length 56: PPPoE PADR [Service-Name] [Host-Uniq 0x01000000] [AC-Cookie 0xF4D9017443DC1C72B12FDBA07A7A0A7201000000]
21:34:27.877835 02:42:ac:11:00:02 > 02:42:ac:11:00:03, ethertype PPPoE D (0x8863), length 32: PPPoE PADS [ses 0x1] [Service-Name] [Host-Uniq 0x01000000]
21:34:35.917860 02:42:ac:11:00:03 > 02:42:ac:11:00:02, ethertype PPPoE D (0x8863), length 52: PPPoE PADT [ses 0x1] [Host-Uniq 0x01000000] [AC-Cookie 0xF4D9017443DC1C72B12FDBA07A7A0A7201000000]
21:34:35.918190 02:42:ac:11:00:02 > 02:42:ac:11:00:03, ethertype PPPoE D (0x8863), length 37: PPPoE PADT [ses 0x1] [Generic-Error "Received PADT"]
```
