# Branch Summary: Mac and Linux Audio Toggle Implementations

## Overview

Two new branches have been created with platform-specific implementations of the Audio Toggle utility, mirroring the functionality of the Windows version.

## Branch Details

### 1. Mac Version Branch
**Branch Name:** `copilot/mac-version-installation`
**Status:** ✅ Committed and pushed to remote

**Files Created:**
- `audio_toggle_mac.py` (271 lines) - Main application
- `install_mac.sh` - Installation script
- `uninstall_mac.sh` - Uninstallation script  
- `README_MAC.md` - Comprehensive documentation

**Quick Install Command:**
```bash
curl -fsSL https://raw.githubusercontent.com/pechavarriaa/WindowsAudioProfiles/copilot/mac-version-installation/install_mac.sh | bash
```

**Technical Implementation:**
- **Language:** Python 3
- **UI Framework:** rumps (macOS menu bar application library)
- **Audio Control:** SwitchAudioSource CLI tool (CoreAudio API wrapper)
- **Auto-start:** LaunchAgents (~/Library/LaunchAgents/)
- **Notifications:** Native macOS notifications via rumps
- **Configuration:** JSON file at ~/.config/audio_toggle/config.json
- **Dependencies:** 
  - Python 3.7+
  - rumps (`pip3 install rumps`)
  - pyobjc-framework-Cocoa
  - SwitchAudioSource (`brew install switchaudio-osx`)

**Features:**
✅ Menu bar icon integration (🔊)
✅ One-click audio device toggle
✅ Native macOS notifications
✅ Interactive device configuration
✅ Auto-start on login via LaunchAgents
✅ Lightweight and minimal resource usage

---

### 2. Linux Version Branch
**Branch Name:** `copilot/linux-version-installation`
**Status:** ✅ Committed locally (commit: 2fd6720)
**Note:** Needs to be pushed to remote

**Files Created:**
- `audio_toggle_linux.py` (439 lines) - Main application
- `install_linux.sh` - Multi-distro installation script
- `uninstall_linux.sh` - Uninstallation script
- `README_LINUX.md` - Comprehensive documentation with distro-specific instructions

**Quick Install Command:**
```bash
curl -fsSL https://raw.githubusercontent.com/pechavarriaa/WindowsAudioProfiles/copilot/linux-version-installation/install_linux.sh | bash
```

**Technical Implementation:**
- **Language:** Python 3
- **UI Framework:** GTK 3 + AppIndicator3 (system tray)
- **Audio Control:** pactl (PulseAudio/PipeWire control utility)
- **Auto-start:** XDG autostart (~/.config/autostart/)
- **Notifications:** libnotify (notify-send)
- **Configuration:** JSON file at ~/.config/audio_toggle/config.json
- **Dependencies:**
  - Python 3.6+
  - python3-gi (PyGObject)
  - gir1.2-appindicator3-0.1
  - libnotify
  - pulseaudio-utils (pactl)

**Supported Distributions:**
- ✅ Ubuntu / Debian / Linux Mint / Pop!_OS
- ✅ Fedora / RHEL / CentOS
- ✅ Arch Linux / Manjaro / EndeavourOS
- ✅ openSUSE
- ⚠️ Other distributions (may require manual dependency installation)

**Features:**
✅ System tray icon integration
✅ One-click audio device toggle
✅ Desktop notifications via libnotify
✅ Interactive device configuration
✅ Auto-start on login via XDG autostart
✅ Multi-distro package manager support (apt, dnf, pacman, zypper)
✅ PulseAudio and PipeWire compatibility
✅ GNOME extension instructions for system tray support

**Desktop Environment Compatibility:**
| Desktop Environment | Status |
|---------------------|---------|
| KDE Plasma | ✅ Native support |
| XFCE | ✅ Native support |
| Cinnamon | ✅ Native support |
| MATE | ✅ Native support |
| Budgie | ✅ Native support |
| GNOME | ⚠️ Requires appindicator extension |

---

## Common Features Across All Versions

### Windows (Original)
- PowerShell-based
- System tray integration via Windows Forms
- Core Audio API via inline C#
- Startup folder integration

### macOS (New)
- Python-based
- Menu bar integration via rumps
- CoreAudio via SwitchAudioSource CLI
- LaunchAgents integration

