#! /bin/sh

calculate_cache_slabs() {
  # Calculate power of 2 close to the number of threads
  if [ "${NUM_THREADS}" -gt 1 ]; then
    # Calculate base 2 logarithm of number of threads
    power=$(echo "l(${NUM_THREADS})/l(2)" | bc -l)
    # Round the result
    rounded_power=$(printf "%.0f" "${power}")
    # 2 the power of the calculated number
    echo "2^${rounded_power}" | bc
  else
    # Default value
    echo 4
  fi
}

calculate_available_memory() {
  reserved=12582912
  available=$(free -b | grep Mem: | awk '{print $7}')
  if [ "${available}" -le $((reserved * 2)) ]; then
    echo "Not enough memory" >&2
    exit 1
  fi
  echo $((available - reserved))
}

# Performance variables
NUM_THREADS=$(nproc)
CACHE_SLABS=$(calculate_cache_slabs)
RRSET_CACHE_SIZE=$(($(calculate_available_memory) / 3))
MSG_CACHE_SIZE=$(($(calculate_available_memory) / 6))

# Configurable variables
CACHE_MIN_TTL=${CACHE_MIN_TTL:-0}
CONTROL_CERT=${CONTROL_CERT:-/etc/unbound/unbound_control.pem}
CONTROL_KEY=${CONTROL_KEY:-/etc/unbound/unbound_control.key}
DO_IPV4=${DO_IPV4:-yes}
DO_IPV6=${DO_IPV6:-no}
DO_TCP=${DO_TCP:-yes}
DO_UDP=${DO_UDP:-yes}
EXTENDED_STATISTICS=${EXTENDED_STATISTICS:-no}
RATELIMIT=${RATELIMIT:-0}
REMOTECONTROL=${REMOTECONTROL:-no}
ROOT_HINTS=${ROOT_HINTS:-icann}
SERVER_CERT=${SERVER_CERT:-/etc/unbound/unbound_server.pem}
SERVER_KEY=${SERVER_KEY:-/etc/unbound/unbound_server.key}
SERVE_EXPIRED=${SERVE_EXPIRED:-yes}
SO_REUSEPORT=${SO_REUSEPORT:-yes}
STATISTICS_CUMULATIVE=${STATISTICS_CUMULATIVE:-no}
STATISTICS_INTERVAL=${STATISTICS_INTERVAL:-0}
VERBOSITY=${VERBOSITY:-0}

sed 's/{{CACHE_MIN_TTL}}/'"${CACHE_MIN_TTL}"'/' -i /etc/unbound/unbound.conf
sed 's/{{CACHE_SLABS}}/'"${CACHE_SLABS}"'/' -i /etc/unbound/unbound.conf
sed 's#{{CONTROL_CERT}}#'"${CONTROL_CERT}"'#' -i /etc/unbound/unbound.conf
sed 's#{{CONTROL_KEY}}#'"${CONTROL_KEY}"'#' -i /etc/unbound/unbound.conf
sed 's/{{DO_IPV4}}/'"${DO_IPV4}"'/' -i /etc/unbound/unbound.conf
sed 's/{{DO_IPV6}}/'"${DO_IPV6}"'/' -i /etc/unbound/unbound.conf
sed 's/{{DO_TCP}}/'"${DO_TCP}"'/' -i /etc/unbound/unbound.conf
sed 's/{{DO_UDP}}/'"${DO_UDP}"'/' -i /etc/unbound/unbound.conf
sed 's/{{EXTENDED_STATISTICS}}/'"${EXTENDED_STATISTICS}"'/' -i /etc/unbound/unbound.conf
sed 's/{{MSG_CACHE_SIZE}}/'"${MSG_CACHE_SIZE}"'/' -i /etc/unbound/unbound.conf
sed 's/{{NUM_THREADS}}/'"${NUM_THREADS}"'/' -i /etc/unbound/unbound.conf
sed 's/{{RATELIMIT}}/'"${RATELIMIT}"'/' -i /etc/unbound/unbound.conf
sed 's/{{REMOTECONTROL}}/'"${REMOTECONTROL}"'/' -i /etc/unbound/unbound.conf
sed 's/{{ROOT_HINTS}}/'"${ROOT_HINTS}"'/' -i /etc/unbound/unbound.conf
sed 's/{{RRSET_CACHE_SIZE}}/'"${RRSET_CACHE_SIZE}"'/' -i /etc/unbound/unbound.conf
sed 's#{{SERVER_CERT}}#'"${SERVER_CERT}"'#' -i /etc/unbound/unbound.conf
sed 's#{{SERVER_KEY}}#'"${SERVER_KEY}"'#' -i /etc/unbound/unbound.conf
sed 's/{{SERVE_EXPIRED}}/'"${SERVE_EXPIRED}"'/' -i /etc/unbound/unbound.conf
sed 's/{{SO_REUSEPORT}}/'"${SO_REUSEPORT}"'/' -i /etc/unbound/unbound.conf
sed 's/{{STATISTICS_CUMULATIVE}}/'"${STATISTICS_CUMULATIVE}"'/' -i /etc/unbound/unbound.conf
sed 's/{{STATISTICS_INTERVAL}}/'"${STATISTICS_INTERVAL}"'/' -i /etc/unbound/unbound.conf
sed 's/{{VERBOSITY}}/'"${VERBOSITY}"'/' -i /etc/unbound/unbound.conf

exec /usr/sbin/unbound -c /etc/unbound/unbound.conf -d -v
