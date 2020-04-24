#!/usr/bin/env bash

set -e

dnsdist --disable-syslog --uid pdns --gid pdns <<EOF | grep setKey > /etc/dnsdist/dnsdist.conf
makeKey()
EOF

echo 'controlSocket("127.0.0.1")' >> /etc/dnsdist/dnsdist.conf
echo "${DNSDIST_CONFIG}" >> /etc/dnsdist/dnsdist.conf

exec dnsdist --disable-syslog --uid pdns --gid pdns "${@}"
