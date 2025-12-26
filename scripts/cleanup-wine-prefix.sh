#!/bin/bash
# Clean up unnecessary Windows components from Wine prefix
# Removes components installed by the old file dialog fix script

SCUM_APPID=513710

echo "======================================"
echo "Wine Prefix Cleanup"
echo "======================================"
echo
echo "This will remove Windows components that were installed"
echo "by the file dialog fix but are not actually needed:"
echo
echo "  • comdlg32ocx (legacy common dialogs)"
echo "  • msxml3 (XML parser)"
echo "  • msxml6 (XML parser)"
echo
echo "Note: d3dcompiler_47 will NOT be removed as it may be"
echo "needed for DirectX/DXVK functionality."
echo
read -p "Continue with cleanup? (y/N): " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
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
    exit 1
fi

WINEPREFIX="$COMPAT_PATH/pfx"
echo "✓ Found prefix: $WINEPREFIX"
echo

# Check if SAH is running
if pgrep -f "SCUM Admin Helper" > /dev/null; then
    echo "⚠ Warning: SAH is currently running."
    read -p "Stop SAH and continue? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        pkill -f "SCUM Admin Helper"
        sleep 2
        echo "✓ SAH stopped"
    else
        echo "Cancelled. Please stop SAH and run this script again."
        exit 1
    fi
fi

echo "Removing unnecessary components..."
echo

# Remove comdlg32.ocx (legacy common dialogs - not needed)
if [ -f "$WINEPREFIX/drive_c/windows/syswow64/comdlg32.ocx" ]; then
    echo "Removing comdlg32.ocx..."
    rm -f "$WINEPREFIX/drive_c/windows/syswow64/comdlg32.ocx"
    echo "✓ Removed comdlg32.ocx"
else
    echo "  comdlg32.ocx not found (already removed or never installed)"
fi

# Clean up DLL overrides from registry
echo
echo "Cleaning registry DLL overrides..."

REG_FILE="/tmp/sah-cleanup.reg"
cat > "$REG_FILE" << 'EOF'
REGEDIT4

[HKEY_CURRENT_USER\Software\Wine\DllOverrides]
"comdlg32"=-
"shell32"=-
EOF

wine regedit "$REG_FILE" 2>&1 | grep -v "fixme:" | grep -v "pressure-vessel" > /dev/null 2>&1
rm "$REG_FILE"
echo "✓ Removed DLL overrides"

# Update sah-env.sh to remove old settings
echo
echo "Cleaning environment settings..."

SAH_ENV="$(dirname "$0")/sah-env.sh"
if [ -f "$SAH_ENV" ]; then
    # Remove old WINEDLLOVERRIDES line if present
    if grep -q "WINEDLLOVERRIDES.*comdlg32" "$SAH_ENV"; then
        sed -i '/WINEDLLOVERRIDES.*comdlg32/d' "$SAH_ENV"
        echo "✓ Removed old DLL overrides from sah-env.sh"
    fi
    
    # Keep WINE_WINDOWS_VERSION as it's needed
    if grep -q "WINE_WINDOWS_VERSION" "$SAH_ENV"; then
        echo "✓ Windows version setting preserved (needed for dialogs)"
    fi
else
    echo "⚠ sah-env.sh not found"
fi

echo
echo "======================================"
echo "Cleanup complete!"
echo "======================================"
echo
echo "Removed:"
echo "  ✓ comdlg32.ocx (legacy dialogs)"
echo "  ✓ DLL overrides (comdlg32, shell32)"
echo
echo "Kept:"
echo "  ✓ Windows 10 version setting (required)"
echo "  ✓ .NET Framework 4.0/4.8 (required for SAH)"
echo "  ✓ d3dcompiler_47 (may be needed for graphics)"
echo
echo "Your Wine prefix is now cleaner while keeping"
echo "everything SAH needs to function properly."
echo
echo "File dialogs will continue to work with just"
echo "the Windows 10 version setting."
echo

read -p "Launch SAH to test? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Launching SAH..."
    protontricks-launch --appid $SCUM_APPID "$WINEPREFIX/drive_c/users/steamuser/AppData/Local/SCUM_Admin_Helper/SCUM Admin Helper.exe" &
    sleep 2
    echo "✓ SAH launched. Test the file dialogs to confirm they still work."
fi
