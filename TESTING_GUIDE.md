# User Guide: Testing and Troubleshooting Audio Toggle

## Testing the Fix

Now that the toggle logic has been improved, follow these steps to test:

### Step 1: Install or Update
```bash
# If already installed, uninstall first
bash uninstall_mac.sh

# Install fresh
bash install_mac.sh
```

### Step 2: Configure Devices
```bash
# Option A: From menu bar
Click 🔊 icon → Configure Devices...

# Option B: From terminal
python3 ~/.local/share/audio_toggle/audio_toggle_mac.py --configure
```

**Important:** Note the EXACT device names you select!

### Step 3: Test Toggle
```bash
# Click the menu bar icon (🔊) and select "Toggle Audio"
```

### Step 4: Check What Happened

**A. Check the notification:**
- ✅ "Audio Switched to Speakers/Headset" - Success!
- ❌ "Toggle Failed" - Output switch failed
- ⚠️ "Toggle Partial" - Output worked but input failed
- ℹ️ "Configuration Required" - Not configured

**B. Check the actual audio:**
- Play some audio
- Verify it's coming from the correct device
- If it's still on the same device, check logs

### Step 5: Check Debug Logs

```bash
# View logs in real-time
tail -f ~/Library/Logs/audio_toggle.log

# View error logs
tail -f ~/Library/Logs/audio_toggle_error.log

# Or view recent entries
tail -50 ~/Library/Logs/audio_toggle.log
```

**Look for these debug messages:**
```
[Toggle] Current output: 'Built-in Speakers'
[Toggle] Speaker device: 'Built-in Speakers'
[Toggle] Headset output: 'USB Headset'
[Toggle] Switching to Headset: output='USB Headset', input='USB Headset Mic'
```

## Common Issues and Solutions

### Issue 1: "Toggle Failed" notification

**Possible Cause:** Device name mismatch

**Check logs for:**
```
[Toggle] Current output: 'Built-in Speakers '  ← Extra space!
[Toggle] Speaker device: 'Built-in Speakers'
```

**Solution:**
1. Run configuration again
2. Make sure you select the correct devices
3. Device names must match exactly

### Issue 2: Always switches to same device

**Possible Cause:** Current device detection not working

**Check logs for:**
```
[Toggle] Current output: 'None'
```

**Solution:**
1. Verify SwitchAudioSource is installed: `which SwitchAudioSource`
2. Test manually: `SwitchAudioSource -c -t output`
3. Should print current device name

### Issue 3: Switches output but not input

**Notification:** "Toggle Partial: Output switched but input failed"

**Possible Cause:** Input device name wrong or disconnected

**Solution:**
1. Check input device: `SwitchAudioSource -c -t input`
2. List available inputs: `SwitchAudioSource -a -t input`
3. Reconfigure input devices

### Issue 4: Warning about device not matching

**Log message:** "[Toggle] Warning: Current device doesn't match configured devices"

**Cause:** Currently using a device that wasn't configured

**Behavior:** Will default to switching to Speakers

**Solution:**
1. This is expected if you manually changed audio device
2. Toggle will still work, just defaults to Speakers
3. If you want it to toggle from current device, reconfigure including that device

### Issue 5: No logs appearing

**Possible Cause:** Log files not created or app not running via LaunchAgent

**Check:**
```bash
# Check if app is running
ps aux | grep audio_toggle_mac.py

# Check if LaunchAgent is loaded
launchctl list | grep audiotoggle

# Check log directory exists
ls -la ~/Library/Logs/audio_toggle*.log
```

**Solution:**
```bash
# Reload LaunchAgent
launchctl unload ~/Library/LaunchAgents/com.pechavarriaa.audiotoggle.plist
launchctl load ~/Library/LaunchAgents/com.pechavarriaa.audiotoggle.plist
```

## Manual Testing Commands

### Test Device Switching Manually
```bash
# List output devices
SwitchAudioSource -a -t output

# Get current output
SwitchAudioSource -c -t output

# Switch to a specific device
SwitchAudioSource -s "Built-in Speakers" -t output

# List input devices
SwitchAudioSource -a -t input

# Get current input
SwitchAudioSource -c -t input

# Switch input
SwitchAudioSource -s "Built-in Microphone" -t input
```

### Test Configuration File
```bash
# View config
cat ~/.config/audio_toggle/config.json

# Should look like:
# {
#   "speaker_device": "Built-in Speakers",
#   "headset_output": "USB Headset",
#   "speaker_input": "Built-in Microphone",
#   "headset_input": "USB Headset Mic"
# }
```

## Expected Behavior

### Scenario 1: Starting on Speakers
```
Current: Built-in Speakers
Toggle: Switches to USB Headset
Toggle: Switches back to Built-in Speakers
Toggle: Switches to USB Headset
...continues toggling
```

### Scenario 2: Starting on Headset
```
Current: USB Headset
Toggle: Switches to Built-in Speakers
Toggle: Switches to USB Headset
Toggle: Switches to Built-in Speakers
...continues toggling
```

### Scenario 3: Starting on Other Device
```
Current: Bluetooth Speakers (not configured)
Toggle: Switches to Built-in Speakers (fallback)
Toggle: Switches to USB Headset
Toggle: Switches to Built-in Speakers
...continues toggling
```

## Success Criteria

✅ Toggle switches between configured devices  
✅ Notifications are accurate  
✅ Debug logs show what's happening  
✅ Error messages help diagnose issues  
✅ No silent failures  
✅ State remains consistent  

## If It Still Doesn't Work

1. **Check logs** for error messages
2. **Run manual SwitchAudioSource commands** to verify devices exist
3. **Check config.json** has correct device names
4. **Try reconfiguring** to get exact device names
5. **Report the issue** with logs attached

---

**Created:** 2026-02-09  
**Purpose:** Help users test and troubleshoot toggle functionality  
**Status:** Ready for testing
