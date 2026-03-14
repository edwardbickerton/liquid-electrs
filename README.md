# Liquid Electrs for Umbrel

This repository packages Blockstream `electrs` as a standalone Umbrel app for
Liquid mainnet. The app is intentionally narrow: it depends only on Umbrel's
Elements app, exposes a plain Electrum endpoint on `51001`, and serves a
dynamic landing page that mirrors Umbrel's Bitcoin `electrs` app closely.

The app does not ship:

- Esplora or any block explorer UI
- a bundled Liquid or Bitcoin node
- Tor hidden services
- mempool integration

## Repository Layout

- `umbrel-app.yml`: Umbrel app metadata
- `docker-compose.yml`: Umbrel runtime definition
- `exports.sh`: exported connection variables
- `AGENTS.md`: repo-specific guidance for future Codex sessions
- `electrs/`: Blockstream `electrs` build and runtime wrapper
- `apps/backend/`: Express API that serves the frontend and exposes
  `/ping`, `/v1/electrs/version`, `/v1/electrs/syncPercent`, and
  `/v1/electrs/electrum-connection-details`
- `apps/frontend/`: Vue app that renders the Umbrel-style connection page

## Runtime Summary

At runtime, the app is split into two services:

- `electrs`: builds and runs Blockstream `electrs` with Liquid support against
  the external Elements RPC endpoint
- `app`: serves the landing page and polls live sync/version state from
  `electrs` and Elements RPC

Request flow:

- browser traffic to `/` goes through Umbrel `app_proxy` into the `app`
  service on port `3006`
- wallet traffic to `51001` hits `electrs` directly

The app depends on Umbrel's `elements` app. `electrs` still runs with
`--parent-network bitcoin` because that is a Liquid runtime setting, not a
direct Umbrel dependency declaration.

The supported Umbrel integration path uses Umbrel's exported Elements RPC
credentials: use `http://elements_node_1` as the service host, map
`APP_ELEMENTS_NODE_RPC_PORT` onto `ELEMENTS_PORT`, and pass through
`APP_ELEMENTS_RPC_USER` and `APP_ELEMENTS_RPC_PASS`. A read-only
`${ELEMENTS_DATA_DIR}` mount can still be kept as a fallback source for
`elements.conf`, but it is no longer the primary authentication path.
`exports.sh` also re-derives the Elements RPC password defensively so this app
does not inherit its own `APP_PASSWORD` through Umbrel's legacy dependency
export flow.

The `electrs` wrapper is intentionally shipped in a low-resource configuration
for Umbrel devices: `--lightmode` is enabled and address search is left
disabled.

The Umbrel `docker-compose.yml` is intentionally not directly runnable with
plain Docker Compose because Umbrel injects the `app_proxy` service image at
runtime.

## Connect Blockstream App

To connect Blockstream App desktop to this server:

1. Open the custom Electrum server settings in Blockstream App.
2. Set the address to your Umbrel device's `.local` hostname.
3. On a default installation that will usually be `umbrel.local`.
4. Set the port to `51001`.
5. Keep `Enable TLS/SSL` disabled.

The landing page QR code encodes the same plain `host:port` value:
`<your-device-domain>.local:51001`.

## Notes Before Publishing

- `repo` and `support` in `umbrel-app.yml` assume the GitHub repository lives
  at `edwardbickerton/liquid-electrs`.
- `docker-compose.yml` still uses local `build:` sections and is intended for
  development and packaging iteration first.
- Producing published multi-arch images pinned by digest is a later release
  step.

## Testing

Recommended workflow:

- run the app through `umbrel-dev` with the Elements app already installed
- verify the landing page shows live version, sync progress, your current
  Umbrel `.local` hostname, `51001`, and `Disabled`
- connect `Blockstream App` desktop to your current Umbrel `.local` hostname on
  port `51001`
- keep `Enable TLS/SSL` disabled
