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

The supported Umbrel integration path uses `http://elements_node_1` as the
service host and maps `APP_ELEMENTS_NODE_RPC_PORT` onto `ELEMENTS_PORT`.
Canonical Umbrel `elements` does not export RPC credentials or its data dir for
dependents, so this app fixes `ELEMENTS_USER` to `elements`, re-derives
`APP_ELEMENTS_RPC_PASS` in `exports.sh`, and sets `ELEMENTS_DATA_DIR` to the
standard `${UMBREL_ROOT}/app-data/elements/data` path. The read-only
`${ELEMENTS_DATA_DIR}` mount remains as a fallback source for `elements.conf`,
but it is no longer the primary authentication path.

The `electrs` wrapper is intentionally shipped in a low-resource configuration
for Umbrel devices: `--lightmode` is enabled, address search is left
disabled, the default RocksDB write buffer and block cache are kept small, and
the supported 16 GiB Umbrel profile now caps the `electrs` container at `10g`.
The package also raises the container `nofile` limit to `100000` because
upstream `electrs` asks RocksDB for that many open files during indexing.

The main stability change is a local patch against the pinned Blockstream
`electrs` commit that adds checkpointed initial sync. Large sync backlogs are
processed in `500`-header windows by default, with each window explicitly
flushed and checkpointed before the next one begins. That keeps progress
durable across restarts and avoids the old "finish headers, then OOM before any
useful state is saved" behavior.

Those defaults can still be tuned with `ELECTRS_DB_WRITE_BUFFER_SIZE_MB`,
`ELECTRS_DB_BLOCK_CACHE_MB`, `ELECTRS_MEM_LIMIT`,
`ELECTRS_NOFILE_SOFT_LIMIT`, `ELECTRS_NOFILE_HARD_LIMIT`, and
`ELECTRS_INITIAL_SYNC_BATCH_SIZE` if a specific box needs adjustment.

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

## Install On Umbrel

Use this command from the Umbrel host:

```bash
umbreld client apps.install.mutate --appId liquid-electrs
```

For a clean reinstall, make sure `liquid-electrs` is not currently installed
first. If Umbrel's installed app list does not include it but a stale
`app-data/liquid-electrs` directory still exists, remove that stale runtime copy
before reinstalling.

## Image Publishing

- `repo` and `support` in `umbrel-app.yml` assume the GitHub repository lives
  at `edwardbickerton/liquid-electrs`.
- `docker-compose.yml` still uses local `build:` sections so `umbreld client
  apps.install.mutate --appId liquid-electrs` works before GHCR images are
  published.
- The repository still includes `.github/workflows/publish-liquid-electrs-images.yml`
  so the app can move to digest-pinned multi-arch images later.
- `umbrel-app.yml` intentionally does not set `icon:`. Official Umbrel apps get
  their homescreen and App Store icon from the published
  `umbrel-apps-gallery/<app-id>/icon.svg` asset rather than a manifest-local
  relative path.
- Until `liquid-electrs` is merged upstream and its gallery assets are
  published, local installs from this unpublished app ID will show a missing
  icon and any gallery images will also resolve to missing CDN assets.
The publish workflow emits final digest values in the job summary so they can
be copied into release installs once the package is ready to stop building
on-device.

## Testing

Recommended workflow:

- run the app through `umbrel-dev` with the Elements app already installed
- verify the landing page shows live version, sync progress, your current
  Umbrel `.local` hostname, `51001`, and `Disabled`
- connect `Blockstream App` desktop to your current Umbrel `.local` hostname on
  port `51001`
- keep `Enable TLS/SSL` disabled
- confirm `electrs` startup logs show the configured mem limit, open-files
  limit, initial sync batch size, and resume/checkpoint messages
