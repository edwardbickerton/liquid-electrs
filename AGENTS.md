# AGENTS.md

This file captures repo-specific guidance for future Codex sessions in this
repository.

## Umbrel App Framework Reference

- Use the Umbrel App Framework README as the upstream reference for Umbrel app
  packaging and conventions:
  https://github.com/getumbrel/umbrel-apps/blob/master/README.md

## What This Repo Is For

- This repository exists to package Blockstream `electrs` as a self-hosted
  Liquid Electrum server for Umbrel.
- The main user goal is to let Umbrel users connect `Blockstream App` desktop
  clients to their own Liquid Electrum server.
- This repo is a thin Umbrel wrapper. It should not grow into a broader Liquid
  management suite.

## Product Direction

- Liquid mainnet only.
- The only declared Umbrel app dependency is `elements`.
- The app exposes a plain Electrum endpoint on `51001`.
- TLS/SSL is intentionally disabled.
- The landing page should tell users to keep `Enable TLS/SSL` disabled in
  `Blockstream App`.
- The landing page should stay visually close to Umbrel's Bitcoin `electrs`
  app, but without any Tor UI.

## Scope Boundaries

- Do not add Esplora or any block explorer UI here.
- Do not add Tor hidden services here.
- Do not add mempool integration here.
- Do not add custom wallet-management features here.
- If explorer functionality is needed later, it should live in a separate app
  and repository.

## Current App Architecture

- `electrs/` builds and runs Blockstream `electrs` with the `liquid` feature.
- `apps/backend/` serves the frontend bundle and exposes the internal HTTP API
  used by the landing page.
- `apps/frontend/` renders the Umbrel-style landing page.
- Wallet traffic goes straight to the `electrs` service on port `51001`.
- The app targets canonical Umbrel `elements`: `ELEMENTS_HOST` should stay
  `http://elements_node_1`, `ELEMENTS_PORT` should come from
  `APP_ELEMENTS_NODE_RPC_PORT`, `ELEMENTS_USER` should default to `elements`,
  and `APP_ELEMENTS_RPC_PASS` should be derived locally in this repo's
  `exports.sh` rather than relied on as a dependency export. A read-only
  `${ELEMENTS_DATA_DIR}` mount should remain as a fallback source for
  `elements.conf`, but it is not the primary auth path.
- `exports.sh` should continue to derive the Elements RPC password from the
  `elements` app seed and hardcode `ELEMENTS_DATA_DIR` to
  `${UMBREL_ROOT}/app-data/elements/data` so the app works with canonical
  Umbrel `elements`.

## Directory Responsibilities

- The repo root contains Umbrel metadata, the compose file, exported
  connection variables, store assets, and docs.
- `electrs/` owns the Liquid `electrs` image build and startup logic.
- `apps/backend/` owns the Express API and static bundle serving.
- `apps/frontend/` owns the Vue landing page, Tailwind styling, and QR/copy UI.

## Working Rules For Future Sessions

- Keep changes minimal and wrapper-focused.
- Prefer configuring upstream `electrs` over patching its source.
- If ports or connection details change, update `docker-compose.yml`,
  `exports.sh`, and the landing page together.
- If the landing page changes, rebuild the root `app` image when testing so the
  frontend bundle and backend serve layer stay in sync.
- This repo is the canonical project root. Do not treat `liquid-esplora` as
  the active app once this repo exists.

## Test Workflow

- Use Umbrel / `umbrel-dev` with the Elements app installed.
- Verify the landing page loads and shows live sync/version status plus the
  expected `umbrel.local:51001` value.
- Verify `Blockstream App` desktop connects successfully with TLS disabled.

## Known Caveats

- The app is not yet ready for Umbrel store submission because it still uses
  local `build:` sections instead of published multi-arch images pinned by
  digest.
- The app assumes the Elements app provides a healthy external RPC endpoint.
