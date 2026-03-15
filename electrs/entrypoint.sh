#!/bin/sh
set -eu

die() {
  echo "$1" >&2
  exit 1
}

elements_conf_value() {
  key="$1"
  conf_dir="${ELEMENTS_CONF_DIR:-/mnt/elements}"
  conf_path="${conf_dir}/elements.conf"

  if [ ! -f "$conf_path" ]; then
    return 1
  fi

  awk -F= -v lookup_key="$key" '
    /^[[:space:]]*#/ { next }
    NF >= 2 {
      raw_key = $1
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", raw_key)

      if (raw_key == lookup_key) {
        sub(/^[^=]*=/, "", $0)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0)
        print $0
        exit
      }
    }
  ' "$conf_path"
}

normalize_host() {
  host="$1"
  host="${host#http://}"
  host="${host#https://}"
  host="${host%%/*}"
  host="${host%%:*}"
  printf "%s" "$host"
}

ELEMENTS_HOST="${ELEMENTS_HOST:-http://elements_node_1}"
ELEMENTS_PORT="${ELEMENTS_PORT:-}"
ELEMENTS_USER="${ELEMENTS_USER:-elements}"
ELEMENTS_PASS="${ELEMENTS_PASS:-}"
ELEMENTS_CONF_DIR="${ELEMENTS_CONF_DIR:-/mnt/elements}"

if [ -z "$ELEMENTS_PASS" ]; then
  ELEMENTS_PASS="$(elements_conf_value rpcpassword || true)"
fi

ELEMENTS_HOST="$(normalize_host "$ELEMENTS_HOST")"

if [ -z "$ELEMENTS_PORT" ]; then
  die "Missing Elements RPC port. Set ELEMENTS_PORT from Umbrel APP_ELEMENTS_NODE_RPC_PORT."
fi

if [ -z "$ELEMENTS_PASS" ]; then
  die "Missing Elements RPC password. Derive APP_ELEMENTS_RPC_PASS in liquid-electrs exports.sh or mount elements.conf with rpcpassword."
fi

COOKIE="${ELEMENTS_USER}:${ELEMENTS_PASS}"
LOG_LEVEL="${ELECTRS_LOG_LEVEL:-vv}"
BANNER="${ELECTRS_BANNER:-Umbrel Liquid Electrs}"
DAEMON_PARALLELISM="${ELECTRS_DAEMON_PARALLELISM:-1}"
DB_PARALLELISM="${ELECTRS_DB_PARALLELISM:-1}"
DB_WRITE_BUFFER_SIZE_MB="${ELECTRS_DB_WRITE_BUFFER_SIZE_MB:-64}"
DB_BLOCK_CACHE_MB="${ELECTRS_DB_BLOCK_CACHE_MB:-8}"

mkdir -p /data/electrs_liquid_db

# Umbrel hardware is resource constrained, so keep light mode on and do not
# enable address search indexing.
set +e
/usr/local/bin/electrs \
  -"${LOG_LEVEL}" \
  --timestamp \
  --network liquid \
  --parent-network bitcoin \
  --daemon-dir "${ELEMENTS_CONF_DIR}" \
  --daemon-rpc-addr "${ELEMENTS_HOST}:${ELEMENTS_PORT}" \
  --daemon-parallelism "${DAEMON_PARALLELISM}" \
  --cookie "${COOKIE}" \
  --jsonrpc-import \
  --lightmode \
  --electrum-rpc-addr 0.0.0.0:50001 \
  --monitoring-addr 0.0.0.0:4224 \
  --db-dir /data/electrs_liquid_db/mainnet \
  --db-parallelism "${DB_PARALLELISM}" \
  --db-write-buffer-size-mb "${DB_WRITE_BUFFER_SIZE_MB}" \
  --db-block-cache-mb "${DB_BLOCK_CACHE_MB}" \
  --electrum-banner "${BANNER}"
exit_code="$?"
set -e

echo "electrs exited with code ${exit_code}" >&2
exit "${exit_code}"
