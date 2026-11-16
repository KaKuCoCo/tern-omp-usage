# Fork changelog

上游：[joaodutra88/tern-omp-usage](https://github.com/joaodutra88/tern-omp-usage)

## 2026-11-16

### Changed
- 合併上游 0.6.1：用量改為 Tern widget bar 的獨立 widget（palette › Edit widgets… 放置），不再用 Plugin segments。
  - 原因：跟上游同步；舊的片段樣式改動因此作廢，見文末。

### Fixed
- 整合測試的更新情境先打開 `updates`，再檢查 `⬆`。
  - 原因：fork 預設關閉 `updates`，原測試沒開就預期出現 `⬆`，合併前就失敗。

## 2026-11-10

### Changed
- 更新按鈕改為顯示 fork 更新步驟，不再重裝原始 repo。
  - 原因：重裝會以原始版本覆蓋 fork 的修改。
- `updates` 預設關閉。
  - 原因：更新檢查追蹤原作者的 releases，fork 由 `sync.ps1` 更新，`⬆` 會誤導。

## 已移除
- 2026-11-10 修正 Tern 0.9.14 狀態列間距變寬（`#statusline > .sl-plugins` 改後代選擇器）：上游 0.4.2 已修好，合併上游 0.4.3 時移除。
- 2026-11-12 狀態列 CSS 改選 `#widgetbar .wg-status-chip[title=…]`：上游 0.4.4 修好，0.5.0 改用 widget 後不再需要，合併 0.6.1 時移除。
- 2026-11-11 還原狀態列標籤顏色、2026-11-10 狀態列顏色改用 Tern token：上游 0.5.0 改用 widget 的 `tone` 與自己的配色，片段 CSS 已刪，合併 0.6.1 時移除。
- 2026-11-10 額度鎖定時只顯示鎖定的視窗：上游 0.5.0 每個視窗是獨立 widget，鎖定時該 widget 顯示 `LOCKED`，合併 0.6.1 時移除。
