#!/bin/bash
# SCUM Admin Helper Installation Script for Linux
# Installs SAH into SCUM's Proton prefix

set -e

SCUM_APPID=513710
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "======================================"
echo "SCUM Admin Helper Linux Installer"
echo "======================================"
echo

# Function to find Steam library paths
find_steam_libraries() {
    local libraries=()
    
    # Default Steam library
    if [ -d "$HOME/.steam/steam" ]; then
        libraries+=("$HOME/.steam/steam")
    fi
    
    # Check libraryfolders.vdf for additional libraries
    local vdf="$HOME/.steam/steam/steamapps/libraryfolders.vdf"
    if [ -f "$vdf" ]; then
        while IFS= read -r line; do
            if [[ $line =~ \"path\"[[:space:]]*\"([^\"]+)\" ]]; then
                libraries+=("${BASH_REMATCH[1]}")
            fi
        done < "$vdf"
    fi
    
    echo "${libraries[@]}"
}

# Find SCUM installation
find_scum_install() {
    local libraries=($(find_steam_libraries))
    
    for lib in "${libraries[@]}"; do
        local scum_path="$lib/steamapps/common/SCUM"
        if [ -d "$scum_path" ]; then
            echo "$scum_path"
            return 0
        fi
    done
    
    return 1
}

# Check dependencies
echo "Checking dependencies..."

HAS_ERRORS=0

if ! command -v protontricks &> /dev/null; then
    echo "✗ ERROR: protontricks is not installed."
    echo "  Install it with one of these methods:"
    echo "    • pip install protontricks"
    echo "    • pip3 install --user protontricks"
    echo "    • sudo apt install protontricks     (Ubuntu/Debian)"
    echo "    • sudo dnf install protontricks     (Fedora)"
    echo "    • yay -S protontricks               (Arch)"
    echo
    HAS_ERRORS=1
fi

if ! command -v curl &> /dev/null; then
    echo "✗ ERROR: curl is not installed."
    echo "  Install it with: sudo apt install curl  (or your package manager)"
    echo
    HAS_ERRORS=1
fi

if ! command -v unzip &> /dev/null; then
    echo "✗ ERROR: unzip is not installed."
    echo "  Install it with: sudo apt install unzip  (or your package manager)"
    echo
    HAS_ERRORS=1
fi

if [ $HAS_ERRORS -eq 1 ]; then
    echo "Please install missing dependencies and try again."
    exit 1
fi

if ! command -v winetricks &> /dev/null; then
    echo "⚠ WARNING: winetricks not found."
    echo "  It's usually installed with protontricks, but may be needed separately."
    echo
fi

echo "✓ All dependencies found"
echo

# Find SCUM installation
echo "Looking for SCUM installation..."
SCUM_PATH=$(find_scum_install)

if [ -z "$SCUM_PATH" ]; then
    echo "✗ ERROR: SCUM installation not found."
    echo
    echo "Troubleshooting:"
    echo "  1. Ensure SCUM is installed via Steam"
    echo "  2. Check Steam library locations:"
    if [ -f "$HOME/.steam/steam/steamapps/libraryfolders.vdf" ]; then
        echo "     Configured Steam libraries:"
        grep -oP '"path"\s*"\K[^"]+' "$HOME/.steam/steam/steamapps/libraryfolders.vdf" 2>/dev/null | while read lib; do
            echo "       - $lib"
        done
    fi
    echo "  3. Manually check if SCUM folder exists:"
    echo "     ls -d ~/.steam/steam/steamapps/common/SCUM"
    echo "     ls -d /mnt/*/SteamLibrary/steamapps/common/SCUM"
    echo
    exit 1
fi

echo "✓ Found SCUM at: $SCUM_PATH"
echo

# Determine the compatdata path
STEAM_LIBRARIES=($(find_steam_libraries))
COMPAT_PATH=""

for lib in "${STEAM_LIBRARIES[@]}"; do
    test_path="$lib/steamapps/compatdata/$SCUM_APPID"
    if [ -d "$test_path" ]; then
        COMPAT_PATH="$test_path"
        break
    fi
done

if [ -z "$COMPAT_PATH" ]; then
    echo "✗ ERROR: SCUM Proton prefix not found."
    echo
    echo "The Proton prefix (compatdata/513710) doesn't exist yet."
    echo
    echo "Resolution:"
    echo "  1. Launch SCUM from Steam at least once"
    echo "  2. Wait for the game to fully load (reach main menu)"
    echo "  3. Exit SCUM"
    echo "  4. Run this installer again"
    echo
    echo "This creates the Wine prefix where SAH will be installed."
    echo
    exit 1
fi

echo "✓ Found Proton prefix at: $COMPAT_PATH"
echo

# SAH installation path in Windows prefix
SAH_INSTALL_PATH="$COMPAT_PATH/pfx/drive_c/users/steamuser/AppData/Local/SCUM_Admin_Helper"
SAH_EXE="$SAH_INSTALL_PATH/SCUM Admin Helper.exe"

# Check if SAH is already installed
if [ -f "$SAH_EXE" ]; then
    echo "SCUM Admin Helper is already installed at:"
    echo "$SAH_INSTALL_PATH"
    echo
    read -p "Reinstall? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
fi

# Download SAH
echo "Downloading SCUM Admin Helper..."
SAH_URL="https://download.scumadminhelper.com/file/sah-storage/SAH_Setup.zip"
TEMP_DIR=$(mktemp -d)
SAH_ZIP="$TEMP_DIR/SAH_Setup.zip"

if ! curl -L -f -o "$SAH_ZIP" "$SAH_URL" --connect-timeout 10 --max-time 300; then
    echo "✗ ERROR: Failed to download SCUM Admin Helper."
    echo
    echo "Troubleshooting:"
    echo "  1. Check your internet connection"
    echo "  2. Try manually downloading from:"
    echo "     $SAH_URL"
    echo
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Verify download
if [ ! -f "$SAH_ZIP" ] || [ ! -s "$SAH_ZIP" ]; then
    echo "✗ ERROR: Downloaded file is missing or empty."
    rm -rf "$TEMP_DIR"
    exit 1
fi

FILE_SIZE=$(stat -f%z "$SAH_ZIP" 2>/dev/null || stat -c%s "$SAH_ZIP" 2>/dev/null)
if [ "$FILE_SIZE" -lt 100000 ]; then
    echo "✗ ERROR: Downloaded file is too small ($FILE_SIZE bytes)."
    rm -rf "$TEMP_DIR"
    exit 1
fi

echo "✓ Downloaded ($FILE_SIZE bytes)"
echo

# Extract the ZIP file to get the installer
echo "Extracting installer from ZIP..."
if ! unzip -q -o "$SAH_ZIP" -d "$TEMP_DIR" 2>/tmp/sah-unzip-error.log; then
    echo "✗ ERROR: Failed to extract ZIP file."
    echo
    echo "Error details:"
    cat /tmp/sah-unzip-error.log
    echo
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Find the installer executable
SAH_INSTALLER=$(find "$TEMP_DIR" -name "*.exe" -type f | head -1)
if [ -z "$SAH_INSTALLER" ] || [ ! -f "$SAH_INSTALLER" ]; then
    echo "✗ ERROR: No installer found in ZIP file."
    echo
    echo "Contents of ZIP:"
    ls -la "$TEMP_DIR/"
    echo
    rm -rf "$TEMP_DIR"
    exit 1
fi

echo "✓ Found installer: $(basename "$SAH_INSTALLER")"
echo

# Run the Windows installer with protontricks
echo "Running SCUM Admin Helper installer..."
echo "This will run silently and may take 5-10 minutes..."
echo "(Installation output logged to /tmp/sah-install.log)"
echo

# Install to the standard location - redirect messy Windows installer output to log
if ! protontricks-launch --appid "$SCUM_APPID" "$SAH_INSTALLER" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /DIR="C:\\users\\steamuser\\AppData\\Local\\SCUM_Admin_Helper" >> /tmp/sah-install.log 2>&1; then
    echo "✗ ERROR: Installer failed to run."
    echo
    echo "This can happen if:"
    echo "  1. .NET Framework is not installed yet (we'll install it next)"
    echo "  2. Proton prefix is corrupted"
    echo "  3. Disk space is insufficient"
    echo
    echo "Trying alternative installation method..."
    echo
fi

# Wait for installation to complete
echo "Waiting for installation to complete..."
sleep 15

rm -rf "$TEMP_DIR"

# Verify installation
if [ ! -f "$SAH_EXE" ]; then
    echo "✗ ERROR: Installation verification failed."
    echo "Expected file not found: $SAH_EXE"
    echo
    echo "Files extracted:"
    ls -la "$SAH_INSTALL_PATH/" 2>/dev/null || echo "  Directory is empty or inaccessible"
    echo
    exit 1
fi

echo "✓ SCUM Admin Helper installed successfully!"
echo

# Install dependencies via protontricks
echo "Checking Wine dependencies..."
echo

# Check if .NET Framework directories already exist
NETFX_PATH="$COMPAT_PATH/pfx/drive_c/windows/Microsoft.NET/Framework"
DOTNET40_EXISTS=0
DOTNET48_EXISTS=0

if [ -d "$NETFX_PATH/v4.0.30319" ]; then
    echo "✓ .NET Framework 4.x already detected"
    DOTNET40_EXISTS=1
    DOTNET48_EXISTS=1
fi

# Install .NET Framework 4.0 (required for SCUM BattlEye)
if [ $DOTNET40_EXISTS -eq 0 ]; then
    echo "Installing .NET Framework 4.0..."
    echo "  (Required for SCUM multiplayer/BattlEye)"
    echo "  This may take 5-10 minutes..."
    DOTNET40_FAILED=0
    if ! protontricks $SCUM_APPID dotnet40 2>&1 | tee /tmp/sah-install-dotnet40.log; then
        if grep -qi "already installed\|winetricks done" /tmp/sah-install-dotnet40.log; then
            echo "✓ .NET Framework 4.0 already installed"
        else
            echo "⚠ Warning: .NET Framework 4.0 installation encountered errors"
            echo "  Check /tmp/sah-install-dotnet40.log for details"
            DOTNET40_FAILED=1
        fi
    else
        echo "✓ .NET Framework 4.0 installed"
    fi
    echo
else
    echo "✓ Skipping .NET Framework 4.0 (already installed)"
    echo
    DOTNET40_FAILED=0
fi

# Install .NET Framework 4.8 (required for SCUM Admin Helper)
if [ $DOTNET48_EXISTS -eq 0 ]; then
    echo "Installing .NET Framework 4.8..."
    echo "  (Required for SCUM Admin Helper)"
    echo "  This may take 10-15 minutes..."
    DOTNET48_FAILED=0
    if ! protontricks $SCUM_APPID dotnet48 2>&1 | tee /tmp/sah-install-dotnet48.log; then
        if grep -qi "already installed\|winetricks done" /tmp/sah-install-dotnet48.log; then
            echo "✓ .NET Framework 4.8 already installed"
        else
            echo "⚠ Warning: .NET Framework 4.8 installation encountered errors"
            echo "  This is CRITICAL for SCUM Admin Helper to work"
            echo "  Check /tmp/sah-install-dotnet48.log for details"
            DOTNET48_FAILED=1
        fi
    else
        echo "✓ .NET Framework 4.8 installed"
    fi
    echo
else
    echo "✓ Skipping .NET Framework 4.8 (already installed)"
    echo
    DOTNET48_FAILED=0
fi

# Install Visual C++ runtimes (commonly needed)
echo "Checking Visual C++ 2019 runtime..."
VCRUN_PATH="$COMPAT_PATH/pfx/drive_c/windows/system32/msvcp140.dll"
if [ -f "$VCRUN_PATH" ]; then
    echo "✓ Visual C++ 2019 runtime already installed"
    echo
else
    echo "Installing Visual C++ 2019 runtime..."
    if ! protontricks $SCUM_APPID vcrun2019 2>&1 | tee /tmp/sah-install-vcrun.log; then
        if grep -qi "already installed\|winetricks done" /tmp/sah-install-vcrun.log; then
            echo "✓ Visual C++ 2019 runtime already installed"
        else
            echo "⚠ Warning: VC++ runtime installation may have failed"
            echo "  Check /tmp/sah-install-vcrun.log for details"
        fi
    else
        echo "✓ Visual C++ 2019 runtime installed"
    fi
    echo
fi

# Verify .NET installations
echo "Verifying .NET Framework installations..."
if [ -d "$NETFX_PATH/v4.0.30319" ]; then
    echo "✓ .NET 4.x installation verified"
else
    echo "✗ WARNING: .NET 4.x directory not found"
    echo "  SAH may not launch properly"
    DOTNET48_FAILED=1
fi

if [ $DOTNET48_FAILED -eq 1 ]; then
    echo
    echo "⚠ IMPORTANT: .NET Framework 4.8 installation issues detected."
    echo "  You may need to manually install it:"
    echo "    protontricks $SCUM_APPID dotnet48"
    echo "  Or check if SCUM needs to be updated/validated."
    echo
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation aborted. Fix .NET issues and try again."
        exit 1
    fi
fi

echo

# Create simple launch script
echo "Creating launch script..."

LAUNCH_SCRIPT="$SCUM_PATH/launch-sah.sh"

cat > "$LAUNCH_SCRIPT" << EOF
#!/bin/bash
# Launch SCUM Admin Helper

APPID=$SCUM_APPID
SAH_PATH="$SAH_EXE"

if [ ! -f "\$SAH_PATH" ]; then
    echo "ERROR: SCUM Admin Helper not found at:"
    echo "\$SAH_PATH"
    exit 1
fi

echo "Launching SCUM Admin Helper..."
protontricks-launch --appid \$APPID "\$SAH_PATH"
EOF

chmod +x "$LAUNCH_SCRIPT"
echo "✓ Launch script created: $LAUNCH_SCRIPT"
echo
echo "    • launch-sah.sh"
echo "    • close-sah.sh"
echo

# Create desktop shortcut
echo "Creating desktop shortcut..."
DESKTOP_FILE="$HOME/.local/share/applications/scum-admin-helper.desktop"
mkdir -p "$HOME/.local/share/applications"

cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=SCUM Admin Helper
Comment=Server administration tool for SCUM
Exec=$LAUNCH_SCRIPT
Icon=utilities-terminal
Terminal=false
Type=Application
Categories=Game;Utility;
EOF

echo "✓ Desktop shortcut created"
echo "  Points to: $LAUNCH_SCRIPT"
echo

# Test SAH can launch
echo "Testing SCUM Admin Helper..."
echo "  Starting SAH in test mode (will close after 5 seconds)..."
echo

TEST_PASSED=0
protontricks-launch --appid $SCUM_APPID "$SAH_EXE" &
SAH_PID=$!

# Wait for process to start
sleep 3

if pgrep -f "SCUM Admin Helper.exe" > /dev/null 2>&1; then
    echo "✓ SCUM Admin Helper launched successfully!"
    TEST_PASSED=1
    # Kill the test instance
    pkill -f "SCUM Admin Helper.exe" 2>/dev/null
    sleep 1
else
    echo "✗ WARNING: Could not verify SAH launch"
    echo "  This might be normal, but SAH may need troubleshooting"
fi

echo

# Installation complete
echo "======================================"
echo "Installation Complete!"
echo "======================================"
echo

if [ $TEST_PASSED -eq 1 ]; then
    echo "✓ All checks passed!"
else
    echo "⚠ Installation completed with warnings."
    echo "  Please test manually: $LAUNCH_SCRIPT"
fi

echo
echo "How to use:"
echo "  • Desktop: Search for 'SCUM Admin Helper' in your application menu"
echo "  • Terminal: $LAUNCH_SCRIPT"
echo "  • Manual close: pkill -f 'SCUM Admin Helper.exe'"
echo
echo "Note: SAH uses SCUM's Proton prefix but runs independently."
echo "      Steam will NOT think SCUM is running when only SAH is open."
echo
