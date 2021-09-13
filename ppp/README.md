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
