---
name: monitor-liquid-electrs-logs
description: Inspect recent liquid-electrs log snapshots and Umbrel app state, correlate them with elements logs when dependency issues may be involved, and sample host CPU and RAM usage during checks. Use when asked to check, monitor, keep watching, or interpret liquid-electrs logs, sync progress, restarts, OOM kills, startup failures, upstream elements connectivity, or whether the machine is under CPU or memory pressure while liquid-electrs runs.
---

# Monitor Liquid Electrs Logs

Use this skill when a user wants a recent `liquid-electrs` log snapshot interpreted, or wants you to keep checking whether the app is healthy.

## Workflow

1. Check app state first with `umbreld client apps.list.query` or `umbreld client apps.state.query --appId liquid-electrs`.
2. Sample host load before or alongside the first log snapshot:
   - Use `free -m` for RAM totals and available memory.
   - Use `vmstat 1 2` and read the final row for current CPU idle, user, system, and wait percentages.
   - If a process-level view would help explain pressure, use `top -b -n 1` or `ps` to identify the heaviest processes.
3. Read a recent snapshot with `umbreld client apps.logs.query --appId liquid-electrs`.
4. If the app is starting, stalled, restarting, or showing RPC/auth/connectivity errors, also read a recent snapshot with `umbreld client apps.logs.query --appId elements` and compare timestamps, restarts, block-tip progress, and auth or connectivity errors.
5. Classify the app:
   - Healthy startup: `Liquid Electrs app listening on port 3006`, plus `electrs configured mem limit`, `electrs initial sync batch size`, and `electrs open files limit`, with no immediate restart or auth/connectivity failures.
   - Syncing normally: header progress keeps advancing, checkpoint flushes appear, and the app stays `ready`.
   - Unhealthy: `Killed`, `exit code 137`, `panic`, `error`, repeated restart loops, auth failures, or host memory/CPU pressure severe enough to explain instability.
6. If the user asks to keep watching, use the "sleep trick": take a snapshot, `sleep` for a short interval, then take another snapshot. Repeat for at least 20 minutes unless the app becomes unhealthy sooner or the user stops you. Compare the newest header height, checkpoint height, app state, RAM availability, CPU usage, and any matching `elements` signal each round.
7. If the app is uninstalled, report that there are no live logs to monitor.

## What To Report

- The latest meaningful log lines with timestamps.
- Whether the app is ready, syncing, stalled, or crashing.
- The most likely cause if unhealthy, with concrete evidence.
- Current RAM and CPU usage, plus whether the machine looks resource-constrained.
- Whether progress appears durable across restarts, if that matters to the user.

## Guardrails

- Do not invent log content or assume the app is healthy from partial startup output alone.
- Distinguish header download from full indexing.
- Prefer concrete heights, exit codes, and timestamps over vague summaries.
- Prefer machine-wide CPU and RAM snapshots over guesses about resource pressure.
- For watch requests, do not stop after the first snapshot; keep monitoring through the full 20-minute window unless a failure appears earlier.
- Treat `elements` as a companion signal, not a replacement. Skip extra `elements` checks when `liquid-electrs` is clearly healthy and advancing normally unless the user wants a deeper diagnostic pass.
