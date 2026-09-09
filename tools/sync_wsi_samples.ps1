<#
.SYNOPSIS
  Chrome 版 WSI リポジトリの samples/ から公開サンプルを plugins/samples/ に取り込む。

.DESCRIPTION
  WSI リポジトリで git 管理されている samples (plugin.json を持つディレクトリ) だけを対象にする。
  gitignore されたローカル専用サンプル (dmm.co.jp, mgstage.com) は取り込まない。
  取り込み先は plugins/samples/<plugin id>/ で、plugin.json / main.js / style.css / README.md をコピーする。
  ZIP は契約テストが生成するのでコピーしない。

.PARAMETER WsiRepo
  WSI リポジトリのパス。既定は環境変数 WSI_REPO、なければ ../WebSystemInjection。
#>
param(
  [string]$WsiRepo = $(if ($env:WSI_REPO) { $env:WSI_REPO } else { Join-Path $PSScriptRoot '..\..\WebSystemInjection' })
)

$ErrorActionPreference = 'Stop'
$root = Resolve-Path (Join-Path $PSScriptRoot '..')
$dest = Join-Path $root 'plugins\samples'
$WsiRepo = Resolve-Path $WsiRepo

if (-not (Test-Path (Join-Path $WsiRepo 'samples'))) {
  throw "samples/ が見つかりません: $WsiRepo"
}

Push-Location $WsiRepo
try {
  $tracked = git ls-files samples | Where-Object { $_ -like '*/plugin.json' }
} finally {
  Pop-Location
}

if (-not $tracked) { throw 'git 管理された samples/**/plugin.json がありません' }

New-Item -ItemType Directory -Force $dest | Out-Null
$ids = @()
foreach ($rel in $tracked) {
  $srcDir = Join-Path $WsiRepo (Split-Path $rel -Parent)
  $def = Get-Content (Join-Path $srcDir 'plugin.json') -Raw -Encoding UTF8 | ConvertFrom-Json
  $id = $def.id
  $ids += $id
  $target = Join-Path $dest $id
  New-Item -ItemType Directory -Force $target | Out-Null
  foreach ($name in @('plugin.json', 'main.js', 'style.css', 'README.md')) {
    $f = Join-Path $srcDir $name
    if (Test-Path $f) { Copy-Item $f (Join-Path $target $name) -Force }
  }
  Write-Host "synced: $id  <-  $rel"
}

$manifest = [ordered]@{
  source     = 'https://github.com/Serendipity1118/WebSystemInjection'
  syncedAt   = (Get-Date).ToString('o')
  ids        = $ids
}
$json = ($manifest | ConvertTo-Json) -replace "`r`n", "`n"
[IO.File]::WriteAllText((Join-Path $dest 'index.json'), $json + "`n", (New-Object Text.UTF8Encoding $false))
Write-Host "wrote $(Join-Path $dest 'index.json') ($($ids.Count) plugins)"
