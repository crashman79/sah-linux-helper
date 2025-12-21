# Troubleshooting Guide

Solutions to common problems with SCUM Admin Helper on Linux.

## Quick Diagnostics

**Use the GUI for fastest diagnosis:**
```bash
./scripts/sah-helper.sh
# Click "Status" or "Troubleshooting"
```

**Command line status check:**
```bash
./scripts/status-sah.sh
```

## Common Issues

### 1. "protontricks is not installed"

**Symptoms:**
- Installer fails with "protontricks command not found"
- `protontricks --version` shows "command not found"

**Solutions:**

**Install via pip:**
```bash
# Try pip3 first
pip3 install protontricks

# Or pip
pip install protontricks

# Verify installation
protontricks --version
```

**Fix PATH if installed but not found:**
```bash
# Add .local/bin to PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Verify
which protontricks
```

### 2. "SCUM installation not found"

**Symptoms:**
- Installer says "SCUM not found in any Steam library"
- Can't locate SCUM directory

**Causes:**
- SCUM not installed
- Installed in non-standard Steam library
- Multiple Steam libraries not detected

**Solutions:**

**Find SCUM manually:**
```bash
# Search for SCUM directory
find ~ -name "SCUM" -type d 2>/dev/null | grep steamapps

# Check Steam library folders
cat ~/.steam/steam/steamapps/libraryfolders.vdf | grep path

# Common locations:
# ~/.steam/steam/steamapps/common/SCUM
# ~/.local/share/Steam/steamapps/common/SCUM
# /mnt/*/SteamLibrary/steamapps/common/SCUM
```

**Verify SCUM is installed:**
1. Open Steam
2. Check Library → SCUM shows "Installed"
3. Note the drive/library it's installed on

**Check installer script is finding all libraries:**
The installer searches these patterns:
- `~/.steam/steam/steamapps`
- `~/.local/share/Steam/steamapps`
- `/mnt/*/SteamLibrary/steamapps`
- `/mnt/*/*/SteamLibrary/steamapps`

If your library is elsewhere, the installer should still work via manual path entry.

### 3. "SCUM Proton prefix not found"

**Symptoms:**
- "compatdata/513710 not found"
- "Proton prefix doesn't exist"

**Cause:** 
SCUM has never been run, so Proton hasn't created the prefix yet.

**Solution:**
```bash
# 1. Launch SCUM from Steam
# 2. Wait for main menu to appear
# 3. Exit SCUM
# 4. Verify prefix was created:
ls -la ~/.steam/steam/steamapps/compatdata/513710/pfx/

# 5. Run installer again
./scripts/install-sah.sh
```

### 4. SAH Won't Launch

**Symptoms:**
- Desktop shortcut does nothing
- Manual launch fails silently
- SAH process doesn't appear

**Diagnosis:**
```bash
# Check if SAH files exist
find ~/.steam -name "SCUM Admin Helper.exe" 2>/dev/null

# Test launch manually and check output
/path/to/SCUM/launch-sah.sh

# Check for errors in log
cat /tmp/sah-launch.log
```

**Common Causes and Fixes:**

**.NET Framework not installed:**
```bash
# Check .NET
find ~/.steam -path "*/Microsoft.NET/Framework/v4.0.30319" 2>/dev/null

# Reinstall if missing
./scripts/install-sah.sh  # Select reinstall .NET
```

**Permissions issue:**
```bash
# Make launch script executable
chmod +x /path/to/SteamLibrary/steamapps/common/SCUM/launch-sah.sh

# Check SAH exe permissions
ls -l ~/.steam/steam/steamapps/compatdata/513710/pfx/drive_c/users/steamuser/AppData/Local/SCUM_Admin_Helper/
```

**Proton environment problem:**
```bash
# Test protontricks
protontricks 513710 --version

# If this fails, reinstall protontricks
pip3 uninstall protontricks
pip3 install protontricks
```

**Vulkan/DXVK errors:**
Check `/tmp/sah-launch.log` for:
- "Failed to create Vulkan instance"
- "DXVK" errors

