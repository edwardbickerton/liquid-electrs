#!/bin/sh
set -eu

LAN_HOSTNAME="${LAN_HOSTNAME:-umbrel.local}"
PLAIN_PORT="${PLAIN_PORT:-51001}"

mkdir -p /usr/share/nginx/html /etc/nginx

export LAN_HOSTNAME PLAIN_PORT

envsubst '${LAN_HOSTNAME} ${PLAIN_PORT}' \
  < /templates/index.html.template \
  > /usr/share/nginx/html/index.html

envsubst '' \
  < /templates/nginx.conf.template \
  > /etc/nginx/nginx.conf

exec nginx -g 'daemon off;'

