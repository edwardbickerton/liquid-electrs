#!/bin/sh
set -eu

# Canonical Umbrel `elements` does not export RPC credentials for dependents.
# Derive the Elements password here so this app works with upstream `elements`
# and does not accidentally inherit its own APP_PASSWORD through legacy exports.
if command -v derive_entropy >/dev/null 2>&1; then
  export APP_ELEMENTS_RPC_PASS="$(derive_entropy "app-elements-seed-APP_PASSWORD")"
fi

# Canonical Umbrel `elements` also does not export its data dir, so mount the
# standard installed Elements chain data location explicitly.
export ELEMENTS_DATA_DIR="${UMBREL_ROOT}/app-data/elements/data"

cat <<EOF
export LIQUID_ELECTRS_LAN_HOST=${DEVICE_DOMAIN_NAME:-umbrel.local}
export LIQUID_ELECTRS_ELECTRUM_TCP_PORT=51001
EOF
