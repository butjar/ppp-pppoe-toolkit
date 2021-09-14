FROM alpine:3.13

ENV IFUPDOWN_NG_IFACES /etc/network/interfaces

RUN set -eux; \
	\
# When pointing the ppp logs to this file, the logs are redirected to the
# stdout of the process with PID 1.
	PPPD_STDOUT_LOG=/var/log/ppp/pppd.stdout.log; \
	IFUPDOWN_NG_VXLAN_EXECUTOR_URL=https://raw.githubusercontent.com/ifupdown-ng/ifupdown-ng/main/executor-scripts/linux/vxlan; \
	\
	apk add --no-cache \
		bash \
		ifupdown-ng \
		ifupdown-ng-ppp \
		iproute2 \
		ppp; \
	\
	wget -O /usr/libexec/ifupdown-ng/vxlan "$IFUPDOWN_NG_VXLAN_EXECUTOR_URL"; \
	chmod +x /usr/libexec/ifupdown-ng/vxlan; \
	ln -sf /proc/1/fd/1 "$PPPD_STDOUT_LOG"

COPY etc /etc/
COPY usr /usr/
COPY docker-entrypoint.sh /usr/local/bin/

WORKDIR /usr/sbin
ENTRYPOINT ["docker-entrypoint.sh"]
