# Installation Guide

Complete step-by-step guide to installing SCUM Admin Helper on Linux.

## What Gets Installed

The installer creates:

1. **SAH Application** (in SCUM's Proton prefix):
   - Location: `~/.steam/.../compatdata/513710/pfx/drive_c/users/steamuser/AppData/Local/SCUM_Admin_Helper/`
   - Contains: `SCUM Admin Helper.exe` and all required files

2. **Launch Script** (in SCUM game directory):
   - Location: `/path/to/SteamLibrary/steamapps/common/SCUM/launch-sah.sh`
   - Self-contained launcher that uses protontricks

3. **Desktop Shortcut** (in your application menu):
   - Location: `~/.local/share/applications/scum-admin-helper.desktop`
   - Points to the launch script above
   - Appears when you search for "SCUM Admin Helper"

4. **Dependencies** (if not already present):
   - .NET Framework 4.0 and 4.8
   - Visual C++ 2019 Runtime
   - All installed into SCUM's Proton prefix

## System Requirements

- **OS**: Any Linux distribution (Ubuntu, Fedora, Arch, CachyOS, etc.)
- **SCUM**: Installed via Steam
- **SCUM Run Once**: Must be launched at least once (creates Proton prefix)
- **Python**: 3.x (usually pre-installed)
- **Internet**: Required for downloading SAH (~110MB)
- **protontricks**: Required for launching SAH with Steam's Proton (ensures proper rendering)

**Note:** SAH uses `protontricks-launch` to run with Steam's Proton runtime, NOT system Wine. This ensures proper graphics rendering and settings persistence.

## Installation Methods

### Method 1: GUI Installer (Recommended)

The GUI provides a guided installation with progress tracking and error handling.

**Option A: Clone Repository (Recommended)**
```bash
git clone https://github.com/crashman79/sah-linux-helper.git
cd sah-linux-helper
./scripts/sah-helper.sh
```

**Option B: Direct Download**
```bash
wget https://raw.githubusercontent.com/crashman79/sah-linux-helper/main/scripts/sah-helper.sh
chmod +x sah-helper.sh
./sah-helper.sh
```

**Steps:**
1. Click "Install" from main menu
2. Read requirements and click Continue
3. Installer opens in terminal
4. Follow on-screen prompts
5. Wait for completion (10-30 minutes)
6. SAH appears in application menu

### Method 2: Command Line

For advanced users or headless systems.

**Option A: From Repository**
```bash
git clone https://github.com/crashman79/sah-linux-helper.git
cd sah-linux-helper
./scripts/install-sah.sh
```

**Option B: Direct Download**
```bash
wget https://raw.githubusercontent.com/crashman79/sah-linux-helper/main/scripts/install-sah.sh
chmod +x install-sah.sh
./install-sah.sh
```

## Prerequisites Setup

### Step 1: Install Dependencies

#### Ubuntu/Debian:
```bash
sudo apt update
sudo apt install python3-pip zenity curl unzip
pip3 install protontricks

# Add pip to PATH if needed
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

#### Fedora:
```bash
sudo dnf install python3-pip zenity curl unzip
pip3 install protontricks
```

#### Arch Linux / CachyOS:
```bash
sudo pacman -S python-pip zenity curl unzip
pip install protontricks
```

### Step 2: Verify Dependencies

```bash
# Check all dependencies
protontricks --version  # Should show version number
zenity --version        # Should show version number
curl --version          # Should show version number
unzip -v                # Should show version number

# If protontricks not found, check PATH
which protontricks
echo $PATH | grep .local/bin
```

### Step 3: Run SCUM Once

**Critical**: SCUM must be launched at least once before installing SAH.

1. Open Steam Library
2. Launch **SCUM**
3. Wait for the game to fully load (main menu appears)
4. Exit SCUM

This creates the Proton prefix at:
```
~/.steam/steam/steamapps/compatdata/513710/pfx/
```

## Running the Installer

### Using GUI (Recommended)

```bash
cd /path/to/sah-scripts
chmod +x scripts/sah-helper.sh
./scripts/sah-helper.sh
```

1. Click **"Install"** from main menu
2. Read the requirements screen
3. Click **"OK"** to continue
4. Installer launches in new terminal window
5. Follow the on-screen prompts

**What the installer does:**
- ✓ Checks for dependencies
- ✓ Locates SCUM installation
- ✓ Detects existing .NET Framework
- ✓ Downloads SAH (~110MB)
- ✓ Extracts to temp directory
- ✓ Installs to SCUM's Proton prefix
- ✓ Installs .NET Framework 4.0/4.8 (if needed)
- ✓ Installs VC++ Runtime 2019
- ✓ Creates launch script in SCUM directory
- ✓ Creates desktop shortcut
- ✓ Tests installation

**Time**: 10-30 minutes (depends on .NET installation)

### Using Command Line

```bash
cd /path/to/sah-scripts
chmod +x scripts/install-sah.sh
./scripts/install-sah.sh
```

Follow the prompts. The installer is interactive and will guide you through each step.

## Post-Installation

### Verify Installation

**Via GUI:**
1. Open GUI: `./scripts/sah-helper.sh`
2. Click **"Status"**
3. Check all items show ✓ (green checkmarks)

**Via Command Line:**
```bash
# Check SAH files exist
find ~/.steam -name "SCUM Admin Helper.exe" 2>/dev/null

# Check .NET Framework
find ~/.steam -path "*/Microsoft.NET/Framework/v4.0.30319" 2>/dev/null

# Check launch script
ls -l /path/to/SteamLibrary/steamapps/common/SCUM/launch-sah.sh

# Check desktop shortcut
ls -l ~/.local/share/applications/scum-admin-helper.desktop
```

### Test Launch

**Via GUI:**
1. Open GUI: `./scripts/sah-helper.sh`
2. Click **"Test Launch"**
3. SAH should start in a few seconds
4. Close SAH when done testing

**Via Command Line:**
```bash
# Launch manually
/path/to/SteamLibrary/steamapps/common/SCUM/launch-sah.sh

# Check if running
ps aux | grep -i "SCUM Admin Helper"

# Close
pkill -f "SCUM Admin Helper.exe"
```

### Create Backup (Recommended)

Before using SAH with your server, create a backup:

**Via GUI:**
1. Open GUI → **"Backup Management"** → **"Create Backup"**
2. Choose "SAH Only" for quick backup
3. Wait for completion

**Via Command Line:**
```bash
./scripts/backup-sah.sh
# Choose option 1 (SAH Only)
```

## Usage

### Launching SAH

**Method 1: Application Menu (Easiest)**
1. Open your application launcher
2. Search for "SCUM Admin Helper"
3. Click to launch

**Method 2: Direct Script**
```bash
/path/to/SteamLibrary/steamapps/common/SCUM/launch-sah.sh
```

**Method 3: Via GUI**
1. Open GUI: `./scripts/sah-helper.sh`
2. Click **"Manual Control"** → **"Launch SAH"**

### Normal Workflow

1. **Launch SAH** (via application menu)
2. **Configure SAH** (connect to server, etc.)
3. **Launch SCUM** (from Steam, normally)
4. **Play SCUM** (SAH manages server in background)
5. **Close SAH** (manually when done)

### Closing SAH

```bash
# Graceful close
pkill -f "SCUM Admin Helper.exe"

# Force kill (if needed)
pkill -9 -f "SCUM Admin Helper.exe"

# Or use GUI
./scripts/sah-helper.sh  # → Manual Control → Stop SAH

# Or use kill script
./scripts/kill-sah.sh
```

## Steam Integration (Not Recommended)

**Note**: Steam launch options integration has been removed from this guide. It caused Vulkan/DXVK errors because SAH cannot run within Steam's runtime environment. The desktop shortcut method is more reliable.

If you must try Steam integration, see [examples/steam-launch-options.md](../examples/steam-launch-options.md) for historical notes, but expect issues.

## Troubleshooting

See [troubleshooting.md](troubleshooting.md) for solutions to common problems:

- protontricks not found
- SCUM installation not detected
- SAH won't launch
- .NET installation fails
- Permission errors
- Download fails
- Steam shows SCUM running when only SAH is open

## Uninstallation

To remove SAH:

```bash
# Find and remove SAH directory
find ~/.steam -path "*/SCUM_Admin_Helper" -type d -exec rm -rf {} +

# Remove desktop shortcut
rm ~/.local/share/applications/scum-admin-helper.desktop

# Remove launch script
rm /path/to/SteamLibrary/steamapps/common/SCUM/launch-sah.sh

# Remove backups (optional)
rm -rf ~/sah-backups/
```

To reinstall after uninstallation, just run the installer again.

## Next Steps

- Read [troubleshooting.md](troubleshooting.md) for common issues
- Create regular backups via GUI or `./scripts/backup-sah.sh`
- Join SCUM community forums for SAH usage help
- Report bugs via GitHub Issues
   (Replace `YOUR_USERNAME` with your actual username)

### 5. Test the Setup

1. Launch SCUM from Steam
2. SCUM Admin Helper should start first
3. Then SCUM game should start
4. When you exit SCUM, SAH should close automatically

## Verification

Check if everything is working:

```bash
# Check SAH installation
find ~/.steam/steam/steamapps/compatdata/513710 -name "SCUM Admin Helper.exe"

# Check script permissions
ls -l ~/launch-sah.sh ~/close-sah.sh

# Test protontricks
protontricks --version
```

## Alternative: Manual Installation

If the automated installer doesn't work, see [Manual Installation](manual-installation.md).

## Next Steps

- Read [Troubleshooting](troubleshooting.md) for common issues
- Check [Usage Guide](usage-guide.md) for advanced options