These are usually harmless warnings. SAH should still work.

### 5. SAH Won't Close / Stuck Process

**Symptoms:**
- SAH window won't close
- Process remains after closing window
- Multiple SAH processes running

**Solutions:**

**Graceful termination:**
```bash
pkill -f "SCUM Admin Helper.exe"
```

**Force kill:**
```bash
pkill -9 -f "SCUM Admin Helper.exe"
```

**Via GUI:**
```bash
./scripts/sah-helper.sh
# → Manual Control → Stop SAH
```

**Via kill script:**
```bash
./scripts/kill-sah.sh
```

**Verify it's stopped:**
```bash
ps aux | grep -i "SCUM Admin Helper"
# Should show no results
```

### 6. Steam Shows SCUM Running When Only SAH is Open

**Symptoms:**
- Steam shows SCUM as "Running" (blue/green)
- Can't launch SCUM because Steam thinks it's already running
- This happens when only SAH is open

**Explanation:**
- This is EXPECTED BEHAVIOR
- SAH uses SCUM's Proton prefix (App ID 513710)
- Steam sees Wine/Proton activity in that prefix
- Steam assumes SCUM is running
- This is harmless and won't affect gameplay

**Solutions:**

**Option 1: Close SAH first** (recommended)
```bash
pkill -f "SCUM Admin Helper.exe"
# Now Steam will show SCUM as not running
```

**Option 2: Ignore the indicator**
- Just launch SCUM normally from Steam
- Both SAH and SCUM will run fine
- Steam tracking doesn't affect functionality

**Option 3: Use GUI control**
```bash
./scripts/sah-helper.sh
# → Manual Control → Stop SAH
```

**Why this happens:**
- SAH needs SCUM's Proton prefix to run (for .NET dependencies)
- Using separate prefix causes .NET incompatibility
- Shared prefix means shared Steam tracking
- Trade-off: Correct .NET environment vs accurate Steam status

### 7. Installation Fails During .NET Setup

**Symptoms:**
- "winetricks failed"
- ".NET installation error"
- Installation hangs during .NET step

**Solutions:**

**Check disk space:**
```bash
df -h ~  # Need at least 5GB free
```

**Retry .NET installation:**
```bash
# The installer skips existing .NET
# To force reinstall, temporarily rename it:
mv ~/.steam/steam/steamapps/compatdata/513710/pfx/drive_c/windows/Microsoft.NET/Framework/v4.0.30319 \
   ~/.steam/steam/steamapps/compatdata/513710/pfx/drive_c/windows/Microsoft.NET/Framework/v4.0.30319.bak

# Run installer again
./scripts/install-sah.sh

# If successful, remove backup:
rm -rf ~/.steam/steam/steamapps/compatdata/513710/pfx/drive_c/windows/Microsoft.NET/Framework/v4.0.30319.bak
```

**Check winetricks log:**
```bash
cat /tmp/sah-install-dotnet40.log
cat /tmp/sah-install-dotnet48.log
```

**Manual .NET installation:**
```bash
protontricks 513710 dotnet40
protontricks 513710 dotnet48
```

### 8. Download Fails

**Symptoms:**
- "Failed to download SAH"
- "curl: connection refused"
- Download hangs or times out

**Solutions:**

**Check internet connection:**
```bash
ping -c 3 google.com
curl -I https://download.scumadminhelper.com
```

**Retry download:**
```bash
# Manual download
cd /tmp
curl -L -o SAH_Setup.zip https://download.scumadminhelper.com/file/sah-storage/SAH_Setup.zip

# Verify download (should be ~110MB)
ls -lh SAH_Setup.zip

# Run installer with existing download
./scripts/install-sah.sh
```

**Check firewall:**
```bash
# Temporarily disable firewall (if safe)
sudo systemctl stop firewalld  # Fedora
sudo ufw disable               # Ubuntu
# Try download again
# Re-enable after testing
```

### 9. Permission Denied Errors

