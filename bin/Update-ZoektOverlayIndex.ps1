param(
  [string]$ChromiumSrc = $env:CHROMIUM_SRC,
  [string]$OverlayDir  = "$env:USERPROFILE\.zoekt\chromium-overlay"
)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path $ChromiumSrc)) { throw "ChromiumSrc not found: $ChromiumSrc" }

$stage = Join-Path $OverlayDir "stage"
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$stage"
Get-ChildItem $OverlayDir -Filter *.zoekt* | Remove-Item -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $stage | Out-Null

$changed = @()
$deleted = @()

# Gather changes across nested repos
Get-ChildItem -Path $ChromiumSrc -Recurse -Force -Directory -Filter ".git" -ErrorAction SilentlyContinue |
  ForEach-Object {
    $repo = Split-Path -Parent $_.FullName
    Push-Location $repo
    $changed += (git ls-files -m -o --exclude-standard)
    $deleted += (git ls-files -d)
    Pop-Location
  }

$ignore = '^out/|^\.git/|^\.cipd/'
$changed = $changed | Where-Object {$_ -notmatch $ignore}
$deleted = $deleted | Where-Object {$_ -notmatch $ignore}

# Stage changed files (copy on Windows for reliability)
foreach ($rel in $changed) {
  $src = Join-Path $ChromiumSrc $rel
  $dst = Join-Path $stage $rel
  New-Item -ItemType Directory -Force -Path (Split-Path $dst) | Out-Null
  Copy-Item $src $dst -Force
}

# Save deleted list for rgx filtering
$deleted | Set-Content (Join-Path $OverlayDir "deleted.list")

# Build overlay shard
$env:Path = "$(if ($env:GOBIN) {"$env:GOBIN;"})$env:Path"
& zoekt-index -index $OverlayDir $stage | Out-Null
Write-Host "[zoekt] Overlay updated: $($changed.Count) changed, $($deleted.Count) deleted."
