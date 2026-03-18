# AGENTS.md

Repo-specific guidance for future Codex sessions in this repository.

## Reference

- Use the Umbrel App Framework README as the upstream reference for Umbrel app packaging and conventions: https://github.com/getumbrel/umbrel-apps/blob/master/README.md

## Purpose

- Package Blockstream `electrs` as a self-hosted Liquid Electrum server for Umbrel.
- Keep this repo a thin wrapper for users connecting `Blockstream App` desktop clients to their own server.
- Liquid mainnet only. Do not add Esplora, Tor hidden services, mempool integration, or wallet-management features.

## Layout

- `umbrel-app.yml`: Umbrel app metadata
- `docker-compose.yml`: Umbrel runtime definition
- `exports.sh`: exported connection variables
- `icon.svg`: canonical app icon source for the frontend bundle
- `AGENTS.md`: repo-specific guidance
- `electrs/`: Blockstream `electrs` build and runtime wrapper
- `apps/backend/`: Express API plus `/ping`, `/v1/electrs/version`, `/v1/electrs/syncPercent`, and `/v1/electrs/electrum-connection-details`
- `apps/frontend/`: Vue landing page, styling, and QR/copy UI

## Runtime

- `electrs` runs with Liquid support and `--parent-network bitcoin`.
- The app exposes plain Electrum on port `51001`; TLS/SSL is intentionally disabled.
- The landing page should tell users to keep `Enable TLS/SSL` disabled in `Blockstream App`.
- Browser traffic to `/` goes through Umbrel `app_proxy` into `app:3006`.
- Wallet traffic to `51001` hits `electrs` directly.
- The only declared Umbrel dependency is `elements`.
- Use canonical Umbrel `elements`: `ELEMENTS_HOST=http://elements_node_1`, `ELEMENTS_PORT` from `APP_ELEMENTS_NODE_RPC_PORT`, and `ELEMENTS_USER=elements`.
- `APP_ELEMENTS_RPC_PASS` is derived locally in `exports.sh`.
- `ELEMENTS_DATA_DIR` should be `${UMBREL_ROOT}/app-data/elements/data`, with the read-only mount kept only as a fallback source for `elements.conf`.
- `docker-compose.yml` is not directly runnable with plain Docker Compose because Umbrel injects `app_proxy` at runtime.

## Electrs Defaults

- Keep the wrapper low-resource: `--lightmode` enabled, address search disabled, small RocksDB write buffer and block cache, `6g` RAM and `2.0` CPU on the supported 16 GiB profile.
- The container `nofile` limit should stay at `100000`.
- The pinned Blockstream `electrs` commit includes the checkpointed initial sync patch.
- Large sync backlogs are processed in `100`-header windows by default, with each window flushed and checkpointed before the next one.
- Tunable defaults include `ELECTRS_DB_WRITE_BUFFER_SIZE_MB`, `ELECTRS_DB_BLOCK_CACHE_MB`, `ELECTRS_MEM_LIMIT`, `ELECTRS_NOFILE_SOFT_LIMIT`, `ELECTRS_NOFILE_HARD_LIMIT`, `ELECTRS_INITIAL_SYNC_BATCH_SIZE`, and `ELECTRS_CPUS`.

## Working Rules

- Keep changes minimal and wrapper-focused.
- Prefer configuring upstream `electrs` over patching source when possible.
- If ports or connection details change, update `docker-compose.yml`, `exports.sh`, and the landing page together.
- If the landing page changes, rebuild the root `app` image when testing so the frontend bundle and backend serve layer stay in sync.
- Treat this repo as the canonical project root; do not switch focus to `liquid-esplora`.

## Release And Test

- `repo` and `support` in `umbrel-app.yml` assume `edwardbickerton/liquid-electrs`.
- Local `build:` sections stay until digest-pinned GHCR images are published.
- `umbrel-app.yml` intentionally does not set `icon:`; the official gallery supplies the homescreen and App Store icon.
- Use Umbrel or `umbrel-dev` with the Elements app installed.
- Verify the landing page shows live sync/version status and the expected `umbrel.local:51001` value.
- Verify `Blockstream App` connects successfully with TLS disabled.
- Confirm `electrs` startup logs show the configured mem limit, open-files limit, initial sync batch size, and resume/checkpoint messages.

## Caveat

- The app assumes the Elements app provides a healthy external RPC endpoint.
