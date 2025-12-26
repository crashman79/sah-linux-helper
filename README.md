# SAH Helper for Linux

> **Comprehensive Linux installer and management suite for *SCUM Admin Helper***

[![GitHub](https://img.shields.io/badge/GitHub-crashman79%2Fsah--linux--helper-blue?logo=github)](https://github.com/crashman79/sah-linux-helper)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**SCUM Admin Helper** (SAH) is a Windows-only server administration tool for SCUM, supported by donations and community contributions. **SAH Helper for Linux** provides automated installation, desktop integration, and management tools to run the Windows SAH application seamlessly on Linux via Proton.

**Bonus**: The .NET Framework installation required by SAH may also enable SCUM multiplayer on Linux (normally broken). This functionality is subject to change with future SCUM updates.

## ✨ Features

- 🎨 **User-friendly GUI** for all operations
- 🚀 **One-click installation** with automatic dependency detection
- 🖥️ **Desktop application integration** (appears in app menu)
- 💾 **Backup & restore system** (SAH-only or full prefix)
- 📊 **Real-time status monitoring**
- 🔧 **Manual control** (launch/stop SAH)
- 📝 **Detailed logging** for troubleshooting

## 🚀 Quick Start

### Option 1: Clone Repository

```bash
git clone https://github.com/crashman79/sah-linux-helper.git
cd sah-linux-helper
./scripts/sah-helper.sh  # GUI installer
# or
./scripts/install-sah.sh  # CLI installer
```

### Option 2: Direct Download

```bash
# Download and run GUI
wget https://raw.githubusercontent.com/crashman79/sah-linux-helper/main/scripts/sah-helper.sh
chmod +x sah-helper.sh
./sah-helper.sh

# Or download CLI installer
wget https://raw.githubusercontent.com/crashman79/sah-linux-helper/main/scripts/install-sah.sh
chmod +x install-sah.sh
./install-sah.sh
```

## 📖 Usage

### Launch SAH

```bash
cd /path/to/sah-scripts
chmod +x scripts/sah-helper.sh
./scripts/sah-helper.sh
```

The GUI provides:
- **Installation Wizard** - Automated setup with progress tracking
- **Desktop Info** - Launch SAH from application menu
- **Test Launch** - Verify installation works
- **Status Monitor** - Check SAH/SCUM/dependencies
- **Manual Control** - Start/stop SAH manually
- **Backup Management** - Create/restore/delete backups
- **Log Viewer** - Review installation logs
- **Troubleshooting** - Common issues and solutions

### Option 2: Command Line

```bash
# Install
cd /path/to/sah-scripts
chmod +x scripts/install-sah.sh
./scripts/install-sah.sh

# Launch (after installation)
# Find shortcut in application menu or run:
/path/to/SteamLibrary/steamapps/common/SCUM/launch-sah.sh
```

## � How It Works

The installer:
1. Downloads SAH from official source (~110MB)
2. Installs SAH into SCUM's Proton prefix (shared .NET environment)
3. Creates `launch-sah.sh` using `protontricks-launch` (Steam's Proton)
4. Creates desktop shortcut pointing to the launch script
5. Desktop shortcut appears in application menu

**Why Proton?** SAH uses Steam's Proton runtime (via protontricks) instead of system Wine to ensure:
- ✅ Proper Direct3D/OpenGL rendering (no graphical glitches)
- ✅ Settings and registration key persistence
- ✅ Consistent .NET Framework environment

**File Locations:**
- **SAH Application**: `~/.steam/.../compatdata/513710/pfx/drive_c/.../SCUM_Admin_Helper/`
- **Launch Script**: `/SteamLibrary/steamapps/common/SCUM/launch-sah.sh`
- **Desktop Shortcut**: `~/.local/share/applications/scum-admin-helper.desktop`

## �📋 Prerequisites

**Required:**
- Linux (any distro: Ubuntu, Fedora, Arch, etc.)
- SCUM installed via Steam
- SCUM launched at least once (creates Proton prefix)
- Python 3.x (usually pre-installed)
- Internet connection

**Dependencies** (installer checks and guides you):
- `protontricks` (Python package) - **Required for launching SAH with Steam's Proton**
- `zenity` (for GUI)
- `curl` (usually pre-installed)
- `unzip` (usually pre-installed)

**Important:** SAH uses Steam's Proton (via `protontricks-launch`) to ensure proper rendering and settings preservation. System Wine is NOT used.

### Quick Dependency Install

```bash
# Ubuntu/Debian
sudo apt install python3-pip zenity curl unzip
pip3 install protontricks

# Fedora
sudo dnf install python3-pip zenity curl unzip
pip3 install protontricks

# Arch/CachyOS
sudo pacman -S python-pip zenity curl unzip
pip install protontricks
```

## 📁 Project Structure

```
sah-scripts/
├── scripts/
│   ├── sah-helper.sh              # Main GUI application ⭐
│   ├── install-sah.sh             # Automated installer
│   ├── configure-sah-delays.sh    # Configure chat delays for Linux
│   ├── fix-file-dialogs.sh        # Fix file import/export dialogs
│   ├── backup-sah.sh              # Backup utility
│   ├── restore-sah.sh             # Restore utility
│   ├── open-sah-folder.sh         # Open SAH folder (for import/export)
│   ├── kill-sah.sh                # Force stop SAH
│   └── status-sah.sh              # Status checker
├── docs/
│   ├── installation.md            # Detailed install guide
│   ├── troubleshooting.md  # Problem solutions
│   └── manual-installation.md  # Manual setup
└── examples/
    └── steam-launch-options.md  # Steam integration notes
```

## 🎮 Usage

### Normal Workflow

1. **Launch SAH** from application menu (search "SCUM Admin Helper")
2. **Launch SCUM** from Steam normally
3. **Use SAH** to manage your server while playing
4. **Close SAH** manually when done (or use `pkill -f 'SCUM Admin Helper.exe'`)

### Desktop Shortcut

After installation, SAH appears in your application menu:
- **KDE:** Search "SCUM" in application launcher
- **GNOME:** Search "SCUM" in activities
- **XFCE:** Check Games or Accessories category

The shortcut points to: `/path/to/SteamLibrary/steamapps/common/SCUM/launch-sah.sh`

### Backup Management

**Via GUI:** Backup Management menu
- Create SAH-only backups (~100MB)
- Create full prefix backups (~2-5GB)
- List/view all backups
- Restore from any backup
- Delete old backups

**Via CLI:**
```bash
# Create backup
./scripts/backup-sah.sh

# Restore backup
./scripts/restore-sah.sh
```

Backups stored in: `~/sah-backups/backup-YYYYMMDD-HHMMSS/`

## ⚠️ Known Limitations

**Steam shows SCUM as "running" when only SAH is open:**
- This is expected and harmless
- Both use SCUM's Proton prefix (App ID 513710)
- Steam sees Wine/Proton activity
- Does NOT affect gameplay or Steam functionality
- Workaround: Close SAH before closing SCUM, or ignore indicator

**File Import/Export dialogs don't work:**
- Wine/Proton doesn't support Windows Vista's Common File Dialog API
- **Workaround**: Use `./scripts/open-sah-folder.sh` to open SAH's folder in your file manager
- Manually drag/drop files for import, or copy exported files from SAH's directory
- See [Troubleshooting Guide](docs/troubleshooting.md#10-file-dialogs-dont-work-importexport) for details

## 🔧 Advanced Usage

### Manual SAH Control
```bash
# Launch SAH
/path/to/SteamLibrary/steamapps/common/SCUM/launch-sah.sh

# Check status
./scripts/status-sah.sh

# Stop SAH
pkill -f 'SCUM Admin Helper.exe'
# Or force kill
./scripts/kill-sah.sh
```

### Command Line Tools

```bash
# Quick status check
./scripts/status-sah.sh

# Force stop SAH
./scripts/kill-sah.sh

# Create backup interactively
./scripts/backup-sah.sh

# Restore from backup
./scripts/restore-sah.sh
```

## 📖 Documentation

- **[Quick Reference](QUICKREF.md)** - One-page command cheat sheet ⭐
- **[Installation Guide](docs/installation.md)** - Complete step-by-step setup
- **[Troubleshooting](docs/troubleshooting.md)** - Solutions to common problems
- **[FAQ](docs/FAQ.md)** - Frequently asked questions
- **[Changelog](CHANGELOG.md)** - Version history and changes
- **[Manual Installation](docs/manual-installation.md)** - Manual setup process (if needed)

## 🐛 Troubleshooting

### Quick Fixes

**SAH won't launch:**
```bash
# Check dependencies
protontricks --version
zenity --version

# Verify installation
find ~/.steam -name "SCUM Admin Helper.exe" 2>/dev/null

# Check .NET Framework
find ~/.steam -path "*/Microsoft.NET/Framework/v4.0.30319" 2>/dev/null
```

**Desktop shortcut missing:**
```bash
# Check if exists
ls -l ~/.local/share/applications/scum-admin-helper.desktop

# Recreate via installer
./scripts/install-sah.sh
```

**Permission errors:**
```bash
# Make scripts executable
chmod +x scripts/*.sh
chmod +x /path/to/SCUM/launch-sah.sh
```

For more solutions, see [docs/troubleshooting.md](docs/troubleshooting.md)

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Test thoroughly on your system
4. Submit a pull request with clear description

## 📝 Technical Details

### How It Works

1. **Installation**: SAH is installed into SCUM's Proton prefix at:
   ```
   ~/.steam/steam/steamapps/compatdata/513710/pfx/drive_c/users/steamuser/AppData/Local/SCUM_Admin_Helper/
   ```

2. **Launch**: Uses `protontricks-launch` with SCUM's App ID (513710) to run SAH in the correct Proton environment

3. **Dependencies**: 
   - .NET Framework 4.0/4.8 (installed via winetricks)
   - VC++ Runtime 2019 (installed via winetricks)

4. **Desktop Integration**: Creates `.desktop` file pointing to launch script in SCUM directory

### File Locations

- **SAH Installation**: `$PREFIX/drive_c/users/steamuser/AppData/Local/SCUM_Admin_Helper/`
- **Launch Script**: `/path/to/SteamLibrary/steamapps/common/SCUM/launch-sah.sh`
- **Desktop Shortcut**: `~/.local/share/applications/scum-admin-helper.desktop`
- **Backups**: `~/sah-backups/backup-YYYYMMDD-HHMMSS/`
- **Logs**: `/tmp/sah-*.log`

## 📜 License

MIT License - See LICENSE file for details

**Important Note**: This project (SAH Helper for Linux) is an **unofficial community tool** for installing and managing the Windows application. SCUM Admin Helper itself is developed and maintained by its respective creators and is supported through donations.

## 🙏 Acknowledgments

- **SCUM Admin Helper** developers for creating the Windows application
- **Protontricks** developers for Proton/Wine integration
- Linux gaming community for testing and feedback
- SCUM players who discovered the multiplayer benefit

## 📞 Support

**For SAH Helper for Linux (this installer):**
- **Issues**: Use GitHub Issues for installation/script bugs
- **Discussions**: Use GitHub Discussions for questions
- **Documentation**: Check [docs/](docs/) directory first

**For SCUM Admin Helper (the Windows app itself):**
- Visit the official SAH website/Discord
- Support the developers through donations

---

**Disclaimer**: SAH Helper for Linux is an unofficial community tool. SCUM Admin Helper is developed by its respective creators. This project only provides Linux installation automation and management.

```bash
# Start SAH manually
./scripts/launch-sah.sh

# Start SCUM through Steam

# When done, kill SAH manually
./scripts/kill-sah.sh
```

## 🐛 Troubleshooting

### SAH not found after installation
```bash
# Check if SAH executable exists
find ~/.steam/steam/steamapps/compatdata/513710 -name "SCUM Admin Helper.exe"
```

### Protontricks errors
```bash
# Update protontricks
pip install --upgrade protontricks

# Clear protontricks cache
rm -rf ~/.cache/protontricks
```

### SAH doesn't close automatically
- Check that `close-sah.sh` is in your Steam launch options
- Verify the script is executable: `chmod +x ~/close-sah.sh`
- Check script output in Steam console

### SAH won't launch
- Ensure SCUM has been run at least once (to create Proton prefix)
- Verify protontricks is installed: `protontricks --version`
- Check for errors: `./scripts/launch-sah.sh`

## 📝 Notes

- **SCUM App ID:** 513710
- **Installation Path:** `~/.steam/steam/steamapps/compatdata/513710/pfx/drive_c/users/steamuser/AppData/Local/SCUM_Admin_Helper/`
- **Scripts work with:** Desktop Linux, any Proton-compatible setup

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📜 License

These scripts are provided as-is for the SCUM community. SCUM Admin Helper is developed by [EGLDevs](https://github.com/EGLDevs/SCUM-Admin-Helper).

## ⚠️ Disclaimer

These scripts are community-created tools and are not officially affiliated with SCUM or Gamepires. Use at your own discretion.

---

<sub>Development assisted by AI tools including GitHub Copilot and Claude.</sub>
