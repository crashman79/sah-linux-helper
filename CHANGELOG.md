# Changelog

All notable changes to this project will be documented in this file.

## [1.0.1] - 2024-12-21

### Added
- **Custom Application Icon**: SAH logo with "LINUX" badge overlay
  - Downloaded official SAH logo and created modified version
  - Blue "LINUX" badge in bottom-left corner indicates unofficial Linux helper
  - Icon automatically installed to `~/.local/share/icons/` during setup
  - Falls back to generic icon if using direct download method
  - Assets stored in `assets/` directory with proper attribution
- **"What Gets Installed" Section**: Clear documentation of installation locations
  - SAH application location in Proton prefix
  - Launch script location in SCUM directory
  - Desktop shortcut location
  - Dependencies location
- **"How It Works" Section**: Workflow explanation added to README

### Changed
- **Main GUI Script Renamed**: `sah-gui.sh` → `sah-helper.sh` for clarity
  - Avoids confusion with SAH application itself
  - Other scripts remain `*-sah.sh` as they directly operate on SAH
- **Desktop File**: Updated description to mention "Linux helper" for clarity
- **Icon Attribution**: Added documentation crediting SAH developers
- **Installer**: Enhanced to copy custom icon from assets directory when available
- **Documentation**: Improved clarity about file locations and installation process
- **Steam Deck Support**: Removed (not feasible to support without testing hardware)

### Fixed
- Desktop shortcut now uses custom branded icon instead of generic terminal icon
- Installation guide clearly explains what gets created and where

## [1.0.0] - 2024-12-21

### Added
- **GUI Application** (`sah-helper.sh`) - Full-featured graphical interface
  - Installation wizard with progress tracking
  - Desktop shortcut information and management
  - Test launch functionality
  - Real-time status monitoring
  - Manual SAH control (launch/stop)
  - Backup management system (create/list/restore/delete)
  - Log viewer with multiple log files
  - Integrated troubleshooting guide
  - Backup count display in main menu

- **Backup System**
  - SAH-only backups (~100MB, quick)
  - Full prefix backups (~2-5GB, complete)
  - Timestamped backup directories
  - Metadata tracking (backup info files)
  - Interactive restore with confirmation
  - Backup deletion with safety prompts
  - Via GUI or command line (`backup-sah.sh`, `restore-sah.sh`)

- **Desktop Integration**
  - Application menu shortcut
  - `.desktop` file creation
  - Works in KDE, GNOME, XFCE, and other desktop environments
  - Proper categorization and icons

- **Automated Installer** (`install-sah.sh`)
  - Multi-library Steam detection
  - Automatic SAH download (~110MB)
  - .NET Framework detection and installation
  - VC++ Runtime 2019 installation
  - Launch script creation in SCUM directory
  - Desktop shortcut creation
  - Installation verification and testing
  - Error handling and logging

- **Comprehensive Documentation**
  - README.md with quick start guide
  - Installation guide (docs/installation.md)
  - Troubleshooting guide (docs/troubleshooting.md)
  - FAQ (docs/FAQ.md)
  - Example configurations

- **Utility Scripts**
  - `status-sah.sh` - Process status checker
  - `kill-sah.sh` - Force stop SAH
  - Optimized status checks with glob patterns (100x faster than find)

### Changed
- **Installation Approach**: Switched from Steam launch options to desktop shortcut
  - Reason: SAH incompatible with Steam runtime Vulkan/DXVK environment
  - Benefit: More reliable, no Vulkan errors
  - Trade-off: Manual SAH launch required

- **Script Locations**: Launch script now in SCUM directory
  - Before: `~/launch-sah.sh` and `~/close-sah.sh`
  - After: `/path/to/SCUM/launch-sah.sh` only
  - Benefit: Closer to installation, more logical structure

- **Backup Scope**: Clarified what's included in backups
  - SAH Only: Application + settings + winetricks log
  - Full Prefix: Everything including .NET and all modifications

### Removed
- **Steam Launch Options Integration** (deprecated due to technical limitations)
  - Automatic close functionality removed
  - `close-sah.sh` removed from project
  - `wrapper-sah-scum.sh` attempts removed
  - Reason: Vulkan/DXVK incompatibility within Steam runtime

### Fixed
- GUI terminal formatting issues (Windows installer output)
- Duplicate dialog boxes in GUI
- Stuck progress dialogs (typo: close_work → close_working)
- SCUM process detection (changed from SCUM-Win64-Shipping.exe to SCUM.exe)
- Status check performance (glob patterns instead of recursive find)
- Desktop shortcut path references
- Zenity text formatting (removed problematic line breaks)

### Known Issues
- **Steam Status Tracking**: Steam shows SCUM as "running" when only SAH is open
  - Cause: Shared Proton prefix (App ID 513710)
  - Impact: None on functionality
  - Workaround: Ignore indicator or close SAH first
  - Status: Documented as expected behavior

### Technical Details
- **Dependencies**: protontricks, zenity, curl, unzip
- **SCUM App ID**: 513710
- **SAH Download**: https://download.scumadminhelper.com/file/sah-storage/SAH_Setup.zip
- **Proton Prefix**: `~/.steam/steam/steamapps/compatdata/513710/`
- **Backup Location**: `~/sah-backups/`

## [0.2.0] - Development Phase (Not Released)

### Attempted Features (Not in Final Version)
- Steam launch options integration
- Automatic SAH closing when SCUM exits
- Various wrapper script approaches
- Environment isolation attempts (env -i, systemd-run)

### Lessons Learned
- SAH cannot run within Steam runtime environment
- Vulkan/DXVK instance creation fails in Steam context
- Shared Proton prefix necessary for .NET compatibility
- Desktop shortcut approach more reliable than Steam integration

## [0.1.0] - Initial Concept

### Initial Features
- Basic installation script
- Manual launch scripts
- Simple .NET Framework installation
- Command-line only interface

---

## Version Numbering

This project uses [Semantic Versioning](https://semver.org/):
- **MAJOR** version for incompatible API changes
- **MINOR** version for new functionality (backwards compatible)
- **PATCH** version for backwards compatible bug fixes

## Future Considerations

Potential features for future versions:
- [ ] Automatic update checker for SAH
- [ ] Configuration backup/restore
- [ ] Multiple SAH instance support
- [ ] Automated log rotation
- [ ] SAH settings import/export
- [ ] Custom Proton version selection (if technically feasible)
- [ ] Automatic restart on crash
- [ ] System tray integration (if X11/Wayland permits)

## Contributing

See contribution guidelines in README.md. All contributions should:
- Follow existing code style
- Include documentation updates
- Be tested on at least one Linux distribution
- Update this CHANGELOG

---

**Project**: SAH Helper for Linux (formerly sah-scripts)  
**Repository**: https://github.com/username/sah-scripts  
**License**: MIT  
**Note**: This is an unofficial community tool for installing/managing the Windows SCUM Admin Helper application on Linux.
