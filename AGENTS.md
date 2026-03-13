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

## Scope Boundaries

- Do not add Esplora or any block explorer UI here.
- Do not add Tor hidden services here.
- Do not add mempool integration here.
- Do not add custom wallet-management features here.
- If explorer functionality is needed later, it should live in a separate app
  and repository.

## Current App Architecture

- `electrs/` builds and runs Blockstream `electrs` with the `liquid` feature.
- `gateway/` serves the landing page at the app root.
- Wallet traffic goes straight to the `electrs` service on port `51001`.
- The app uses the external Elements RPC endpoint supplied by Umbrel via
  `APP_ELEMENTS_*` variables.

## Directory Responsibilities

- The repo root contains Umbrel metadata, the compose file, exported
  connection variables, store assets, and docs.
- `electrs/` owns the Liquid `electrs` image build and startup logic.
- `gateway/` owns the static landing page and Nginx configuration.

## Working Rules For Future Sessions

- Keep changes minimal and wrapper-focused.
- Prefer configuring upstream `electrs` over patching its source.
- If ports or connection details change, update `docker-compose.yml`,
  `exports.sh`, and the landing page together.
- If the landing page changes, rebuild the `gateway` image when testing so the
  template changes are picked up.
- This repo is the canonical project root. Do not treat `liquid-esplora` as
  the active app once this repo exists.

## Test Workflow

- Use Umbrel / `umbrel-dev` with the Elements app installed.
- Verify the landing page loads and shows the expected `umbrel.local:51001`
  value.
- Verify `Blockstream App` desktop connects successfully with TLS disabled.

## Known Caveats

- The app is not yet ready for Umbrel store submission because it still uses
  local `build:` sections instead of published multi-arch images pinned by
  digest.
- The app assumes the Elements app provides a healthy external RPC endpoint.
