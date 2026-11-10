# Fork changelog

## 2026-11-10

- Fix status line spacing in Tern 0.9.14. A wrapper separates `#statusline` from `.sl-plugins`, so the direct-child selectors no longer match. Use descendant selectors to restore the gap and margin rules.
