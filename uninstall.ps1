<#
.SYNOPSIS
    Removes the Operator Aid Dashboard kiosk setup.
.USAGE
    Run as Administrator:
    powershell -ExecutionPolicy Bypass -File .\uninstall.ps1
#>

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Please run as Administrator." -ForegroundColor Red
    pause
    exit 1
}

$dashboardDir = Join-Path $env:USERPROFILE "Dashboard"
$startupShortcut = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\Startup\OperatorAidDashboard.lnk"
$desktopShortcut = Join-Path $env:USERPROFILE "Desktop\Dashboard.lnk"

Write-Host ""
Write-Host "Removing Operator Aid Dashboard..." -ForegroundColor Yellow

if (Test-Path $startupShortcut) {
    Remove-Item $startupShortcut -Force
    Write-Host "  Removed startup shortcut" -ForegroundColor DarkGray
}
if (Test-Path $desktopShortcut) {
    Remove-Item $desktopShortcut -Force
    Write-Host "  Removed desktop shortcut" -ForegroundColor DarkGray
}
if (Test-Path $dashboardDir) {
    Remove-Item $dashboardDir -Recurse -Force
    Write-Host ("  Removed " + $dashboardDir) -ForegroundColor DarkGray
}

# Restore default power settings
powercfg /change monitor-timeout-ac 10
powercfg /change standby-timeout-ac 30

Write-Host ""
Write-Host "  Done. Power settings restored to defaults (10min screen, 30min sleep)." -ForegroundColor Green
Write-Host ""
pause
