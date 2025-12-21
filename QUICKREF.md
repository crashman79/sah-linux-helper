# Quick Reference Guide

**Repository**: https://github.com/crashman79/sah-linux-helper

One-page reference for common tasks with SAH Helper for Linux.

## Installation

```bash
# Clone repository (recommended)
git clone https://github.com/crashman79/sah-linux-helper.git
cd sah-linux-helper

# Or download directly
wget https://raw.githubusercontent.com/crashman79/sah-linux-helper/main/scripts/sah-helper.sh
chmod +x sah-helper.sh

# Install dependencies (choose your distro)
sudo apt install python3-pip zenity curl unzip && pip3 install protontricks  # Ubuntu/Debian
sudo dnf install python3-pip zenity curl unzip && pip3 install protontricks  # Fedora
sudo pacman -S python-pip zenity curl unzip && pip install protontricks      # Arch/CachyOS

# Run SCUM once (creates Proton prefix)
# Launch SCUM from Steam → Exit

# Run installer
./scripts/sah-helper.sh  # GUI (recommended)
# OR
./scripts/install-sah.sh  # Command line
```

## Daily Usage

```bash
# Launch SAH
# Search "SCUM Admin Helper" in application menu
# OR
/path/to/SteamLibrary/steamapps/common/SCUM/launch-sah.sh

# Launch SCUM
# Open Steam → Launch SCUM normally

# Close SAH when done
pkill -f "SCUM Admin Helper.exe"
```

## GUI Commands

```bash
# Open GUI
./scripts/sah-helper.sh

# GUI Menu Options:
# - Install: Run installation wizard
# - Desktop Info: Show shortcut location and usage
# - Test Launch: Test SAH startup
# - Status: Check installation/running status
# - Manual Control: Launch/stop SAH manually
# - Backup Management: Create/restore/delete backups
# - View Logs: Open installation logs
# - Troubleshooting: Common issues and fixes
```

## Command Line Tools

```bash
# Status check
./scripts/status-sah.sh

# Force stop SAH
./scripts/kill-sah.sh
pkill -f "SCUM Admin Helper.exe"     # Graceful
pkill -9 -f "SCUM Admin Helper.exe"  # Force

# Manual launch
/path/to/SteamLibrary/steamapps/common/SCUM/launch-sah.sh

# Backup
./scripts/backup-sah.sh
# Choose: 1=SAH Only (~100MB), 2=Full Prefix (~2-5GB)

# Restore
./scripts/restore-sah.sh
# Select backup to restore
```

## File Locations

```bash
# SAH Installation
~/.steam/steam/steamapps/compatdata/513710/pfx/drive_c/users/steamuser/AppData/Local/SCUM_Admin_Helper/

# .NET Framework
~/.steam/steam/steamapps/compatdata/513710/pfx/drive_c/windows/Microsoft.NET/Framework/v4.0.30319/

# Launch Script
/path/to/SteamLibrary/steamapps/common/SCUM/launch-sah.sh

# Desktop Shortcut
~/.local/share/applications/scum-admin-helper.desktop

# Backups
~/sah-backups/backup-YYYYMMDD-HHMMSS/

# Logs
/tmp/sah-install-dotnet40.log
/tmp/sah-install-dotnet48.log
/tmp/sah-install-vcrun.log
/tmp/sah-launch.log
/tmp/sah-unzip-error.log
```

## Quick Diagnostics

```bash
# Check if SAH is installed
find ~/.steam -name "SCUM Admin Helper.exe" 2>/dev/null

# Check if .NET is installed
find ~/.steam -path "*/Microsoft.NET/Framework/v4.0.30319" 2>/dev/null

# Check dependencies
protontricks --version
zenity --version
curl --version
unzip -v

# Check if SAH/SCUM are running
ps aux | grep -E "(SCUM Admin Helper|SCUM.exe)" | grep -v grep

# Check desktop shortcut
cat ~/.local/share/applications/scum-admin-helper.desktop

# View recent logs
tail -50 /tmp/sah-launch.log
```

