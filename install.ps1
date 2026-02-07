#Requires -Version 5.1
<#
.SYNOPSIS
    Installs Audio Toggle to your system.
.DESCRIPTION
    Downloads and installs the Audio Toggle system tray utility.
    Creates shortcuts and optionally adds to Windows startup.
.LINK
    https://github.com/pechavarriaa/WindowsAudioProfiles
#>

param(
    [switch]$AddToStartup,
    [switch]$DesktopShortcut,
    [switch]$Silent
)

$ErrorActionPreference = "Stop"

$repoUrl = "https://raw.githubusercontent.com/pechavarriaa/WindowsAudioProfiles/main"
$installDir = Join-Path $env:LOCALAPPDATA "AudioToggle"
$scriptPath = Join-Path $installDir "toggleAudio.ps1"

function Write-Status {
    param([string]$Message)
    if (-not $Silent) {
        Write-Host $Message -ForegroundColor Cyan
    }
}

function Write-Success {
    param([string]$Message)
    if (-not $Silent) {
        Write-Host $Message -ForegroundColor Green
    }
}

# Create install directory
Write-Status "Creating install directory..."
if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
}

# Download the script
Write-Status "Downloading Audio Toggle..."
try {
    Invoke-WebRequest -Uri "$repoUrl/toggleAudio.ps1" -OutFile $scriptPath -UseBasicParsing
} catch {
    Write-Error "Failed to download script: $_"
    exit 1
}

# Unblock the file
Write-Status "Unblocking script..."
Unblock-File -Path $scriptPath

# Create shortcut helper function
function New-Shortcut {
    param(
        [string]$ShortcutPath,
        [string]$TargetPath,
        [string]$Arguments,
        [string]$IconLocation
    )
    
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($ShortcutPath)
    $shortcut.TargetPath = $TargetPath
    $shortcut.Arguments = $Arguments
    $shortcut.WindowStyle = 7  # Minimized
    if ($IconLocation) {
        $shortcut.IconLocation = $IconLocation
    }
    $shortcut.Save()
}

$pwshPath = "powershell.exe"
$arguments = "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptPath`""
$iconPath = "C:\Windows\System32\SndVol.exe,0"

# Create Start Menu shortcut
Write-Status "Creating Start Menu shortcut..."
$startMenuPath = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\Audio Toggle.lnk"
New-Shortcut -ShortcutPath $startMenuPath -TargetPath $pwshPath -Arguments $arguments -IconLocation $iconPath

# Desktop shortcut (optional)
if ($DesktopShortcut) {
    Write-Status "Creating Desktop shortcut..."
    $desktopPath = Join-Path ([Environment]::GetFolderPath("Desktop")) "Audio Toggle.lnk"
    New-Shortcut -ShortcutPath $desktopPath -TargetPath $pwshPath -Arguments $arguments -IconLocation $iconPath
}

# Add to Startup (optional)
if ($AddToStartup) {
    Write-Status "Adding to Windows Startup..."
    $startupPath = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\Startup\Audio Toggle.lnk"
    New-Shortcut -ShortcutPath $startupPath -TargetPath $pwshPath -Arguments $arguments -IconLocation $iconPath
}

Write-Success "`n=== Installation Complete ==="
Write-Host ""
Write-Host "Installed to: $scriptPath" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Edit the script to set your audio device names:" -ForegroundColor White
Write-Host "     notepad `"$scriptPath`"" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Find your device names by running:" -ForegroundColor White
Write-Host "     . `"$scriptPath`"; Get-AudioDevices" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. Launch from Start Menu: 'Audio Toggle'" -ForegroundColor White
Write-Host ""

if (-not $Silent) {
    $launch = Read-Host "Launch Audio Toggle now? (Y/n)"
    if ($launch -ne 'n' -and $launch -ne 'N') {
        Start-Process $pwshPath -ArgumentList $arguments
    }
}
