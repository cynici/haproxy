#!/bin/sh
set -ux
rm -f /var/run/rsyslogd.pid
rsyslogd
if [ -n "${RUNUSER_UID:-}" ]; then
    adduser -s /bin/false -D -h "${RUNUSER_HOME:-/usr/local/etc/haproxy}" -H -u ${RUNUSER_UID} haproxy
fi
exec /docker-entrypoint.sh "$@"
