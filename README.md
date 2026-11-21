# 十三支計分器

免費的 iPhone / iPad 主畫面 App（PWA），放在 GitHub Pages，可離線使用。
資料存在各裝置自己的 localStorage（`13zhi`、`13zhi_names`），不會上傳。

## 更新三步驟

改完 `index.html`（或任何檔案）後：

1. 把 `sw.js` 第 2 行的 `VERSION` 加 1（例如 `'v1'` → `'v2'`）
2. `git add -A && git commit -m "說明這次改了什麼"`
3. `git push`

約 1 分鐘後 GitHub Pages 更新完成。

## 版本號怎麼運作

`sw.js` 裡的 `VERSION` 決定快取名稱（`shisanzhi-v1`…）。
- 版本號**沒變**：手機一直用舊的快取檔案，看不到你的修改。
- 版本號**改了**：手機下次開啟（或回到 App）時，會在背景下載新版，
  畫面下方出現「有新版本，點這裡更新」，點下去就切換並重新載入。舊快取會自動刪除。
- 玩家名字、紀錄不受更新影響。

## 字型

不使用網路字型（離線會壞）。直接用系統字型：iOS 的 PingFang TC（苹方繁體），
其他裝置退回 Noto Sans TC / 微軟正黑體。

## 本機測試

`python -m http.server 8000` 後開 http://localhost:8000
