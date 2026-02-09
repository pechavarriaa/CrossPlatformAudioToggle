# Fix: Double Instance Startup on Mac

## Problem
After running the Mac installer, two instances of Audio Toggle were being started instead of one.

## Root Cause
The `install_mac.sh` script was starting the application twice:

1. **Via LaunchAgent (Line 108)**: The `launchctl load` command loads the LaunchAgent plist file which has `RunAtLoad` set to `true`, causing it to start immediately.
2. **Via Direct Execution (Line 121)**: The installer manually started the app with `python3 "$INSTALL_DIR/$SCRIPT_NAME" &`

## Solution
Removed the manual app startup (lines 118-121) from the installer since the LaunchAgent already handles starting the application automatically when loaded.

### Changes Made:
- **Removed**: `python3 "$INSTALL_DIR/$SCRIPT_NAME" &` (manual start)
- **Removed**: `echo -e "\n${YELLOW}Starting Audio Toggle now...${NC}"` (misleading message)
- **Updated**: Success message to clarify app starts via LaunchAgent

### Before:
```bash
# Load the LaunchAgent
launchctl load "$LAUNCH_AGENTS_DIR/$PLIST_NAME"

echo -e "\n${YELLOW}Starting Audio Toggle now...${NC}"

# Start the app
python3 "$INSTALL_DIR/$SCRIPT_NAME" &

echo -e "\n${GREEN}✓ Audio Toggle is now running in your menu bar!${NC}"
```

### After:
```bash
# Load the LaunchAgent
launchctl load "$LAUNCH_AGENTS_DIR/$PLIST_NAME"

echo -e "\n${GREEN}✓ Audio Toggle has been installed and started via LaunchAgent!${NC}"
echo -e "The app should appear in your menu bar shortly (🔊)"
```

## Technical Details

The LaunchAgent plist configuration includes:
```xml
<key>RunAtLoad</key>
<true/>
```

This setting causes the application to start immediately when the LaunchAgent is loaded with `launchctl load`. There's no need for a separate manual start.

## Impact
- ✅ Only one instance of Audio Toggle starts after installation
- ✅ Clearer messaging about how the app starts
- ✅ No change to functionality - app still auto-starts on login
- ✅ No duplicate menu bar icons

## Testing
To verify the fix:
1. Run the installer: `bash install_mac.sh`
2. Check running processes: `ps aux | grep audio_toggle_mac.py`
3. Should see only ONE instance (plus the grep command itself)
4. Check menu bar for only ONE audio toggle icon (🔊)

## Related Files
- `install_mac.sh` - Fixed installer script
- `audio_toggle_mac.py` - Application (no changes needed)
- LaunchAgent plist at `~/Library/LaunchAgents/com.pechavarriaa.audiotoggle.plist`

---

**Fixed:** 2026-02-09  
**Branch:** copilot/mac-version-installation  
**Issue:** Two instances starting after installation  
**Solution:** Remove duplicate manual start
