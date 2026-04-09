@echo off
:: Quick-launch the dashboard without full kiosk setup.
:: Just double-click this file to open the dashboard in fullscreen.

set "DASHBOARD=%~dp0index.html"
set "URL=file:///%DASHBOARD:\=/%"

:: Try Chrome first, then Edge
set "BROWSER="
if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" (
    set "BROWSER=%ProgramFiles%\Google\Chrome\Application\chrome.exe"
) else if exist "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" (
    set "BROWSER=%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
) else if exist "%LocalAppData%\Google\Chrome\Application\chrome.exe" (
    set "BROWSER=%LocalAppData%\Google\Chrome\Application\chrome.exe"
) else if exist "%ProgramFiles%\Microsoft\Edge\Application\msedge.exe" (
    set "BROWSER=%ProgramFiles%\Microsoft\Edge\Application\msedge.exe"
) else if exist "%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe" (
    set "BROWSER=%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe"
)

if defined BROWSER (
    echo Launching dashboard in kiosk mode...
    start "" "%BROWSER%" --kiosk --disable-infobars --noerrdialogs --disable-session-crashed-bubble --disable-restore-session-state --no-first-run "%URL%"
) else (
    echo No Chrome or Edge found. Opening in default browser...
    start "" "%URL%"
)
