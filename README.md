# Operator Aid — Office Dashboard

A touchscreen-optimized productivity dashboard designed for a vertically-mounted office TV. Displays real-time Jira sprint data, weather, clock, and interactive tools — all within arm's reach at the bottom of the screen.

## Features

- **Live Jira Kanban** — Current sprint tasks from the SCRUM project, drag-and-drop or swipe to move cards
- **Clock & Weather** — SLO weather via Open-Meteo (no API key needed)
- **Sprint Stats** — In Progress / Done / To Do counts at a glance
- **Countdown Timer** — Graduation countdown (configurable)
- **Whiteboard** — Freeform drawing with colors, touch-optimized
- **Pomodoro Timer** — Presets for 5/15/25/45/60 min
- **Sticky Notes** — Persisted across refreshes
- **Quick Links** — Jira, Confluence, GitHub, Canvas

## Layout

The TV is mounted high, so nothing clickable is in the top half:

- **Top 40%** — Read-only display (clock, weather, stats). Zero interactive elements.
- **Bottom 60%** — All interactive content (kanban, whiteboard, timer, notes, links)
- **Toolbar** — Persistent at the very bottom. "Board" = home button.

## Setup (Windows)

### Option A: Quick launch (no install)

Just double-click `launch.bat` — it opens the dashboard fullscreen in Chrome or Edge. Done.

### Option B: Full kiosk setup (auto-starts on boot)

1. Clone the repo:
```
git clone https://github.com/YOUR_USERNAME/office-dashboard.git
cd office-dashboard
```

2. Right-click PowerShell → **Run as Administrator**

3. Run:
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\setup.ps1
```

4. Reboot. The dashboard will auto-launch in fullscreen kiosk mode on every login.

### What `setup.ps1` does

- Copies `index.html` to `%USERPROFILE%\Dashboard\`
- Detects Chrome or Edge
- Creates a kiosk launcher batch file
- Adds a shortcut to the Windows Startup folder (auto-launches on login)
- Disables screen sleep and hibernation on AC power
- Creates a Desktop shortcut for manual launch

### Exiting kiosk mode

- **Alt+F4** closes the browser
- **F11** toggles fullscreen on/off
- **Ctrl+W** closes the tab

### Uninstalling

Run as Administrator:
```powershell
.\uninstall.ps1
```

This removes the Dashboard folder, startup shortcut, desktop shortcut, and restores default power settings.

## Files

```
office-dashboard/
├── index.html       # The entire dashboard (single file, no build step)
├── launch.bat       # Double-click to open dashboard (no install needed)
├── setup.ps1        # One-command kiosk install (run as admin)
├── uninstall.ps1    # Clean removal
├── .gitignore
└── README.md
```

## Configuration

### Countdown target
In `index.html`, find and change:
```javascript
const deadline = new Date('2026-06-12T17:00:00');
```

### Weather location
Update the latitude/longitude in the fetch URL:
```javascript
// San Luis Obispo: 35.28, -120.66
fetch('https://api.open-meteo.com/v1/forecast?latitude=35.28&longitude=-120.66...')
```

### Jira project
Change `SCRUM` in the JQL query inside `loadJiraData()` and update the fallback data array.

### Quick links
Add more `<a class="link-card">` blocks in the `view-links` section.

## Architecture

Single HTML file. No build step. No server. No dependencies. Runs in any browser.

| Feature | Source | Refresh |
|---------|--------|---------|
| Weather | Open-Meteo API (free, no key) | Every 10 min |
| Jira | Anthropic API + Atlassian MCP | Every 5 min (fallback: embedded data) |
| Notes | localStorage | Instant |
| Whiteboard | Canvas API (in-memory) | Clears on refresh |

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Screen goes to sleep | Run `setup.ps1` again, or manually: `powercfg /change monitor-timeout-ac 0` |
| Chrome shows "restore pages" bar | The `--disable-session-crashed-bubble` flag handles this; delete `%LOCALAPPDATA%\Google\Chrome\User Data\Default\Preferences` if it persists |
| Touch not responding | Check Device Manager → Human Interface Devices for the touch driver |
| Weather shows "Unavailable" | Needs internet; Open-Meteo is free but requires connectivity |
| Dashboard doesn't auto-start | Check that `OperatorAidDashboard.lnk` exists in `shell:startup` |

## License

MIT
