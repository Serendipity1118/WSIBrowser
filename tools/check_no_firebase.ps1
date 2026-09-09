<#
.SYNOPSIS
  Firebase 関連と既存アプリ (pokePlus) のバックエンド識別子がリポジトリに含まれていないことを検査する。

.DESCRIPTION
  要件定義の絶対条件「既存アプリのバックエンド (Firebase 等) には一切アクセスしない・依存しない」を機械的に守る。
  git 管理下のファイルを対象に禁止パターンを検索し、見つかれば終了コード 1 で失敗する。
  doc/ (設計文書) と、このスクリプト自身は除外する。

.PARAMETER Root
  リポジトリのルート。既定はこのスクリプトの親ディレクトリ。
#>
param(
  [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

$ErrorActionPreference = 'Stop'

# 禁止パターン (大文字小文字を区別しない正規表現)
$patterns = @(
  'firebase',
  'firestore',
  'cloud_firestore',
  'firebase_core',
  'firebase_auth',
  'google-services\.json',
  'GoogleService-Info\.plist',
  'pokeplus-6e417',
  'jp\.serendipy\.pokeplus'
)

# 除外 (リポジトリ相対パスの正規表現)
$excludes = @(
  '^doc/',
  '^tools/check_no_firebase\.ps1$',
  '^\.github/workflows/',
  '\.md$'
)

Push-Location $Root
try {
  # 日本語ファイル名をエスケープさせずに受け取る
  $prev = [Console]::OutputEncoding
  [Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)
  try {
    $files = git -c core.quotepath=false ls-files
  } finally {
    [Console]::OutputEncoding = $prev
  }
} finally {
  Pop-Location
}

$hits = @()
foreach ($rel in $files) {
  $skip = $false
  foreach ($ex in $excludes) { if ($rel -match $ex) { $skip = $true; break } }
  if ($skip) { continue }
  $path = Join-Path $Root $rel
  if (-not (Test-Path $path -PathType Leaf)) { continue }
  # バイナリらしきファイルは読まない
  if ($rel -match '\.(png|jpg|jpeg|gif|ico|zip|jar|ttf|otf|woff2?|pdf)$') { continue }
  $lineNo = 0
  foreach ($line in [IO.File]::ReadLines($path)) {
    $lineNo++
    # この検査スクリプト自身への参照 (npm script 名など) は許可
    if ($line -imatch 'check[_:]no[-_]firebase') { continue }
    foreach ($p in $patterns) {
      if ($line -imatch $p) {
        $hits += [pscustomobject]@{ File = $rel; Line = $lineNo; Pattern = $p; Text = $line.Trim() }
        break
      }
    }
  }
}

if ($hits.Count -gt 0) {
  Write-Host "NG: $($hits.Count) forbidden reference(s) found" -ForegroundColor Red
  $hits | ForEach-Object { Write-Host ("  {0}:{1}  [{2}]  {3}" -f $_.File, $_.Line, $_.Pattern, $_.Text) }
  exit 1
}

Write-Host "OK: no Firebase / pokePlus backend references in $($files.Count) tracked files"
exit 0
