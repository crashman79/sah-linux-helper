---
name: Bug report
about: Report a bug with SAH Helper for Linux (installer/scripts)
title: '[BUG] '
labels: bug
assignees: ''
---

**Important**: This is for bugs with the SAH Helper for Linux installer/scripts only. For issues with SCUM Admin Helper itself (the Windows app), please contact the SAH developers directly.

## Bug Description
A clear and concise description of the bug.

## To Reproduce
Steps to reproduce the behavior:
1. Run command '...'
2. Select option '...'
3. See error

## Expected Behavior
What you expected to happen.

## Actual Behavior
What actually happened.

## System Information

### Linux Distribution
```bash
# Run and paste output:
cat /etc/os-release
uname -r
```

**Distribution**: (e.g., Ubuntu 22.04, Fedora 39, Arch Linux, CachyOS, Pop!_OS)
**Based On**: (e.g., Debian, Arch, RHEL)
**Package Manager**: (e.g., apt, dnf, pacman, yay)
**Desktop Environment**: (e.g., GNOME, KDE, Cinnamon, XFCE)

### Steam Installation
- **Steam Type**: [ ] Native Package [ ] Flatpak [ ] Snap [ ] Other: ___
- **Steam Path**: (e.g., `~/.steam/steam` or `~/.var/app/com.valvesoftware.Steam`)
- **SCUM Library**: (e.g., `/mnt/games/SteamLibrary`, `~/.steam/steam/steamapps`)
- **SCUM Path**: (full path to SCUM directory)

### Software Versions
```bash
# Run and paste output:
python3 --version
pip3 --version
protontricks --version || echo "Not installed"
zenity --version || echo "Not installed"
curl --version | head -1
steam --version 2>/dev/null || flatpak info com.valvesoftware.Steam 2>/dev/null | grep -E "ID|Version"
```

### Graphics/Proton
- **GPU**: (e.g., AMD RX 6700 XT, NVIDIA RTX 3060, Intel Arc A770)
- **GPU Driver**: (e.g., Mesa 23.3.1, NVIDIA 545.29.06)
- **Vulkan Version**: `vulkaninfo --summary 2>/dev/null | grep "Vulkan Instance Version" || echo "N/A"`
- **Proton Version**: (Check Steam → SCUM → Properties → Compatibility)

## Diagnostic Information

### Installation Status
```bash
# Run these commands and paste output:
echo "=== SAH Executable ==="
find ~/.steam ~/.local/share/Steam ~/.var/app/com.valvesoftware.Steam -name "SCUM Admin Helper.exe" 2>/dev/null

echo "=== .NET Framework ==="
find ~/.steam ~/.local/share/Steam ~/.var/app/com.valvesoftware.Steam -path "*/Microsoft.NET/Framework/v4.0.30319" 2>/dev/null

echo "=== Launch Script ==="
find ~/.steam ~/.local/share/Steam ~/.var/app/com.valvesoftware.Steam -name "launch-sah.sh" 2>/dev/null
cat $(find ~/.steam ~/.local/share/Steam -name "launch-sah.sh" 2>/dev/null | head -1) 2>/dev/null

echo "=== Desktop Shortcut ==="
cat ~/.local/share/applications/scum-admin-helper.desktop 2>/dev/null

echo "=== Proton Prefix ==="
ls -la ~/.steam/steam/steamapps/compatdata/513710/pfx/drive_c/users/*/AppData/Roaming/ 2>/dev/null
```

### Running Processes
```bash
# Run and paste output:
ps aux | grep -E "(SCUM|SAH|protontricks)" | grep -v grep
pgrep -fa "SCUM|SAH" 2>/dev/null
```

### Dependency Check
```bash
# Run and paste output:
which python3 zenity curl unzip protontricks-launch
pip3 list | grep -i proton
```

## Logs

### Installation Logs
Please check and attach these logs from `/tmp/`:
- [ ] `/tmp/sah-install*.log`
- [ ] `/tmp/sah-launch.log`
- [ ] `/tmp/sah-unzip-error.log`
- [ ] `/tmp/winetricks.log` (from Proton prefix if exists)

```
# Paste relevant log excerpts here or attach files
```

### Recent System Logs (if crashes/errors)
```bash
# Check system logs (optional):
journalctl --user -xe | grep -E "(steam|proton|SCUM)" | tail -50
dmesg | grep -i error | tail -20
```

## Screenshots
If applicable, add screenshots showing:
- Error messages
- GUI dialogs
- Terminal output
- File manager views of installation paths

## Additional Context

### Installation Method
- [ ] GUI installer (sah-helper.sh)
- [ ] CLI installer (install-sah.sh)
- [ ] Manual installation

### Previous Attempts
- [ ] First time installing
- [ ] Reinstalling after uninstall
- [ ] Upgrading from previous version
- [ ] Multiple failed attempts

### Other Relevant Info
Any other context about the problem (custom Steam libraries, external drives, symlinks, unusual permissions, etc.)
