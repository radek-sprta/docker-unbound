#! /bin/sh

CACHE_MIN_TTL=${CACHE_MIN_TTL:-0}
DO_IPV6=${DO_IPV6:-yes}
DO_IPV4=${DO_IPV4:-yes}
DO_UDP=${DO_UDP:-yes}
DO_TCP=${DO_TCP:-yes}
RATELIMIT=${RATELIMIT:-0}
ROOT_HINTS=${ROOT_HINTS:-named}
SO_REUSEPORT=${SO_REUSEPORT:-yes}
SERVE_EXPIRED=${SERVE_EXPIRED:-yes}
STATISTICS_INTERVAL=${STATISTICS_INTERVAL:-0}
STATISTICS_CUMULATIVE=${STATISTICS_CUMULATIVE:-no}
EXTENDED_STATISTICS=${EXTENDED_STATISTICS:-no}
VERBOSITY=${VERBOSITY:-0}

sed 's/{{CACHE_MIN_TTL}}/'"${CACHE_MIN_TTL}"'/' -i /etc/unbound/unbound.conf
sed 's/{{DO_IPV6}}/'"${DO_IPV6}"'/' -i /etc/unbound/unbound.conf
sed 's/{{DO_IPV4}}/'"${DO_IPV4}"'/' -i /etc/unbound/unbound.conf
sed 's/{{DO_UDP}}/'"${DO_UDP}"'/' -i /etc/unbound/unbound.conf
sed 's/{{DO_TCP}}/'"${DO_TCP}"'/' -i /etc/unbound/unbound.conf
sed 's/{{RATELIMIT}}/'"${RATELIMIT}"'/' -i /etc/unbound/unbound.conf
sed 's/{{ROOT_HINTS}}/'"${ROOT_HINTS}"'/' -i /etc/unbound/unbound.conf
sed 's/{{SO_REUSEPORT}}/'"${SO_REUSEPORT}"'/' -i /etc/unbound/unbound.conf
sed 's/{{SERVE_EXPIRED}}/'"${SERVE_EXPIRED}"'/' -i /etc/unbound/unbound.conf
sed 's/{{STATISTICS_INTERVAL}}/'"${STATISTICS_INTERVAL}"'/' -i /etc/unbound/unbound.conf
sed 's/{{STATISTICS_CUMULATIVE}}/'"${STATISTICS_CUMULATIVE}"'/' -i /etc/unbound/unbound.conf
sed 's/{{EXTENDED_STATISTICS}}/'"${EXTENDED_STATISTICS}"'/' -i /etc/unbound/unbound.conf
sed 's/{{VERBOSITY}}/'"${VERBOSITY}"'/' -i /etc/unbound/unbound.conf

exec /usr/sbin/unbound -c /etc/unbound/unbound.conf -d -v
