---
name: report-liquid-electrs-sync-progress
description: Report the current sync progress of liquid-electrs from Umbrel app state and recent logs, including durable tip height, in-flight batch progress, restart durability, and whether the node is syncing, stalled, or healthy. Use when asked to summarize liquid-electrs sync status, progress percentage, current block height, or latest checkpointed height.
---

# Report Liquid Electrs Sync Progress

Use this skill to turn raw `liquid-electrs` and companion `elements` logs into a compact progress report.

## Workflow

1. Check app state first with `umbreld client apps.state.query --appId liquid-electrs`.
2. Read a recent `liquid-electrs` log snapshot with `umbreld client apps.logs.query --appId liquid-electrs`.
3. If the latest `liquid-electrs` snapshot is stalled, restarting, or unclear, also read `umbreld client apps.logs.query --appId elements` and compare the newest block-tip lines and timestamps.
4. Report the latest durable sync point from the logs:
   - Prefer `checkpoint flushed: durable tip height=...` as the authoritative synced height.
   - Also note the current batch range from `catch-up sync batch X/Y: heights A..B`.
   - Do not confuse the in-flight batch upper bound with the durable checkpointed height.
5. If the user wants a percentage and a live chain tip is available, compute:
   - `durable tip height / current Liquid tip height * 100`
   - State clearly whether the percentage is exact or estimated.
6. When multiple snapshots are available, compare heights and timestamps to say whether progress is advancing, paused, or recovering after restart.

## Output

- Keep the response to one short line when possible.
- Include only: durable tip height, current batch range, percentage, and a short health status.
- Use this format:
  `Heights: <durable tip> | Batch: <start>..<end> | Progress: <pct>% | Health: <ready/syncing/stalled/crashing>`
- If the status is ambiguous, add one brief caveat instead of extra detail.
- Do not include hashes, timestamps, proxy noise, or long explanations unless needed to resolve ambiguity.

## Guardrails

- Do not invent heights.
- Distinguish app readiness from full chain sync.
- Prefer exact heights over vague summaries.
