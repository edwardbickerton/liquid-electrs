---
name: install-liquid-electrs-on-umbrel
description: Install or reinstall the liquid-electrs Umbrel app from the Umbrel host, including stale app-data cleanup and clean reinstall checks. Use when asked to install, reinstall, or recover liquid-electrs on Umbrel.
---

# Install Liquid Electrs on Umbrel

Use this skill when you need to install or cleanly reinstall `liquid-electrs` on an Umbrel host.

## Workflow

1. For a clean reinstall, confirm `liquid-electrs` is not currently installed first.
2. If Umbrel's installed app list does not include it but `app-data/liquid-electrs` still exists, remove only that stale runtime copy before reinstalling.
3. From the Umbrel host, run:
   ```bash
   umbreld client apps.install.mutate --appId liquid-electrs
   ```
4. Do not change unrelated app data or other app IDs.
