# Fork changelog

## 2026-11-10

- Fix status line spacing in Tern 0.9.14.
  - Use descendant selectors to restore the gap and margin rules.
  - A wrapper separates `#statusline` from `.sl-plugins`, so the direct-child selectors no longer match.
- Keep update notices, but stop the update action from reinstalling the original plugin.
  - Reinstalling the original repository would discard this fork's changes.
  - The action now explains how to sync the fork and run `sync.ps1` from tern-omp-settings.
