# Single Instance Protection - Cross-Platform

Audio Toggle now includes single-instance protection on all platforms to prevent duplicate tray icons.

## How It Works

### Windows (PowerShell)
**Method**: Global Mutex with installation path hash
- **File**: `toggleAudio.ps1`
- **Mechanism**: Creates a named mutex based on MD5 hash of installation directory
- **Benefits**:
  - Different installations can run simultaneously (dev + production)
  - Same installation = only one instance allowed
  - Automatic cleanup on exit

**Example**:
```powershell
# Mutex name includes path hash
$mutexName = "Global\AudioToggle_$installPathHash"
```

### macOS & Linux (Python)
**Method**: Exclusive file lock (fcntl)
- **Files**: `audio_toggle_mac.py`, `audio_toggle_linux.py`
- **Mechanism**: Exclusive lock on `~/.config/audio_toggle/.audio_toggle.lock`
- **Benefits**:
  - Unix-standard approach (fcntl.LOCK_EX)
  - Automatic cleanup on process termination
  - Works even if process crashes (kernel releases lock)

**Example**:
```python
fcntl.flock(self.lockfile.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
```

## Security Features

### Windows
✅ **Path verification** - Only stops instances from known installation paths
✅ **Unique identifier** - Embedded `$Global:AUDIO_TOGGLE_INSTANCE_ID`
✅ **Confirmation prompt** - Review before stopping processes
✅ **Path-specific mutex** - Different paths = different mutex names

### macOS & Linux
✅ **Lockfile location** - Standard `~/.config/audio_toggle/`
✅ **PID tracking** - Lockfile contains process ID
✅ **Atomic operations** - fcntl guarantees exclusive access
✅ **Auto-cleanup** - Kernel releases lock if process crashes

## Stopping Instances

### Windows
```powershell
# Interactive (with confirmation)
.\stop_all_instances.ps1

# Force stop (no confirmation)
.\stop_all_instances.ps1 -Force
```

### macOS & Linux
```bash
# Make executable (first time only)
chmod +x stop_all_instances.sh

# Run
./stop_all_instances.sh
```

Or manually:
```bash
# macOS
pkill -f "audio_toggle_mac.py"

# Linux
pkill -f "audio_toggle_linux.py"

# Clean up lockfile
rm -f ~/.config/audio_toggle/.audio_toggle.lock
```

## What Happens When You Try to Start a Duplicate?

### Windows
```
Audio Toggle is already running.
```
Script exits silently (exit code 0)

### macOS
```
Audio Toggle is already running.
```
Script exits silently (exit code 0)

### Linux
```
Audio Toggle is already running.
```
Script exits silently (exit code 0)

## Troubleshooting

### Stale Lock (macOS/Linux)

If the app crashed and left a stale lockfile:

**Symptom**: Can't start app, says "already running" but no tray icon

**Solution**:
```bash
# Check for stale lock
ls -la ~/.config/audio_toggle/.audio_toggle.lock

# Check if PID in lockfile is running
cat ~/.config/audio_toggle/.audio_toggle.lock  # Shows PID
ps -p <PID>  # Check if process exists

# If process doesn't exist, remove lockfile
rm ~/.config/audio_toggle/.audio_toggle.lock
```

**Or use the helper script**:
```bash
./stop_all_instances.sh  # Offers to remove stale lockfile
```

### Multiple Installations

**Windows**: Each installation path has its own mutex, so they won't conflict:
- `C:\Users\You\AppData\Local\AudioToggle\` = Mutex A
- `C:\Users\You\source\AudioToggle\` = Mutex B
- Both can run simultaneously ✓

**macOS/Linux**: Single shared lockfile, so only one instance total:
- Installed version OR dev version (not both)
- To run multiple, use different config directories

## Implementation Details

### Windows Mutex Pattern
```powershell
# Create path-specific mutex name
$installPathHash = [MD5]::Create().ComputeHash($PSScriptRoot)
$mutexName = "Global\AudioToggle_$installPathHash"

# Try to acquire
$mutex = New-Object System.Threading.Mutex($false, $mutexName)
if (-not $mutex.WaitOne(0, $false)) {
    exit 0  # Another instance running
}

# Register cleanup
Register-EngineEvent PowerShell.Exiting -Action {
    $mutex.ReleaseMutex()
    $mutex.Dispose()
}
```

### Unix Lockfile Pattern
```python
import fcntl

# Try to acquire exclusive lock
self.lockfile = open(lockfile_path, 'w')
fcntl.flock(self.lockfile.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)

# Write PID for debugging
self.lockfile.write(str(os.getpid()))

# Cleanup registered via atexit
atexit.register(self._release_lock)
```

## Benefits

✅ **No more duplicate tray icons**
✅ **Clean user experience**
✅ **Automatic cleanup** on normal exit
✅ **Kernel cleanup** on crash (Unix)
✅ **Safe process stopping** - only targets verified instances
✅ **Multiple installations supported** (Windows)
✅ **Cross-platform consistency**

## Testing

1. **Start the app normally**
   - Should work fine

2. **Try to start again**
   - Should see "already running" message
   - Should exit immediately

3. **Check tray**
   - Should only see one icon

4. **Exit normally**
   - Lock should be released
   - Can start again successfully

5. **Kill process forcefully**
   - Unix: Lock is automatically released by kernel
   - Windows: Mutex is automatically released by OS

6. **Run stop script**
   - Should find and stop only Audio Toggle instances
   - Should not affect other processes
