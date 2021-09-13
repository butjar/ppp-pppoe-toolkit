ppp
===

The `ppp` image ships with the
[ppp meta package](https://git.alpinelinux.org/aports/tree/main/ppp)
installed that pulls in several subpackages. Most notably the subpackage
`ppp-daemon` provides
[Paul's PPP Package](https://ppp.samba.org/).

The subpackage `ppp-pppoe` provides the `rp-pppoe.so` kernel module and the
binary `pppoe-discovery`.

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
