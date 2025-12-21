# Steam Launch Options Examples

## Basic Setup

The standard setup that works for most users:

```bash
/home/USERNAME/launch-sah.sh; %command%; /home/USERNAME/close-sah.sh
```

Replace `USERNAME` with your actual Linux username.

## What Each Part Does

1. **`/home/USERNAME/launch-sah.sh`** - Starts SCUM Admin Helper before the game
2. **`;`** - Separator (run next command after previous completes)
3. **`%command%`** - Steam's placeholder for the actual game launch command
4. **`;`** - Another separator
5. **`/home/USERNAME/close-sah.sh`** - Runs after game exits to close SAH

## Advanced Examples

### With Custom Script Location

If you moved the scripts to a different location:

```bash
/opt/scum-tools/launch-sah.sh; %command%; /opt/scum-tools/close-sah.sh
```

### With Additional Launch Parameters

If you need SCUM game launch parameters:

```bash
/home/USERNAME/launch-sah.sh; %command% -dx11 -lowmemory; /home/USERNAME/close-sah.sh
```

Common SCUM parameters:
- `-dx11` - Use DirectX 11
- `-dx12` - Use DirectX 12
- `-lowmemory` - Low memory mode
- `-high` - High CPU priority
- `-fullscreen` - Force fullscreen
- `-windowed` - Force windowed mode

### With Logging

To log script output for debugging:

```bash
/home/USERNAME/launch-sah.sh 2>&1 | tee ~/sah-launch.log; %command%; /home/USERNAME/close-sah.sh 2>&1 | tee ~/sah-close.log
```

### Running Scripts in Background

To avoid blocking Steam launcher:

```bash
/home/USERNAME/launch-sah.sh & %command%; /home/USERNAME/close-sah.sh
```

**Note:** The `&` after launch script runs it in background. This can help if Steam seems to hang waiting for the script.

## Testing Launch Options

Before using with Steam, test each part:

```bash
# Test launch script
~/launch-sah.sh
# Check if SAH started
ps aux | grep "SCUM Admin Helper"

# Kill it for next test
pkill -f "SCUM Admin Helper"

# Test close script manually
# (Start SAH and SCUM first, then run)
~/close-sah.sh
```

## Troubleshooting Launch Options

### Scripts Don't Run

**Check 1: Permissions**
```bash
ls -l ~/launch-sah.sh ~/close-sah.sh
# Should show -rwxr-xr-x (executable)

# Fix if needed
chmod +x ~/launch-sah.sh ~/close-sah.sh
```

**Check 2: Path is correct**
```bash
# Verify files exist
cat ~/launch-sah.sh
cat ~/close-sah.sh
```

**Check 3: Use absolute paths**
- Always use full paths starting with `/home/`
- Don't use `~` or relative paths in Steam launch options

### SAH Starts But Game Doesn't

**Issue:** Launch script might be blocking.

**Fix:** Add `&` to run in background:
```bash
/home/USERNAME/launch-sah.sh & %command%; /home/USERNAME/close-sah.sh
```

Or add exit to launch script to ensure it doesn't block.

### Game Exits But Close Script Doesn't Run

**Check:** Steam launch options format

**Correct format:**
```bash
script1; %command%; script2
```

**Incorrect formats:**
```bash
script1 %command% script2          # ✗ Missing semicolons
script1; %command% && script2      # ✗ Wrong separator
script1 && %command% && script2    # ✗ Stops if script1 fails
```

## Alternative: No Auto-Close

If you only want to launch SAH but manually close it:

```bash
/home/USERNAME/launch-sah.sh; %command%
```

Then manually kill SAH when done:
```bash
~/development/sah-scripts/scripts/kill-sah.sh
```

## Alternative: Manual Launch

If you prefer to control everything manually, leave launch options empty and use:

```bash
# Before starting SCUM
~/launch-sah.sh

# Start SCUM normally from Steam

# After closing SCUM
~/close-sah.sh
# or
~/development/sah-scripts/scripts/kill-sah.sh
```

## Copying to Clipboard

To easily copy the launch option:

```bash
echo "/home/$USER/launch-sah.sh; %command%; /home/$USER/close-sah.sh"
```

Then copy the output and paste into Steam.
