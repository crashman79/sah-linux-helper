# SAH Launch Troubleshooting - December 29, 2025

## Issue
SAH doesn't appear when launching SCUM + SAH with watchdog, even after timing fixes.

## What I've Improved

### 1. **Timing Enhancements**
- Increased SCUM initialization wait from 2 seconds to 15 seconds
- Added adaptive waiting with progress feedback
- Better logging at each step

### 2. **Error Detection**
- SAH launch now waits up to 10 seconds to detect the process (was 5)
- Added extended 5-second fallback check if initial check fails
- Captures and displays protontricks output for debugging

### 3. **Better Diagnostics**
- Logs protontricks-launch command being executed
- Shows launch process PIDs
- Reports if error log exists and displays contents
- Suggests specific fixes based on error type

### 4. **New Test Script**
Created `test-sah-launch.sh` - comprehensive diagnostics that:
- Verifies SAH is installed
- Checks .NET Framework is present
- Confirms protontricks-launch is available
- Tests actual SAH launch with detailed output
- Shows what went wrong if it fails

## How to Diagnose

### Option 1: Run the Test Script (Easiest)
```bash
cd /home/crashman79/development/sah-scripts
chmod +x test-sah-launch.sh
./test-sah-launch.sh
```

This will show exactly what's failing and provide specific remediation steps.

### Option 2: Use the GUI (With Better Error Messages)
```bash
./scripts/sah-helper.sh
# Select "Launch SCUM + SAH"
```

The GUI now provides much more detailed error information if SAH fails.

### Option 3: Manual Command Line Test
```bash
# Ensure SCUM is running first
steam steam://rungameid/513710 &
sleep 20

# Then launch SAH
source ./scripts/sah-env.sh
protontricks-launch --appid 513710 "/path/to/SCUM Admin Helper.exe" 
```

Check `/tmp/sah-launch.log` for any errors.

## Common Issues and Fixes

### Issue: ".NET Framework not installed"
```bash
./scripts/reinstall-dotnet.sh
```

### Issue: "protontricks-launch: command not found"
```bash
pip3 install protontricks
```

### Issue: "SAH exe not found"
Reinstall SAH:
```bash
./scripts/install-sah.sh
```

### Issue: "Wine/Proton error" in log
Check if SCUM runs normally from Steam first. If SCUM itself has issues, SAH will too.

## What Changed in sah-helper.sh

1. **Lines 575-651**: Enhanced SCUM launch with better initialization detection
2. **Lines 655-780**: Improved SAH launch with:
   - Extended waiting period
   - Better process detection
   - Fallback verification
   - Detailed error messages
3. **Embedded Launcher Script** (lines 256-363): Improved with:
   - Better progress feedback
   - Error handling
   - Timeout management

## Next Steps

1. **Run the test script**: `./test-sah-launch.sh`
2. **Check the output** for what's failing
3. **Apply recommended fix** from the script
4. **Retry** the launch

Please run the test script and share the output if the issue persists!
