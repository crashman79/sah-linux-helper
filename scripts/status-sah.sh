#!/bin/bash
# Check SCUM Admin Helper status

HELPER_PROCESS="SCUM Admin Helper.exe"
SCUM_PROCESS="SCUM.exe"
SCUM_APPID=513710

# Parse command line arguments
DETAILED=false
if [ "$1" = "--detailed" ] || [ "$1" = "-d" ]; then
    DETAILED=true
fi

echo "======================================"
echo "SCUM Admin Helper Status"
echo "======================================"
echo

# Check if SAH is running
if pgrep -f "$HELPER_PROCESS" > /dev/null 2>&1; then
    echo "✓ SCUM Admin Helper: RUNNING"
    pgrep -f "$HELPER_PROCESS" | while read pid; do
        echo "  PID: $pid"
    done
else
    echo "✗ SCUM Admin Helper: NOT RUNNING"
fi

echo

# Check if SCUM is running
if pgrep -f "$SCUM_PROCESS" > /dev/null 2>&1; then
    echo "✓ SCUM: RUNNING"
    pgrep -f "$SCUM_PROCESS" | while read pid; do
        echo "  PID: $pid"
    done
else
    echo "✗ SCUM: NOT RUNNING"
fi

echo

# Detailed information if requested
if [ "$DETAILED" = true ]; then
    echo "======================================"
    echo "Detailed Configuration"
    echo "======================================"
    echo
    
    # Find Wine prefix
    COMPAT_PATH=""
    for lib in ~/.steam/steam ~/.local/share/Steam /mnt/*/SteamLibrary /mnt/*/*/SteamLibrary; do
        test_path="$lib/steamapps/compatdata/$SCUM_APPID"
        if [ -d "$test_path" ]; then
            COMPAT_PATH="$test_path"
            break
        fi
    done
    
    if [ -n "$COMPAT_PATH" ]; then
        # Check Windows version in registry
        echo "Proton Prefix Configuration:"
        WINEPREFIX="$COMPAT_PATH/pfx"
        export WINEPREFIX
        
        # Check Windows version setting (directly from user.reg for Proton)
        USER_REG="$COMPAT_PATH/pfx/user.reg"
        WIN_VERSION=""
        if [ -f "$USER_REG" ]; then
            # Look for Version="win10" in the registry file
            if grep -q '"Version"="win10"' "$USER_REG" 2>/dev/null; then
                WIN_VERSION="win10"
            else
                # Check what version is set
                WIN_VERSION=$(grep -oP '"Version"="\K[^"]+' "$USER_REG" 2>/dev/null | head -1)
            fi
        fi
        
        if [ "$WIN_VERSION" = "win10" ]; then
            echo "  Windows Version: $WIN_VERSION"
            echo "    ✓ Set to Windows 10 (file dialogs enabled)"
        elif [ -n "$WIN_VERSION" ]; then
            echo "  Windows Version: $WIN_VERSION"
            echo "    ⚠ Not set to Windows 10 (file dialogs may not work)"
            echo "      Run: ./scripts/fix-file-dialogs.sh"
        else
            echo "  Windows Version: Default (not explicitly set)"
            echo "    ⚠ File dialogs may not work"
            echo "      Run: ./scripts/fix-file-dialogs.sh"
        fi
        echo
        
        # Check SAH delay settings
        CONFIG_DIR="$COMPAT_PATH/pfx/drive_c/users/steamuser/AppData/Local/SCUM_Admin_Helper"
        if [ -d "$CONFIG_DIR" ]; then
            CONFIG_FILE=$(find "$CONFIG_DIR" -name "user.config" -type f 2>/dev/null | head -1)
            
            if [ -n "$CONFIG_FILE" ] && [ -f "$CONFIG_FILE" ]; then
                echo "SAH Delay Settings:"
                
                # Check OpenDelay setting
                OPEN_DELAY=$(grep -o '"OpenDelay":"[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)
                
                if [ -n "$OPEN_DELAY" ]; then
                    echo "  Open Chat Delay: ${OPEN_DELAY}ms"
                    
                    # Categorize the delay
                    if [ "$OPEN_DELAY" -lt 1500 ]; then
                        echo "    Profile: Fast/Custom"
                    elif [ "$OPEN_DELAY" -ge 1500 ] && [ "$OPEN_DELAY" -lt 1750 ]; then
                        echo "    Profile: Fast systems (1500ms)"
                    elif [ "$OPEN_DELAY" -ge 1750 ] && [ "$OPEN_DELAY" -lt 2250 ]; then
                        echo "    Profile: Recommended (2000ms)"
                    elif [ "$OPEN_DELAY" -ge 2250 ] && [ "$OPEN_DELAY" -lt 2750 ]; then
                        echo "    Profile: Slower systems (2500ms)"
                    elif [ "$OPEN_DELAY" -ge 2750 ] && [ "$OPEN_DELAY" -le 3000 ]; then
                        echo "    Profile: Maximum compatibility (3000ms)"
                    else
                        echo "    Profile: Custom"
                    fi
                else
                    echo "  Open Chat Delay: Not configured (using SAH default)"
                    echo "    Profile: Default"
                fi
                echo "    Configure: ./scripts/configure-sah-delays.sh"
            else
                echo "SAH Delay Settings:"
                echo "  ⚠ Configuration file not found"
                echo "    SAH needs to be launched at least once"
            fi
        else
            echo "SAH Delay Settings:"
            echo "  ⚠ SAH not installed or not run yet"
        fi
        echo
        
        # Check .NET installation
        echo "Runtime Environment:"
        if [ -d "$COMPAT_PATH/pfx/drive_c/windows/Microsoft.NET/Framework/v4.0.30319" ]; then
            echo "  .NET Framework: ✓ Installed"
            
            # Check for specific assemblies to verify it's complete
            if [ -f "$COMPAT_PATH/pfx/drive_c/windows/Microsoft.NET/Framework/v4.0.30319/mscorlib.dll" ]; then
                echo "    Version: 4.x detected"
            fi
        else
            echo "  .NET Framework: ✗ Not found"
            echo "    ⚠ SAH requires .NET Framework"
            echo "      Run installation via GUI menu"
        fi
        echo
        
        # Check SAH installation
        SAH_EXE="$COMPAT_PATH/pfx/drive_c/users/steamuser/AppData/Local/SCUM_Admin_Helper/SCUM Admin Helper.exe"
        if [ -f "$SAH_EXE" ]; then
            echo "SAH Installation:"
            echo "  Location: ✓ Found"
            echo "  Path: $(dirname "$SAH_EXE")"
            
            # Check file size to give rough version indication
            SAH_SIZE=$(stat -c%s "$SAH_EXE" 2>/dev/null || echo "0")
            SAH_SIZE_MB=$((SAH_SIZE / 1024 / 1024))
            echo "  Size: ${SAH_SIZE_MB}MB"
            
            # Check last modified date
            SAH_MODIFIED=$(stat -c%y "$SAH_EXE" 2>/dev/null | cut -d' ' -f1)
            echo "  Last modified: $SAH_MODIFIED"
        else
            echo "SAH Installation:"
            echo "  ✗ Not found"
            echo "    Run installation via GUI menu"
        fi
        echo
        
        # Check SCUM installation
        echo "SCUM Installation:"
        SCUM_FOUND=false
        for lib in ~/.steam/steam ~/.local/share/Steam /mnt/*/SteamLibrary /mnt/*/*/SteamLibrary; do
            # Check for either SCUM.exe or SCUM-Win64-Shipping.exe
            if [ -f "$lib/steamapps/common/SCUM/SCUM/Binaries/Win64/SCUM.exe" ] || \
               [ -f "$lib/steamapps/common/SCUM/SCUM/Binaries/Win64/SCUM-Win64-Shipping.exe" ]; then
                echo "  Location: ✓ Found"
                echo "  Library: $lib"
                SCUM_FOUND=true
                
                # Check for intro videos
                MOVIES_PATH="$lib/steamapps/common/SCUM/SCUM/Content/Movies"
                if [ -d "$MOVIES_PATH" ]; then
                    VIDEO_COUNT=0
                    [ -f "$MOVIES_PATH/Intro_Cinematic.mp4" ] && ((VIDEO_COUNT++))
                    [ -f "$MOVIES_PATH/Character_Creation_Cinematic.mp4" ] && ((VIDEO_COUNT++))
                    [ -f "$MOVIES_PATH/SCUMsplash.mp4" ] && ((VIDEO_COUNT++))
                    
                    if [ $VIDEO_COUNT -eq 0 ]; then
                        echo "  Intro videos: Removed (~940MB saved)"
                    elif [ $VIDEO_COUNT -eq 3 ]; then
                        echo "  Intro videos: Present (~940MB)"
                        echo "    Remove via: Advanced Tools > Remove SCUM Videos"
                    else
                        echo "  Intro videos: Partially removed"
                    fi
                fi
                break
            fi
        done
        
        if [ "$SCUM_FOUND" = false ]; then
            echo "  ✗ Not found"
            echo "    Install SCUM via Steam"
        fi
        
    else
        echo "⚠ Wine prefix not found"
        echo "  Make sure SCUM is installed and has been run at least once"
    fi
    
    echo
    echo "======================================"
    echo "Run './scripts/status-sah.sh' without --detailed for quick status"
    echo "======================================"
fi
