# Fork changelog

## 2026-11-10

- Shorten the status line while a provider is locked.
  - The `LOCKED` badge already names the provider, shows the reset countdown and the saved resets, so the group name, `reset` countdown and `✦n` segments are dropped for that provider.
  - A full 5h or weekly window added about 40 columns and pushed the end of the status line off screen.
- Fix status line spacing in Tern 0.9.14.
  - Use descendant selectors to restore the gap and margin rules.
  - A wrapper separates `#statusline` from `.sl-plugins`, so the direct-child selectors no longer match.
- Keep update notices, but stop the update action from reinstalling the original plugin.
  - Reinstalling the original repository would discard this fork's changes.
  - The action now explains how to sync the fork and run `sync.ps1` from tern-omp-settings.