**Symptoms:**
- "Permission denied" when running scripts
- Can't execute install-sah.sh
- Desktop shortcut won't work

**Solutions:**

**Make scripts executable:**
```bash
# All scripts in project
chmod +x /path/to/sah-scripts/scripts/*.sh

# Launch script
chmod +x /path/to/SteamLibrary/steamapps/common/SCUM/launch-sah.sh

# Desktop shortcut
chmod +x ~/.local/share/applications/scum-admin-helper.desktop
```

**Check file ownership:**
```bash
# Scripts should be owned by your user
ls -l /path/to/sah-scripts/scripts/
# If owned by root or another user:
sudo chown -R $USER:$USER /path/to/sah-scripts/
```

### 10. Desktop Shortcut Missing or Doesn't Work

**Symptoms:**
- Can't find "SCUM Admin Helper" in application menu
- Shortcut does nothing when clicked
- Shortcut shows wrong icon

**Solutions:**

**Check if shortcut exists:**
```bash
ls -l ~/.local/share/applications/scum-admin-helper.desktop
cat ~/.local/share/applications/scum-admin-helper.desktop
```

**Recreate shortcut:**
```bash
# Run installer again (won't reinstall SAH, just fixes shortcut)
./scripts/install-sah.sh
```

**Update desktop database:**
```bash
update-desktop-database ~/.local/share/applications/
# Or
xdg-desktop-menu forceupdate
```

**Manual shortcut creation:**
```bash
cat > ~/.local/share/applications/scum-admin-helper.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=SCUM Admin Helper
Comment=Server administration tool for SCUM
Exec=/path/to/SteamLibrary/steamapps/common/SCUM/launch-sah.sh
Icon=application-x-executable
Categories=Game;
Terminal=false
EOF

# Update path to your actual SCUM directory
# Make executable
chmod +x ~/.local/share/applications/scum-admin-helper.desktop
```

### 11. GUI Won't Start

**Symptoms:**
- `./scripts/sah-helper.sh` shows error
- "zenity is required"
- GUI appears then immediately closes

**Solutions:**

**Install zenity:**
```bash
# Ubuntu/Debian
sudo apt install zenity

# Fedora
sudo dnf install zenity

# Arch/CachyOS
sudo pacman -S zenity
```

**Run GUI from terminal to see errors:**
```bash
cd /path/to/sah-scripts
./scripts/sah-helper.sh 2>&1 | tee gui-debug.log
```

**Check for X11/Wayland display:**
```bash
echo $DISPLAY        # Should show :0 or similar
echo $WAYLAND_DISPLAY  # May show wayland-0
```

### 12. Backup/Restore Issues

**Backup fails:**
```bash
# Check disk space
df -h ~  # Need space for backup size

# Check permissions
ls -ld ~/sah-backups/
mkdir -p ~/sah-backups/
```

**Restore fails:**
```bash
# Verify backup exists and is valid
ls -lh ~/sah-backups/backup-YYYYMMDD-HHMMSS/
cat ~/sah-backups/backup-YYYYMMDD-HHMMSS/backup-info.txt

# Check backup structure
ls ~/sah-backups/backup-YYYYMMDD-HHMMSS/SCUM_Admin_Helper/
```

## Advanced Troubleshooting

### Enable Debug Mode

```bash
# Run installer with verbose output
bash -x ./scripts/install-sah.sh 2>&1 | tee install-debug.log

# Run GUI with debug
bash -x ./scripts/sah-helper.sh 2>&1 | tee gui-debug.log
```

### Check Proton Version

```bash
# Find Proton version being used
ls ~/.steam/steam/steamapps/compatdata/513710/config_info

# List available Proton versions
ls ~/.steam/steam/compatibilitytools.d/
ls ~/.steam/steam/steamapps/common/ | grep -i proton
```

### Reset Prefix (Last Resort)

**WARNING**: This deletes all SCUM prefix data including SAH!

```bash
# Backup first!
./scripts/backup-sah.sh  # Choose option 2 (Full Prefix)

# Delete prefix
rm -rf ~/.steam/steam/steamapps/compatdata/513710/

# Launch SCUM to recreate prefix
# Run installer again
```

