#!/bin/sh
set -eu

# Umbrel's legacy dependency export path can leak the current app's APP_PASSWORD
# into dependency exports. Derive the Elements password directly so this app
# always talks to the real Elements RPC credentials.
if command -v derive_entropy >/dev/null 2>&1; then
export APP_ELEMENTS_RPC_PASS="$(derive_entropy "app-elements-seed-APP_PASSWORD")"
fi

cat <<EOF
export LIQUID_ELECTRS_LAN_HOST=${DEVICE_DOMAIN_NAME:-umbrel.local}
export LIQUID_ELECTRS_ELECTRUM_TCP_PORT=51001
EOF
