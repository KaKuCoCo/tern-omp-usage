# Fork changelog

## 2026-11-10

- Fix status line spacing in Tern 0.9.14.
  - Use descendant selectors to restore the gap and margin rules.
  - A wrapper separates `#statusline` from `.sl-plugins`, so the direct-child selectors no longer match.
