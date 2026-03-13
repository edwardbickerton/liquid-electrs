#!/bin/sh
set -eu

cat <<EOF
export LIQUID_ELECTRS_LAN_HOST=umbrel.local
export LIQUID_ELECTRS_ELECTRUM_TCP_PORT=51001
EOF

