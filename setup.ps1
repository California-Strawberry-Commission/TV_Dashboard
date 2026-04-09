<#
.SYNOPSIS
    Operator Aid Office Dashboard - Windows Kiosk Setup
.DESCRIPTION
    Sets up the dashboard to auto-launch in fullscreen kiosk mode on boot.
    Run this script once as Administrator, then reboot.
.USAGE
    Right-click PowerShell, Run as Administrator, then:
    cd office-dashboard
    powershell -ExecutionPolicy Bypass -File .\setup.ps1
#>

# Require admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host ""
    Write-Host "  ERROR: Please run this script as Administrator." -ForegroundColor Red
    Write-Host "  Right-click PowerShell -> Run as administrator, then try again." -ForegroundColor Yellow
    Write-Host ""
    pause
    exit 1
}

$ErrorActionPreference = "Stop"
$dashboardDir = Join-Path $env:USERPROFILE "Dashboard"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

Write-Host ""
Write-Host "  ============================================" -ForegroundColor Cyan
Write-Host "    Operator Aid - Dashboard Kiosk Setup" -ForegroundColor Cyan
Write-Host "  ============================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Copy dashboard files
Write-Host "[1/6] Copying dashboard files..." -ForegroundColor Green
if (!(Test-Path $dashboardDir)) {
    New-Item -ItemType Directory -Path $dashboardDir -Force | Out-Null
}
$srcHtml = Join-Path $scriptDir "index.html"
$dstHtml = Join-Path $dashboardDir "index.html"
Copy-Item $srcHtml $dstHtml -Force
Write-Host ("       -> " + $dstHtml) -ForegroundColor DarkGray

# Step 2: Detect browser
Write-Host "[2/6] Detecting browser..." -ForegroundColor Green
$browserPath = $null
$browserName = ""

$searchPaths = @(
    (Join-Path $env:ProgramFiles "Google\Chrome\Application\chrome.exe"),
    (Join-Path ${env:ProgramFiles(x86)} "Google\Chrome\Application\chrome.exe"),
    (Join-Path $env:LOCALAPPDATA "Google\Chrome\Application\chrome.exe"),
    (Join-Path $env:ProgramFiles "Microsoft\Edge\Application\msedge.exe"),
    (Join-Path ${env:ProgramFiles(x86)} "Microsoft\Edge\Application\msedge.exe")
)

foreach ($p in $searchPaths) {
    if (Test-Path $p) {
        $browserPath = $p
        if ($p -like "*chrome*") {
            $browserName = "Chrome"
        } else {
            $browserName = "Edge"
        }
        break
    }
}

if ($browserPath) {
    Write-Host ("       -> Found " + $browserName + " at: " + $browserPath) -ForegroundColor DarkGray
} else {
    Write-Host ""
    Write-Host "  ERROR: No Chrome or Edge found. Install one and try again." -ForegroundColor Red
    Write-Host ""
    pause
    exit 1
}

# Step 3: Create the kiosk launcher batch file
Write-Host "[3/6] Creating kiosk launcher..." -ForegroundColor Green
$launcherPath = Join-Path $dashboardDir "start-kiosk.bat"
$dashboardUrl = "file:///" + ($dashboardDir -replace "\\","/") + "/index.html"

$lines = @(
    "@echo off",
    "title Operator Aid Dashboard",
    "echo Starting dashboard in kiosk mode...",
    "",
    "taskkill /F /IM chrome.exe 2>nul",
    "taskkill /F /IM msedge.exe 2>nul",
    "timeout /t 2 /nobreak >nul",
    "",
    ('start "" "' + $browserPath + '" --kiosk --disable-infobars --noerrdialogs --disable-session-crashed-bubble --disable-restore-session-state --no-first-run --autoplay-policy=no-user-gesture-required "' + $dashboardUrl + '"')
)

Set-Content -Path $launcherPath -Value ($lines -join "`r`n") -Encoding ASCII
Write-Host ("       -> " + $launcherPath) -ForegroundColor DarkGray

# Step 4: Create startup shortcut (auto-launch on login)
Write-Host "[4/6] Creating startup shortcut..." -ForegroundColor Green
$startupDir = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\Startup"
$shortcutPath = Join-Path $startupDir "OperatorAidDashboard.lnk"

$WScriptShell = New-Object -ComObject WScript.Shell
$shortcut = $WScriptShell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $launcherPath
$shortcut.WorkingDirectory = $dashboardDir
$shortcut.Description = "Operator Aid Office Dashboard"
$shortcut.WindowStyle = 7
$shortcut.Save()
Write-Host ("       -> " + $shortcutPath) -ForegroundColor DarkGray

# Step 5: Disable sleep and screen timeout on AC power
Write-Host "[5/6] Disabling sleep and screen timeout (AC power)..." -ForegroundColor Green
powercfg /change monitor-timeout-ac 0
powercfg /change standby-timeout-ac 0
powercfg /change hibernate-timeout-ac 0
Write-Host "       -> Screen timeout: Never" -ForegroundColor DarkGray
Write-Host "       -> Sleep: Never" -ForegroundColor DarkGray
Write-Host "       -> Hibernate: Never" -ForegroundColor DarkGray

# Step 6: Create a desktop shortcut for manual launch
Write-Host "[6/6] Creating desktop shortcut..." -ForegroundColor Green
$desktopShortcut = Join-Path $env:USERPROFILE "Desktop\Dashboard.lnk"
$shortcut2 = $WScriptShell.CreateShortcut($desktopShortcut)
$shortcut2.TargetPath = $launcherPath
$shortcut2.WorkingDirectory = $dashboardDir
$shortcut2.Description = "Launch Office Dashboard"
$shortcut2.Save()
Write-Host ("       -> " + $desktopShortcut) -ForegroundColor DarkGray

# Done
Write-Host ""
Write-Host "  Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "  What happened:" -ForegroundColor White
Write-Host ("    - Dashboard installed to " + $dashboardDir) -ForegroundColor DarkGray
Write-Host ("    - " + $browserName + " will launch in kiosk mode on every login") -ForegroundColor DarkGray
Write-Host "    - Screen will never sleep or turn off (AC power)" -ForegroundColor DarkGray
Write-Host "    - Desktop shortcut created for manual launch" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Next steps:" -ForegroundColor White
Write-Host "    - Reboot to test auto-launch, or double-click Dashboard on the desktop" -ForegroundColor DarkGray
Write-Host "    - Press F11 or Alt+F4 to exit kiosk mode" -ForegroundColor DarkGray
Write-Host ("    - To uninstall: run uninstall.ps1") -ForegroundColor DarkGray
Write-Host ""
pause
