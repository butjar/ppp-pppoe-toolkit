ppp-pppoe-toolkit
=================

The `ppp-pppoe-toolkit` provides a set of docker images that are useful for
debugging applications based on the
[PPP](https://datatracker.ietf.org/doc/html/rfc1661)/[PPPoE](https://datatracker.ietf.org/doc/html/rfc2516)
protocols. The toolkit provides also a playground to learn about the protocols.

Images
------

### Build

The image builds are automated using
[`make`](https://www.gnu.org/software/make/). Each image are build in its own
subsystem. The `Makefile` in the root directory initiates the recusion for all
images. Simply call `make` in the root directory to build all images contained
in the `ppp-pppoe-toolkit`. To build only a single image, you can step in the
according subdirectory and call `make` from there. For example, to build the
`ppp` base image only:

```
$ cd ppp
$ make
```

### Kit

This section introduces the images contained in the `ppp-pppoe-toolkit`.

#### ppp
[`ppp`](./ppp) is a tiny [alpine](https://hub.docker.com/_/alpine) based base
image that provides basic `PPP`/`PPPoE` tools.
