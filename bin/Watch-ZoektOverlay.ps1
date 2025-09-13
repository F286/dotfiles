param(
  [string]$ChromiumSrc = $env:CHROMIUM_SRC,
  [string]$OverlayDir = "$env:USERPROFILE\.zoekt\chromium-overlay"
)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path $ChromiumSrc)) { throw "Set CHROMIUM_SRC first." }

# Initial build
& "$env:USERPROFILE\bin\Update-ZoektOverlayIndex.ps1" -ChromiumSrc $ChromiumSrc -OverlayDir $OverlayDir

$fsw = New-Object IO.FileSystemWatcher $ChromiumSrc, '*'
$fsw.IncludeSubdirectories = $true
$fsw.NotifyFilter = [IO.NotifyFilters]'FileName, LastWrite, DirectoryName'

# Debounce timer (1s)
$pending = $false
$timer = New-Object Timers.Timer
$timer.Interval = 1000
$timer.AutoReset = $false
$timer.add_Elapsed({
  if ($pending) {
    $pending = $false
    & "$env:USERPROFILE\bin\Update-ZoektOverlayIndex.ps1" -ChromiumSrc $ChromiumSrc -OverlayDir $OverlayDir
  }
})

$action = { $ExecutionContext.SessionState.PSVariable.Set('pending',$true); $timer.Stop(); $timer.Start() }
$subs = @()
$subs += Register-ObjectEvent $fsw Changed -Action $action
$subs += Register-ObjectEvent $fsw Created -Action $action
$subs += Register-ObjectEvent $fsw Deleted -Action $action
$subs += Register-ObjectEvent $fsw Renamed -Action $action

Write-Host "[zoekt] Watching $ChromiumSrc for changes. Ctrl+C to stop."
while ($true) { Wait-Event | Out-Null }
