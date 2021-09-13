#!/usr/bin/env bash
set -euo pipefail

if [[ -f "$IFUPDOWN_NG_IFACES" ]]; then
    ifup -ai "$IFUPDOWN_NG_IFACES" >/var/log/ifup-ng.log 2>&1
fi

exec "$@"
