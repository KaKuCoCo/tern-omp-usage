# Fork changelog

上游：[joaodutra88/tern-omp-usage](https://github.com/joaodutra88/tern-omp-usage)

## 2026-11-12

### Fixed
- 狀態列 CSS 改選 `#widgetbar .wg-status-chip[title=…]`，並隱藏 `.wg-status-dot`、去掉 chip 底色與內距。
  - 原因：Tern 0.9.17 把外掛片段畫成 widget bar 狀態 widget 裡的 pill（`span.wg-status-chip`，前面帶圓點），`#statusline .sl-plugin` 選擇器失效，進度點與百分比被拆成一顆顆 pill。
  - 上游：未回報。

## 2026-11-11

### Fixed
- 還原狀態列標籤的顏色：Claude 用 `--ink-pen`（橘），Codex 用 `--accent-ink`（藍），today 用 `--warn`（橘黃），cost 用 `--ok`（綠），credits `✦` 用 `--live`（紫）。
  - 原因：改用 token 時，前三者被改成 `--t1`／`--t2` 變白灰字，cost 與 credits 被誤換成藍色的 `--accent-ink`，原本是綠與紫。

## 2026-11-10

### Changed
- 額度鎖定時只顯示鎖定的視窗（`wk` 或 `5h`），隱藏其他欄位。
  - 原因：鎖定時狀態列多出約 40 欄，把尾端擠出畫面。
- 更新按鈕改為顯示 fork 更新步驟，不再重裝原始 repo。
  - 原因：重裝會以原始版本覆蓋 fork 的修改。
- 狀態列顏色改用 Tern 的 CSS 變數（`--ok`、`--warn`、`--bad`、`--accent`、`--t1`…`--t4`、`--l2`、`*-fill`），不再寫死 hex 色碼。
  - 原因：寫死的顏色不隨淺色、深色與使用者主題變化；Tern 設計指南規定顏色只用 token。
  - 上游：未回報。
- `updates` 預設關閉。
  - 原因：更新檢查追蹤原作者的 releases，fork 由 `sync.ps1` 更新，`⬆` 會誤導。

## 已移除
- 2026-11-10 修正 Tern 0.9.14 狀態列間距變寬（`#statusline > .sl-plugins` 改後代選擇器）：上游 0.4.2 已修好，合併上游 0.4.3 時移除。
