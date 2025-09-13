$script = "$env:USERPROFILE\bin\Watch-ZoektOverlay.ps1"
$trigger = New-ScheduledTaskTrigger -AtLogOn
$action  = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoLogo -ExecutionPolicy Bypass -File `"$script`""
Register-ScheduledTask -TaskName "ZoektOverlayWatch" -Trigger $trigger -Action $action -Description "Real-time Zoekt overlay watch" -User $env:UserName -Force
