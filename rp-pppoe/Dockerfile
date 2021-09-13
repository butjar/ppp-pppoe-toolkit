FROM ppp

RUN set -eux; \
	\
# When pointing the rp-pppoe logs to this file, the logs are redirected to the
# stdout of the process with PID 1.
	RP_PPPOE_PPPD_STDOUT_LOG=/var/log/ppp/rp-pppoe-pppd.stdout.log; \
	\
	apk add --no-cache \
		rp-pppoe \
	\
	&& ln -sf /proc/1/fd/1 "$RP_PPPOE_PPPD_STDOUT_LOG"

COPY etc /etc/
WORKDIR /usr/sbin

CMD ["pppoe-server", "-F"]
