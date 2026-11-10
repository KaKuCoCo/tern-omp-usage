# Fork changelog

## 2026-11-10

- Show only the full window while a provider is locked.
  - The `LOCKED` badge names the provider, counts down to the reset of the window that locks it (the week's when the week is full, else 5h) and carries the saved resets.
  - Next to it the bar keeps only that window (`wk` or `5h`); the other window, Fable, `reset`, the forecast and `📅` are hidden. Both full: the week wins.
  - A full 5h or weekly window used to add about 40 columns and pushed the end of the status line off screen.
- Fix status line spacing in Tern 0.9.14.
  - Use descendant selectors to restore the gap and margin rules.
  - A wrapper separates `#statusline` from `.sl-plugins`, so the direct-child selectors no longer match.
- Keep update notices, but stop the update action from reinstalling the original plugin.
  - Reinstalling the original repository would discard this fork's changes.
  - The action now explains how to sync the fork and run `sync.ps1` from tern-omp-settings.
