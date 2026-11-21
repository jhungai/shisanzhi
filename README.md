# 十三支計分器

免費的 iPhone / iPad 主畫面 App（PWA），放在 GitHub Pages，可離線使用。
資料存在各裝置自己的 localStorage（`13zhi`、`13zhi_names`），不會上傳。

## 更新三步驟

改完 `index.html`（或任何檔案）後：

1. 把 `sw.js` 第 2 行的 `VERSION` 加 1（例如 `'v1'` → `'v2'`）
2. `git add -A && git commit -m "說明這次改了什麼"`
3. `git push`

約 1 分鐘後 GitHub Pages 更新完成。

## 從 claude.ai 拿到新版 index.html 時（重新套用 PWA 功能）

app 的畫面/功能是在 claude.ai artifact 裡改的，新版會出現在 Drive 的「IOS Web App」資料夾。
那份新檔是「純 app」，沒有 PWA 設定，所以要用腳本補回去：

1. 從 Drive 下載新的 `shisanzhi-index.html`，**覆蓋**本資料夾的 `index.html`
2. `powershell -ExecutionPolicy Bypass -File toolspply_pwa.ps1`
   （自動補上 manifest / 圖示連結、iOS meta、字型改系統字型、離線 service worker 註冊、更新橫幅，並把 `sw.js` 的 `VERSION` 加 1）
3. `git add -A && git commit -m "更新 app" && git push`

- 也可以用 `-Source 新檔路徑` 指定來源，腳本會把結果寫進 `index.html`。
- 腳本檢查到 `index.html` 已經有 PWA 設定，會停下來，不會重複套用，也不會多加版本號。
- 如果顯示「Could not find ... artifact layout changed」，代表新版 artifact 的結構變了
  （例如 viewport 那行或 `.wrap` 樣式被改掉），把錯誤訊息貼給 Claude，修 `tools/apply_pwa.ps1` 即可。
- 套用的內容放在 `tools/snippets/`，要改橫幅文字或 meta 就改那裡。

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
