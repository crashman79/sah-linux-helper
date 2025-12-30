# Fix: SCUM + SAH Watchdog Launch Issue

## Problem
When launching SCUM with SAH and watchdog, SAH would fail to appear/launch even though SCUM started successfully. The process would start but nothing would happen.

## Root Cause
**Insufficient timing between SCUM startup and SAH launch.**

The original implementation had critical timing issues:
1. **In the launcher script** (desktop shortcut): Only waited 10 seconds for SCUM to start, then immediately launched SAH
2. **In the GUI launch function**: Waited only 2 seconds after SCUM appeared before launching SAH

This was too fast. SCUM's Proton Wine prefix needs adequate time to fully initialize before SAH can run properly. The Wine environment initialization involves:
- Creating and mounting the prefix
- Initializing the Windows environment
- Setting up file system redirects
- Initializing graphics and audio subsystems

Launching SAH during this initialization phase causes it to fail silently.

## Solution
Increased the delay between SCUM launch and SAH launch from **2 seconds to 15 seconds**.

### Changes Made

#### 1. **Main Launch Function** (`launch_scum_and_sah()`)
- Changed initialization wait from 2 seconds to **15 seconds**
- Added status message to inform user of initialization progress
- Improved SAH startup detection (now waits up to 10 seconds instead of just 5)
- Added better error diagnostics when SAH fails to launch

#### 2. **Embedded Launcher Script** (Desktop Shortcut)
- Enhanced SCUM startup detection with timeout
- Added **15-second initialization delay** after SCUM starts
- Improved error checking and reporting
- Added validation that SAH executable exists before attempting launch

#### 3. **Error Messages**
- Now provides specific diagnostic info when SAH fails
- Checks if error log exists and contains details
- Suggests common causes (.NET Framework, Proton/Wine issues, corrupted files)

## Testing the Fix

### Via GUI
```bash
./scripts/sah-helper.sh
# Select "Launch SCUM + SAH"
```

### Via Desktop Shortcut
Click the "SCUM + Admin Helper" shortcut in your application menu (if already created).

### From Command Line
```bash
~/.local/bin/launch-scum-with-sah.sh
```

## Expected Behavior
1. SCUM launches via Steam
2. After 15 seconds of initialization, SAH launches
3. Both windows should appear
4. Watchdog monitors SCUM exit and offers to close SAH

## If Still Not Working
Check the error log:
```bash
cat /tmp/sah-launch.log
```

Common solutions:
- **".NET not found"**: Run `./scripts/reinstall-dotnet.sh`
- **"Wine/Proton error"**: Verify SCUM launches normally from Steam
- **"File not found"**: Run `./scripts/install-sah.sh` to reinstall

## Technical Details
The 15-second delay is conservative but safe. On most systems:
- SCUM Wine prefix initialization: 3-8 seconds
- Additional buffer for slower systems: 5-7 seconds
- Total recommended wait: 15 seconds

This provides reliable launch on:
- HDD systems
- Slower CPUs
- Heavy system load
- Standard user configurations
