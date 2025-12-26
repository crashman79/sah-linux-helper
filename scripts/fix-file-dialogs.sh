#!/bin/bash
# Set Windows version to Windows 10 for better file dialog compatibility
# This enables SAH's file import/export dialogs on Linux

SCUM_APPID=513710

echo "======================================"
echo "SAH File Dialog Fix"
echo "======================================"
echo
echo "This sets the Windows version to Windows 10 in the"
echo "Wine prefix, which enables file import/export dialogs."
echo
read -p "Continue? (Y/n): " -n 1 -r
echo

if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo
echo "Finding Wine prefix..."

# Find Wine prefix
COMPAT_PATH=""
for lib in ~/.steam/steam ~/.local/share/Steam /mnt/*/SteamLibrary /mnt/*/*/SteamLibrary; do
    test_path="$lib/steamapps/compatdata/$SCUM_APPID"
    if [ -d "$test_path" ]; then
        COMPAT_PATH="$test_path"
        break
    fi
done

if [ -z "$COMPAT_PATH" ]; then
    echo "✗ ERROR: SCUM Proton prefix not found."
    echo "Make sure SCUM is installed."
    exit 1
fi

echo "✓ Found prefix: $COMPAT_PATH"
echo

# Check if protontricks is available
if ! command -v protontricks &> /dev/null; then
    echo "✗ ERROR: protontricks not found."
    echo "Install with: sudo apt install protontricks"
    echo "         or: pip install protontricks"
    exit 1
fi

# Set Windows version to Windows 10 via protontricks
echo "Setting Windows version to Windows 10..."

# Use protontricks to set the registry key
if protontricks $SCUM_APPID reg add "HKEY_CURRENT_USER\\Software\\Wine" /v Version /t REG_SZ /d win10 /f 2>&1 | grep -v "fixme:" | grep -v "pressure-vessel" | head -10; then
    echo "✓ Windows version set to Windows 10"
else
    echo "⚠ Command executed, verifying..."
    # Verify by checking the registry file
    if grep -q '"Version"="win10"' "$COMPAT_PATH/pfx/user.reg" 2>/dev/null; then
        echo "✓ Windows version confirmed as Windows 10"
    else
        echo "⚠ Could not verify setting. File dialogs may not work."
    fi
fi
echo

# Update environment variable
SAH_ENV="$(dirname "$0")/sah-env.sh"
if [ -f "$SAH_ENV" ]; then
    if ! grep -q "WINE_WINDOWS_VERSION" "$SAH_ENV" 2>/dev/null; then
        echo "" >> "$SAH_ENV"
        echo "# Windows version for file dialog compatibility" >> "$SAH_ENV"
        echo 'export WINE_WINDOWS_VERSION="win10"' >> "$SAH_ENV"
        echo "✓ Updated sah-env.sh"
    else
        echo "✓ sah-env.sh already configured"
    fi
fi

echo
echo "======================================"
echo "Configuration complete!"
echo "======================================"
echo
echo "Windows version set to: Windows 10"
echo
echo "Next steps:"
echo "1. Close SAH if running: pkill -f 'SCUM Admin Helper'"
echo "2. Launch SAH again"
echo "3. Test Import/Export buttons - dialogs should now work!"
echo
echo "If dialogs still don't work, you may need to run SAH"
echo "from the desktop shortcut or GUI for the settings to"
echo "take effect."
echo

read -p "Kill SAH now and relaunch? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Stopping SAH..."
    pkill -f "SCUM Admin Helper"
    sleep 2
    echo "✓ SAH stopped. Launching..."
    
    # Source environment and launch SAH
    source "$(dirname "$0")/sah-env.sh"
    protontricks-launch --appid 513710 "$SAH_INSTALL_PATH/SCUM Admin Helper.exe"
    
    echo
    echo "SAH closed."
fi