## Common Issues

### SAH won't start
```bash
# Check installation
find ~/.steam -name "SCUM Admin Helper.exe"

# Check .NET
find ~/.steam -path "*/Microsoft.NET/Framework/v4.0.30319"

# Check logs
cat /tmp/sah-launch.log

# Reinstall
./scripts/install-sah.sh
```

### Steam shows SCUM running (only SAH is open)
```bash
# Expected behavior - shared Proton prefix
# Options:
# 1. Ignore it (recommended)
# 2. Close SAH first: pkill -f "SCUM Admin Helper.exe"
# 3. Launch SCUM anyway (both will work fine)
```

### Desktop shortcut missing
```bash
# Recreate
./scripts/install-sah.sh  # Won't reinstall SAH, just fixes shortcut

# Update database
update-desktop-database ~/.local/share/applications/
```

### Permission errors
```bash
# Make scripts executable
chmod +x /path/to/sah-scripts/scripts/*.sh
chmod +x /path/to/SCUM/launch-sah.sh
chmod +x ~/.local/share/applications/scum-admin-helper.desktop
```

### protontricks not found
```bash
# Install
pip3 install protontricks

# Add to PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Verify
protontricks --version
```

## Backup Management

```bash
# Create SAH-only backup (fast, ~100MB)
./scripts/sah-helper.sh  # → Backup Management → Create Backup → SAH Only

# Create full prefix backup (slow, ~2-5GB, includes everything)
./scripts/sah-helper.sh  # → Backup Management → Create Backup → Full Prefix

# List all backups
./scripts/sah-helper.sh  # → Backup Management → List Backups

# Restore from backup
./scripts/sah-helper.sh  # → Backup Management → Restore Backup → Select backup

# Delete old backups
./scripts/sah-helper.sh  # → Backup Management → Delete Backups → Select backups

# Manual backup location
ls -lh ~/sah-backups/
```

## Environment Variables

```bash
# Useful for debugging

# Verbose Wine output
export WINEDEBUG=+all

# Disable ESYNC (if issues)
export WINEESYNC=0

# Disable FSYNC (if issues)
export WINEFSYNC=0

# Custom Proton log
export PROTON_LOG=1
export PROTON_LOG_DIR=/tmp/proton_logs/
```

## Advanced: Manual Launch

```bash
# Direct protontricks launch
protontricks-launch --appid 513710 "/path/to/SCUM Admin Helper.exe"

# With Wine directly (not recommended)
WINEPREFIX=~/.steam/steam/steamapps/compatdata/513710/pfx \
  wine "/path/to/drive_c/users/steamuser/AppData/Local/SCUM_Admin_Helper/SCUM Admin Helper.exe"
```

## Getting Help

```bash
# Documentation
cat README.md
cat docs/installation.md
cat docs/troubleshooting.md
cat docs/FAQ.md

# GUI help
./scripts/sah-helper.sh  # → Troubleshooting

# Check logs
ls -lt /tmp/sah*.log | head -5
```

## Uninstallation

```bash
# Remove SAH
find ~/.steam -path "*/SCUM_Admin_Helper" -type d -exec rm -rf {} +

# Remove desktop shortcut
rm ~/.local/share/applications/scum-admin-helper.desktop

# Remove launch script
rm /path/to/SteamLibrary/steamapps/common/SCUM/launch-sah.sh

# Remove backups (optional)
rm -rf ~/sah-backups/

# SCUM remains untouched
```

---

**For detailed information**, see:
- [Installation Guide](docs/installation.md)
- [Troubleshooting](docs/troubleshooting.md)
- [FAQ](docs/FAQ.md)

**Support**:
- GitHub Issues: Bug reports and feature requests
- Documentation: Check docs/ directory first
- Community: SCUM forums and Discord
