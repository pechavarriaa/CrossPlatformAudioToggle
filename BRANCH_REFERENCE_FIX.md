# Fix: Branch References Updated to 'main'

## Problem
The install scripts and documentation had hardcoded GitHub raw URLs pointing to temporary copilot branches:
- `copilot/mac-version-installation`
- `copilot/linux-version-installation`

These branches will not exist after the PR is merged to main, causing installation to fail.

## Issue Found In

### Install Scripts
1. **install_mac.sh** (Line 72):
   ```bash
   curl -fsSL "https://raw.githubusercontent.com/pechavarriaa/WindowsAudioProfiles/copilot/mac-version-installation/$SCRIPT_NAME"
   ```

2. **install_linux.sh** (Line 97):
   ```bash
   curl -fsSL "https://raw.githubusercontent.com/pechavarriaa/WindowsAudioProfiles/copilot/linux-version-installation/$SCRIPT_NAME"
   ```

### Documentation
3. **README.md** - 4 references to copilot branches
4. **README_MAC.md** - 3 references to copilot branches
5. **README_LINUX.md** - 5 references to copilot branches
6. **REPOSITORY_STATUS.md** - 3 references to copilot branches

## Solution

Changed all branch references from copilot branches to `main`:

### Install Scripts (Fixed)
```bash
# Before
curl -fsSL "https://raw.githubusercontent.com/pechavarriaa/WindowsAudioProfiles/copilot/mac-version-installation/$SCRIPT_NAME"

# After
curl -fsSL "https://raw.githubusercontent.com/pechavarriaa/WindowsAudioProfiles/main/$SCRIPT_NAME"
```

### Documentation (Fixed)
All installation commands now reference `main`:
```bash
# macOS
curl -fsSL https://raw.githubusercontent.com/pechavarriaa/WindowsAudioProfiles/main/install_mac.sh | bash

# Linux
curl -fsSL https://raw.githubusercontent.com/pechavarriaa/WindowsAudioProfiles/main/install_linux.sh | bash
```

## Impact

### Before Fix ❌
```
User runs install command after merge → 404 Not Found
(copilot branch deleted after merge)
```

### After Fix ✅
```
User runs install command after merge → Downloads from main branch
(main branch exists permanently)
```

## Files Modified

| File | Lines Changed | References Fixed |
|------|---------------|------------------|
| install_mac.sh | 1 | 1 URL |
| install_linux.sh | 1 | 1 URL |
| README.md | 4 | 4 URLs |
| README_MAC.md | 3 | 3 URLs |
| README_LINUX.md | 5 | 5 URLs |
| REPOSITORY_STATUS.md | 3 | 3 URLs |
| **Total** | **17** | **17 references** |

## Testing

### Verify URLs Will Work
Once merged to main, users can run:

**macOS:**
```bash
curl -fsSL https://raw.githubusercontent.com/pechavarriaa/WindowsAudioProfiles/main/install_mac.sh | bash
```

**Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/pechavarriaa/WindowsAudioProfiles/main/install_linux.sh | bash
```

Both will download scripts from the main branch and work correctly.

### Verification Commands
```bash
# Check no copilot branch references remain
grep -r "copilot.*installation" . --include="*.sh" --include="*.md"
# Should return no results (except in this doc)
```

## Summary

✅ All 17 branch references updated  
✅ Install scripts will work post-merge  
✅ Documentation commands will work post-merge  
✅ No broken links after branch deletion  

---

**Fixed:** 2026-02-10  
**Issue:** Hardcoded copilot branch references  
**Solution:** Changed all references to 'main' branch  
**Status:** ✅ Complete