### Linux (New)
- Python-based
- System tray via GTK3/AppIndicator3
- PulseAudio/PipeWire via pactl
- XDG autostart integration

**Shared Functionality:**
1. **Two Audio Profiles:**
   - Profile 1: Headset (headset output + headset microphone)
   - Profile 2: Speakers (speaker output + secondary microphone)

2. **Interactive Configuration:**
   - Lists all available audio devices
   - Numbered selection system
   - Device validation
   - Configuration persistence

3. **Visual Feedback:**
   - System tray/menu bar icon
   - Notifications on device switch
   - Current configuration display

4. **Easy Installation:**
   - One-command installation
   - Automatic dependency management
   - Auto-start configuration
   - Clean uninstallation

---

## Installation Strategy

All three versions follow a similar installation pattern:

### Windows
```powershell
irm https://raw.githubusercontent.com/pechavarriaa/WindowsAudioProfiles/main/install.ps1 | iex
```

### macOS
```bash
curl -fsSL https://raw.githubusercontent.com/pechavarriaa/WindowsAudioProfiles/copilot/mac-version-installation/install_mac.sh | bash
```

### Linux
```bash
curl -fsSL https://raw.githubusercontent.com/pechavarriaa/WindowsAudioProfiles/copilot/linux-version-installation/install_linux.sh | bash
```

Each installer:
1. Checks for and installs required dependencies
2. Downloads the application script
3. Displays available audio devices
4. Guides user through interactive configuration
5. Sets up auto-start on login
6. Launches the application

---

## Testing Status

- **Windows:** ✅ Original implementation, tested and working
- **macOS:** ⚠️ Implementation complete, requires testing on actual macOS system
- **Linux:** ⚠️ Implementation complete, requires testing on various distributions

### Recommended Testing Steps

**For macOS:**
1. Test on macOS 10.14+ (Mojave or later)
2. Verify menu bar icon appearance
3. Test audio device switching
4. Verify notifications work
5. Test auto-start functionality
6. Test with different audio devices (USB, Bluetooth, built-in)

**For Linux:**
1. Test on Ubuntu 20.04+, Fedora 35+, Arch Linux
2. Test on different desktop environments (GNOME, KDE, XFCE)
3. Verify system tray icon (especially on GNOME with extension)
4. Test with PulseAudio and PipeWire
5. Test audio device switching
6. Verify notifications
7. Test auto-start functionality

---

## File Structure

```
WindowsAudioProfiles/
├── main branch (Windows)
│   ├── install.ps1
│   ├── toggleAudio.ps1
│   ├── uninstall.ps1
│   └── README.md
│
├── copilot/mac-version-installation
│   ├── [All Windows files]
│   ├── audio_toggle_mac.py
│   ├── install_mac.sh
│   ├── uninstall_mac.sh
│   ├── README_MAC.md
│   ├── [Linux files also present]
│   ├── audio_toggle_linux.py
│   ├── install_linux.sh
│   ├── uninstall_linux.sh
│   └── README_LINUX.md
│
└── copilot/linux-version-installation
    ├── [All Windows files]
    ├── audio_toggle_linux.py
    ├── install_linux.sh
    ├── uninstall_linux.sh
    └── README_LINUX.md
```

---

## Next Steps

1. **Push Linux branch to remote:**
   ```bash
   git checkout copilot/linux-version-installation
   git push -u origin copilot/linux-version-installation
   ```

2. **Test on target platforms:**
   - Set up macOS test environment
   - Set up Linux VMs for different distros
   - Test all features thoroughly

3. **Clean up Mac branch (optional):**
   - Remove Linux files from Mac branch if you want separation
   - Or keep both implementations in Mac branch for reference

4. **Create pull requests:**
   - Consider creating PRs to merge into main
   - Or maintain as separate branches for platform-specific releases

5. **Update main README:**
   - Add links to Mac and Linux versions
   - Create a matrix showing platform support
   - Add badges for each platform

---

## License

All implementations maintain the same MIT License as the original Windows version.

---

## Contributing

For platform-specific improvements:
- macOS issues/PRs → `copilot/mac-version-installation` branch
- Linux issues/PRs → `copilot/linux-version-installation` branch
- Windows issues/PRs → `main` branch

---

**Last Updated:** 2026-02-09
**Created by:** Copilot Agent
