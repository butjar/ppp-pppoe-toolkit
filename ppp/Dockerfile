FROM alpine:3.13

RUN set -eux; \
	\
# When pointing the ppp logs to this file, the logs are redirected to the
# stdout of the process with PID 1.
	PPPD_STDOUT_LOG=/var/log/ppp/pppd.stdout.log; \
	\
	apk add --no-cache \
		bash \
		ppp; \
	\
	ln -sf /proc/1/fd/1 "$PPPD_STDOUT_LOG"

COPY etc /etc/

WORKDIR /usr/sbin
