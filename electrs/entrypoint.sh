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
    die "Missing Elements config at ${conf_path}. This app expects Umbrel's PeerSwap-style \${ELEMENTS_DATA_DIR} mount."
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
ELEMENTS_PASS="$(elements_conf_value rpcpassword || true)"

ELEMENTS_HOST="$(normalize_host "$ELEMENTS_HOST")"

if [ -z "$ELEMENTS_PORT" ]; then
  die "Missing Elements RPC port. Set ELEMENTS_PORT from Umbrel APP_ELEMENTS_NODE_RPC_PORT."
fi

if [ -z "$ELEMENTS_PASS" ]; then
  die "Missing rpcpassword in elements.conf. This app expects Umbrel's PeerSwap-style Elements datadir mount."
fi

COOKIE="${ELEMENTS_USER}:${ELEMENTS_PASS}"
LOG_LEVEL="${ELECTRS_LOG_LEVEL:-vv}"
BANNER="${ELECTRS_BANNER:-Umbrel Liquid Electrs}"

mkdir -p /data/electrs_liquid_db /tmp/elements

# Umbrel hardware is resource constrained, so keep light mode on and do not
# enable address search indexing.
exec /usr/local/bin/electrs \
  -"${LOG_LEVEL}" \
  --timestamp \
  --network liquid \
  --parent-network bitcoin \
  --daemon-dir /tmp/elements \
  --daemon-rpc-addr "${ELEMENTS_HOST}:${ELEMENTS_PORT}" \
  --cookie "${COOKIE}" \
  --jsonrpc-import \
  --lightmode \
  --electrum-rpc-addr 0.0.0.0:50001 \
  --monitoring-addr 0.0.0.0:4224 \
  --db-dir /data/electrs_liquid_db/mainnet \
  --electrum-banner "${BANNER}"