### Collect Diagnostic Information

For bug reports, collect:

```bash
# System info
uname -a
cat /etc/os-release

# Dependencies
protontricks --version
zenity --version
python3 --version

# SCUM info
find ~/.steam -name "SCUM" -type d 2>/dev/null | grep steamapps
ls -la ~/.steam/steam/steamapps/compatdata/513710/pfx/

# SAH info
find ~/.steam -name "SCUM Admin Helper.exe" 2>/dev/null
ls -l /path/to/SCUM/launch-sah.sh
cat ~/.local/share/applications/scum-admin-helper.desktop

# Logs
cat /tmp/sah-install*.log
cat /tmp/sah-launch.log

# Running processes
ps aux | grep -E "(SCUM|SAH)"
```

## Still Having Issues?

1. **Check logs**: `/tmp/sah-*.log` files contain detailed error information
2. **Use GUI troubleshooting**: `./scripts/sah-helper.sh` → Troubleshooting
3. **Read documentation**: [installation.md](installation.md) for setup help
4. **GitHub Issues**: Report bugs with diagnostic information above
5. **Community Forums**: Ask in SCUM community channels

## Platform-Specific Notes

### Arch-based Distros (Arch, CachyOS, Manjaro)

- Use `pip` not `pip3`
- May need `python-pipx` package
- Check AUR for protontricks-git if issues

### Ubuntu-based Distros

- Need universe repository enabled
- `pip3` is standard
- May need `python3-venv` package

### Fedora/RHEL

- SELinux may block Wine operations
- Consider `setenforce 0` for testing (temporarily)
- Re-enable SELinux after troubleshooting

---

**Last Updated**: December 2025  
**Project**: SAH Helper for Linux (SCUM Admin Helper installer and management tool)  
**Note**: This is an unofficial community tool. SCUM Admin Helper is developed by its respective creators.

**Error:** "Failed to download SCUM Admin Helper"

**Solutions:**
```bash
# Check internet connection
ping github.com

# Try manual download
curl -L -o /tmp/sah.zip https://github.com/EGLDevs/SCUM-Admin-Helper/releases/latest/download/SCUM.Admin.Helper.zip

# Check if curl is installed
which curl || sudo apt install curl
```

### 8. SAH Window Doesn't Appear

**Possible causes:**
- SAH crashed on startup
- Display/graphics issues with Proton

**Debug:**
```bash
# Check if SAH process is running
ps aux | grep -i "scum admin helper"

# Try launching with debug output
protontricks-launch --appid 513710 "/path/to/SCUM Admin Helper.exe"
```

### 9. Multiple SCUM Instances or SAH Won't Close

**Force kill:**
```bash
# Kill all SAH instances
pkill -9 -f "SCUM Admin Helper"

# Kill all SCUM instances
pkill -9 -f "SCUM-Win64"

# Use the kill script
~/development/sah-scripts/scripts/kill-sah.sh
```

## Debug Mode

To see what's happening:

```bash
# Run scripts manually with verbose output
bash -x ~/launch-sah.sh

# Check Steam console output
# In Steam: Settings > Interface > Enable "Display Steam debugging info"
```

## Getting Help

If you're still having issues:

1. Check process status:
   ```bash
   ./scripts/status-sah.sh
   ```

2. Verify installation:
   ```bash
   find ~/.steam -name "SCUM Admin Helper.exe"
   ```

3. Check Steam launch options format:
   ```
   /full/path/launch-sah.sh; %command%; /full/path/close-sah.sh
   ```

4. Test each script individually before using with Steam

## Log Collection

For reporting issues:

```bash
# Collect system info
uname -a
protontricks --version
which protontricks

# Check SAH installation
ls -la ~/.steam/steam/steamapps/compatdata/513710/pfx/drive_c/users/steamuser/AppData/Local/SCUM_Admin_Helper/

# Check running processes
ps aux | grep -iE "(scum|admin)"
```
