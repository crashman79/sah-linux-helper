---
name: Installation problem
about: Issues during SAH installation process
title: '[INSTALL] '
labels: installation, help wanted
assignees: ''
---

**Important**: This is for installation issues with SAH Helper for Linux installer. For issues with SCUM Admin Helper itself (the Windows app), contact the SAH developers directly.

## Installation Issue

### What's happening?
Describe what goes wrong during installation.

### At which stage does it fail?
- [ ] Dependency check (protontricks, zenity, etc.)
- [ ] Downloading SAH
- [ ] Extracting SAH archive
- [ ] Running Windows installer (SAH_Setup.exe)
- [ ] Installing .NET Framework
- [ ] Creating launch script
- [ ] Creating desktop shortcut
- [ ] Other: ___

### Exact error message
```
# Paste the complete error message here
```

## System Information

### Linux Distribution
```bash
# Run and paste:
cat /etc/os-release
uname -r
```

- **Distribution**: 
- **Based On**: (Debian/Arch/RHEL/Other)
- **Package Manager**: (apt/dnf/pacman/etc)

### Steam Installation
- **Steam Type**: [ ] Native [ ] Flatpak [ ] Snap [ ] Other
- **Steam Path**: 
- **SCUM Installed**: [ ] Yes [ ] No
- **SCUM Run Once**: [ ] Yes [ ] No (MUST run once before SAH install)
- **SCUM Library Path**: 

```bash
# Find SCUM installation:
find ~/.steam ~/.local/share/Steam ~/.var/app/com.valvesoftware.Steam -type d -name "SCUM" 2>/dev/null
```

### Dependencies Status
```bash
# Check all dependencies:
echo "Python: $(python3 --version 2>&1)"
echo "pip3: $(pip3 --version 2>&1)"
echo "protontricks: $(protontricks --version 2>&1)"
echo "zenity: $(zenity --version 2>&1)"
echo "curl: $(curl --version 2>&1 | head -1)"
echo "unzip: $(unzip -v 2>&1 | head -1)"

# Check protontricks-launch specifically:
which protontricks-launch && echo "Found" || echo "NOT FOUND"

# Check if protontricks can see SCUM:
protontricks -l 2>&1 | grep -i scum
```

## Installation Attempts

### What did you try?
```bash
# Paste the commands you ran:
./scripts/install-sah.sh
# or
./scripts/sah-helper.sh
```

### Installation Logs
```bash
# Paste contents of:
cat /tmp/sah-install*.log 2>/dev/null

# Also check:
tail -100 /tmp/winetricks.log 2>/dev/null
```

### File System State
```bash
# Check what got created:
echo "=== SAH Files ==="
ls -la ~/.steam/steam/steamapps/compatdata/513710/pfx/drive_c/Program\ Files\ \(x86\)/SAH/ 2>/dev/null

echo "=== .NET Framework ==="
ls -la ~/.steam/steam/steamapps/compatdata/513710/pfx/drive_c/windows/Microsoft.NET/Framework/ 2>/dev/null

echo "=== Launch Script ==="
ls -la ~/.steam/steam/steamapps/common/SCUM/launch-sah.sh 2>/dev/null

echo "=== Desktop File ==="
ls -la ~/.local/share/applications/scum-admin-helper.desktop 2>/dev/null
```

## Network/Download Issues

### Can you reach SAH download URL?
```bash
# Test connectivity:
curl -I https://download.scumadminhelper.com/file/sah-storage/SAH_Setup.zip
```

### Proxy/Firewall?
- [ ] Using VPN
- [ ] Behind corporate firewall
- [ ] Using proxy
- [ ] None of the above

## Disk Space

### Available space in relevant locations:
```bash
# Check space:
df -h ~ /tmp ~/.steam 2>/dev/null
```

- **Home directory**: 
- **SCUM directory**: 
- **/tmp directory**: 

## Previous Installations

- [ ] Fresh first-time install
- [ ] Previously installed SAH (Windows version)
- [ ] Previously tried SAH on Linux
- [ ] Manually modified Proton prefix

### If reinstalling, did you:
- [ ] Run uninstall script
- [ ] Delete old launch script
- [ ] Delete desktop shortcut
- [ ] Remove SAH from Proton prefix

## Additional Context

### Special setup?
- [ ] Custom Steam library location
- [ ] External drive for games
- [ ] Network mounted storage
- [ ] Unusual permissions/ownership
- [ ] SELinux/AppArmor enabled
- [ ] Sandboxed environment

### Other relevant info:
Any other details that might help diagnose the issue.