#!/bin/bash
# Diagnostic script to test SAH launch and provide detailed troubleshooting info
# This helps identify why SAH isn't launching

SCUM_APPID=513710
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================"
echo "SAH Launch Diagnostics"
echo "========================================"
echo

# Step 1: Check if SAH is installed
echo "1. Checking if SAH is installed..."
SAH_FOUND=0
SAH_EXE=""
for lib in ~/.steam/steam ~/.local/share/Steam /mnt/*/SteamLibrary /mnt/*/*/SteamLibrary; do
    test_exe="$lib/steamapps/compatdata/$SCUM_APPID/pfx/drive_c/users/steamuser/AppData/Local/SCUM_Admin_Helper/SCUM Admin Helper.exe"
    if [ -f "$test_exe" ]; then
        echo "   ✓ Found SAH at: $test_exe"
        SAH_EXE="$test_exe"
        SAH_FOUND=1
        break
    fi
done

if [ $SAH_FOUND -eq 0 ]; then
    echo "   ✗ SAH not found - must install first"
    echo "   Run: ./scripts/install-sah.sh"
    exit 1
fi

# Step 2: Check if SCUM is installed
echo
echo "2. Checking SCUM installation..."
SCUM_FOUND=0
for lib in ~/.steam/steam ~/.local/share/Steam /mnt/*/SteamLibrary /mnt/*/*/SteamLibrary; do
    if [ -d "$lib/steamapps/compatdata/$SCUM_APPID/pfx" ]; then
        echo "   ✓ Found SCUM prefix at: $lib/steamapps/compatdata/$SCUM_APPID/pfx"
        WINEPREFIX="$lib/steamapps/compatdata/$SCUM_APPID/pfx"
        SCUM_FOUND=1
        break
    fi
done

if [ $SCUM_FOUND -eq 0 ]; then
    echo "   ✗ SCUM prefix not found"
    echo "   SCUM must be launched at least once from Steam to create the prefix"
    exit 1
fi

# Step 3: Check .NET Framework
echo
echo "3. Checking .NET Framework installation..."
if [ -d "$WINEPREFIX/drive_c/windows/Microsoft.NET/Framework/v4.0.30319" ]; then
    echo "   ✓ .NET Framework v4.0.30319 found"
else
    echo "   ✗ .NET Framework not found - must reinstall"
    echo "   Run: ./scripts/reinstall-dotnet.sh"
    exit 1
fi

# Step 4: Check if protontricks-launch is available
echo
echo "4. Checking protontricks-launch..."
if command -v protontricks-launch &> /dev/null; then
    echo "   ✓ protontricks-launch is available"
    protontricks-launch --version 2>&1 | head -3 | sed 's/^/      /'
else
    echo "   ✗ protontricks-launch not found"
    echo "   Install with: pip3 install protontricks"
    exit 1
fi

# Step 5: Check Steam is running
echo
echo "5. Checking Steam..."
if pgrep -f "steam" > /dev/null 2>&1; then
    echo "   ✓ Steam is running"
else
    echo "   ✗ Steam is not running - please start it"
    exit 1
fi

# Step 6: Actually try to launch SAH
echo
echo "6. Attempting to launch SAH..."
echo "   Sourcing sah-env.sh..."
source "$SCRIPT_DIR/scripts/sah-env.sh"

echo "   Launching with: protontricks-launch --appid $SCUM_APPID \"$SAH_EXE\""
protontricks-launch --appid $SCUM_APPID "$SAH_EXE" > /tmp/test-sah-launch.log 2>&1 &
TEST_PID=$!
echo "   Process started with PID: $TEST_PID"

# Wait for process
echo "   Waiting for SAH to start (10 seconds)..."
for i in {10..1}; do
    sleep 1
    if pgrep -f "SCUM Admin Helper.exe" > /dev/null 2>&1; then
        echo "   ✓ SAH launched successfully!"
        echo
        echo "7. Cleaning up test..."
        pkill -f "SCUM Admin Helper.exe"
        sleep 1
        echo "   ✓ Test SAH process stopped"
        echo
        echo "========================================"
        echo "✓ ALL CHECKS PASSED - SAH can be launched"
        echo "========================================"
        exit 0
    fi
    echo -n "."
done

echo
echo "   ✗ SAH failed to start within 10 seconds"
echo
echo "7. Checking for error output..."
if [ -f /tmp/test-sah-launch.log ] && [ -s /tmp/test-sah-launch.log ]; then
    echo "   Error log found:"
    echo
    cat /tmp/test-sah-launch.log | sed 's/^/      /'
else
    echo "   No error log generated"
fi

echo
echo "========================================"
echo "TROUBLESHOOTING STEPS:"
echo "========================================"
echo "1. Try reinstalling .NET:"
echo "   ./scripts/reinstall-dotnet.sh"
echo
echo "2. Check if protontricks-launch works:"
echo "   protontricks 513710 --version"
echo
echo "3. Try launching SAH manually:"
echo "   export WINEPREFIX=\"$WINEPREFIX\""
echo "   protontricks-launch --appid $SCUM_APPID \"$SAH_EXE\""
echo
echo "4. Check the error log:"
echo "   cat /tmp/sah-launch.log"
echo
echo "5. If all else fails, reinstall SAH:"
echo "   ./scripts/install-sah.sh"
echo
exit 1
