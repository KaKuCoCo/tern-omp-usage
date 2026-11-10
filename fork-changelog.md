# Fork changelog

上游：[joaodutra88/tern-omp-usage](https://github.com/joaodutra88/tern-omp-usage)

## 2026-11-10

### Changed
- 額度鎖定時只顯示鎖定的視窗（`wk` 或 `5h`），隱藏其他欄位。
  - 原因：鎖定時狀態列多出約 40 欄，把尾端擠出畫面。
- 更新按鈕改為顯示 fork 更新步驟，不再重裝原始 repo。
  - 原因：重裝會以原始版本覆蓋 fork 的修改。

### Fixed
- 修正 Tern 0.9.14 狀態列間距變寬。
  - 原因：Tern 新增一層 `div.sb-grp`，直接子層選擇器 `#statusline > .sl-plugins` 失效。
  - 上游：未回報。

## 已移除
