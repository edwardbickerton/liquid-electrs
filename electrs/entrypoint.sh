#!/bin/sh
set -eu

require_env() {
  name="$1"
  eval "value=\${$name:-}"

  if [ -z "$value" ]; then
    echo "Missing required environment variable: $name" >&2
    exit 1
  fi
}

require_env APP_ELEMENTS_NODE_IP
require_env APP_ELEMENTS_RPC_PORT
require_env APP_ELEMENTS_RPC_USER
require_env APP_ELEMENTS_RPC_PASS

COOKIE="${APP_ELEMENTS_RPC_USER}:${APP_ELEMENTS_RPC_PASS}"
LOG_LEVEL="${ELECTRS_LOG_LEVEL:-vv}"
BANNER="${ELECTRS_BANNER:-Umbrel Liquid Electrs}"

mkdir -p /data/electrs_liquid_db /tmp/elements

exec /usr/local/bin/electrs \
  -"${LOG_LEVEL}" \
  --timestamp \
  --network liquid \
  --parent-network bitcoin \
  --daemon-dir /tmp/elements \
  --daemon-rpc-addr "${APP_ELEMENTS_NODE_IP}:${APP_ELEMENTS_RPC_PORT}" \
  --cookie "${COOKIE}" \
  --jsonrpc-import \
  --lightmode \
  --electrum-rpc-addr 0.0.0.0:50001 \
  --monitoring-addr 0.0.0.0:4224 \
  --db-dir /data/electrs_liquid_db/mainnet \
  --electrum-banner "${BANNER}"

