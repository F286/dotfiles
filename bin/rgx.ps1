param(
  [Parameter(Position=0)][string]$Query,
  [string]$Root = (Get-Location).Path,
  [string]$IndexDir = "$env:USERPROFILE\.zoekt\chromium",
  [string]$OverlayDir = "$env:USERPROFILE\.zoekt\chromium-overlay",
  [switch]$Literal, [switch]$IgnoreCase, [switch]$SmartCase
)
$ErrorActionPreference = 'Stop'
if (-not $Query) { Write-Error "Usage: rgx.ps1 -Query 'pattern' [-Root path]"; exit 2 }

$pattern = if ($Literal) { [Regex]::Escape($Query) } else { $Query }
$case = if ($IgnoreCase) { "case:no " } elseif ($SmartCase) { "case:auto " } else { "" }
$Q = "$case$pattern"

# Load changed and deleted file lists to suppress stale HEAD matches
$changed = @()
if (git rev-parse --is-inside-work-tree 2>$null) {
  $changed = git status --porcelain | ForEach-Object { $_.Substring(3) }
}
$deletedList = Join-Path $OverlayDir "deleted.list"
$deleted = Test-Path $deletedList ? (Get-Content $deletedList) : @()

# Search overlay first
$overlay = & zoekt -index $OverlayDir $Q 2>$null

# Search head, filter duplicates/deletions
$head = & zoekt -index $IndexDir $Q 2>$null | Where-Object {
  if ($_ -match '^(.*?):(\d+):(\d+):') {
    $f = $Matches[1]
    -not ($changed -contains $f) -and -not ($deleted -contains $f)
  } else { $true }
}

# Merge and print in VS-clickable format: file(line,col): text
foreach ($ln in @($overlay) + @($head)) {
  if ($ln -match '^(.*?):(\d+):(\d+):(.*)$') {
    $path,$line,$col,$text = $Matches[1..4]
    Write-Output ("{0}({1},{2}): {3}" -f $path,$line,$col,$text)
  } else { Write-Output $ln }
}
