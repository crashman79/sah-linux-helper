# Assets

## Icon Files

### sah-linux-helper-icon.png
Custom icon for SAH Helper for Linux desktop shortcut.

**Source**: Original SAH logo from https://scumadminhelper.com/wp-content/uploads/2021/02/splashscreen_logo.png

**Modifications**:
- Resized to 256x256 for standard icon size
- Added blue "LINUX" badge overlay in bottom-left corner
- Indicates this is the unofficial Linux helper tool

**License**: Original SAH logo belongs to SCUM Admin Helper developers. Modified version used for identification purposes only to distinguish the Linux helper tool from the official Windows application.

### sah-original-logo.png
Unmodified original SAH logo (600x220) from official website. Kept for reference.

## Usage

The installer (`scripts/install-sah.sh`) automatically copies `sah-linux-helper-icon.png` to `~/.local/share/icons/hicolor/256x256/apps/scum-admin-helper.png` during installation when using the git clone method.

If the icon file is not found (direct script download), the installer falls back to the standard `application-x-executable` icon.
