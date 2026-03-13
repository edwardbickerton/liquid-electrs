# Liquid Electrs for Umbrel

This repository packages a Liquid Electrum server as a standalone Umbrel app.
It is intentionally small and wrapper-focused: the app uses Umbrel's existing
Elements app as its only declared dependency and adds just enough UX to help
desktop `Blockstream App` users connect to their own Liquid server.

The app exposes:

- a landing page at the app root with copy-friendly connection details
- a plain Liquid Electrum endpoint on port `51001`

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
- `electrs/`: Blockstream `electrs` source build and runtime wrapper
- `gateway/`: static landing page served through Nginx

## Runtime Summary

At runtime, the app is split into two services:

- `electrs`: builds and runs Blockstream `electrs` with Liquid support against
  the external Elements RPC endpoint
- `gateway`: serves the root landing page with the LAN host and port details

Request flow:

- browser traffic to `/` is served by `gateway`
- wallet traffic to `51001` hits `electrs` directly

The app depends on Umbrel's `elements` app. `electrs` still runs with
`--parent-network bitcoin` because that is a Liquid runtime setting, not a
direct Umbrel dependency declaration.

The Umbrel `docker-compose.yml` is intentionally not directly runnable with
plain Docker Compose because Umbrel injects the `app_proxy` service image at
runtime.

## Notes Before Publishing

- `repo` and `support` in `umbrel-app.yml` assume the GitHub repository will be
  published at `edwardbickerton/liquid-electrs`. Update them if it lives
  elsewhere.
- `docker-compose.yml` currently uses local `build:` sections and is meant for
  development and packaging iteration first.
- Producing published multi-arch images pinned by digest is a later release
  step.

## Testing

Recommended workflow:

- run the app through `umbrel-dev` with the Elements app already installed
- verify the landing page renders the expected `host:port`
- connect `Blockstream App` desktop to `umbrel.local:51001`
- keep `Enable TLS/SSL` disabled
