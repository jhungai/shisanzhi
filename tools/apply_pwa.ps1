# Re-apply the PWA additions to a fresh index.html (e.g. new version from the claude.ai artifact), then bump VERSION.
# Usage:  powershell -ExecutionPolicy Bypass -File tools\apply_pwa.ps1 [-Source C:\path\to\fresh-index.html]
# Without -Source it patches .\index.html in place (so copy the fresh file over index.html first).
param([string]$Source)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$snip = Join-Path $PSScriptRoot 'snippets'
$utf8 = New-Object Text.UTF8Encoding $false
function ReadText($p) { ([IO.File]::ReadAllText($p, $utf8)).Replace("`r`n", "`n").TrimEnd("`n") }
$target = Join-Path $root 'index.html'
if (-not $Source) { $Source = $target }
$t = (ReadText $Source) + "`n"

if ($t.Contains('manifest.webmanifest')) { throw "This index.html already has the PWA additions. Give me the fresh file from Drive (-Source)." }

function Swap($old, $new, $what) {
  if (-not $script:t.Contains($old)) { throw "Could not find $what in the new index.html - the artifact layout changed; patch by hand." }
  $script:t = $script:t.Replace($old, $new)
}

# 1. Remove Google Fonts (breaks offline); use system fonts, PingFang TC first
$t = [regex]::Replace($t, '<link[^>]*fonts\.(googleapis|gstatic)\.com[^>]*>\r?\n?', '')
$t = $t.Replace('"Noto Sans TC"', '-apple-system,"PingFang TC","Noto Sans TC","Microsoft JhengHei"')
# 2. viewport + iOS meta + manifest/icon links
Swap '<meta name="viewport" content="width=device-width,initial-scale=1">' (ReadText "$snip\head.html") 'the viewport meta tag'
# 3. safe-area padding + banner CSS
Swap '.wrap{max-width:820px;margin:0 auto;padding:16px max(4vw,12px) 60px}' (ReadText "$snip\wrap.css") 'the .wrap CSS rule'
# 4. banner button + service worker registration
Swap '<div class="modal" id="modal">' ((ReadText "$snip\banner.html") + "`n" + '<div class="modal" id="modal">') 'the modal div'
Swap "</script>`n</body>" ("</script>`n" + (ReadText "$snip\sw-register.html") + "`n</body>") 'the closing script/body tags'

[IO.File]::WriteAllText($target, $t, $utf8)

# 5. Bump VERSION in sw.js
$swp = Join-Path $root 'sw.js'
$sw = [IO.File]::ReadAllText($swp, $utf8)
$m = [regex]::Match($sw, "const VERSION = 'v(\d+)'")
if (-not $m.Success) { throw "VERSION constant not found in sw.js" }
$new = [int]$m.Groups[1].Value + 1
$sw = $sw.Replace($m.Value, "const VERSION = 'v$new'")
[IO.File]::WriteAllText($swp, $sw, $utf8)
Write-Host "OK: PWA additions applied, VERSION is now v$new. Next: git add -A; git commit -m '...'; git push"
