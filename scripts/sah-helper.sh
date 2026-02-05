#!/bin/bash
# SCUM Admin Helper GUI Launcher
# Provides graphical interface for managing SAH installation and configuration

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCUM_APPID=513710

# Terminal logging function
log() {
    echo "[$(date '+%H:%M:%S')] $1"
}

# Check if zenity is available
if ! command -v zenity &> /dev/null; then
    echo "ERROR: zenity is required for the GUI."
    echo "Install it with:"
    echo "  Ubuntu/Debian: sudo apt install zenity"
    echo "  Fedora: sudo dnf install zenity"
    echo "  Arch: sudo pacman -S zenity"
    echo
    echo "Or run the scripts directly from the command line."
    exit 1
fi

# Require a display (X11 or Wayland)
if [ -z "${DISPLAY:-}" ] && [ -z "${WAYLAND_DISPLAY:-}" ]; then
    echo "ERROR: No display found. DISPLAY and WAYLAND_DISPLAY are unset." >&2
    echo "Run this script from a terminal inside your graphical session (not over SSH without -X)." >&2
    exit 1
fi

log "SCUM Admin Helper GUI started"

# Function to show info dialog
show_info() {
    zenity --info --title="SCUM Admin Helper" --text="$1" --width=400 --no-wrap 2>/dev/null
}

# Function to show error dialog
show_error() {
    zenity --error --title="SCUM Admin Helper - Error" --text="$1" --width=400 --no-wrap 2>/dev/null
}

# Function to show question dialog
ask_question() {
    zenity --question --title="SCUM Admin Helper" --text="$1" --width=400 --no-wrap --ok-label="Yes" --cancel-label="No" 2>/dev/null
}

# Function to show a brief working notification
# First call runs zenity without hiding stderr so display/GTK errors are visible
show_working() {
    local title="${1:-Working}"
    local message="${2:-Please wait...}"
    if [ -z "${ZENITY_STDERR_SHOWN:-}" ]; then
        (
            echo "0"
            echo "# $message"
            while true; do
                sleep 0.2
                echo "# $message"
            done
        ) | zenity --progress --title="$title" --pulsate --auto-close --no-cancel --width=300 2>&1 &
        WORKING_PID=$!
        ZENITY_STDERR_SHOWN=1
    else
        (
            echo "0"
            echo "# $message"
            while true; do
                sleep 0.2
                echo "# $message"
            done
        ) | zenity --progress --title="$title" --pulsate --auto-close --no-cancel --width=300 2>/dev/null &
        WORKING_PID=$!
    fi
}

# Function to close working dialog
close_working() {
    if [ -n "$WORKING_PID" ]; then
        kill $WORKING_PID 2>/dev/null
        wait $WORKING_PID 2>/dev/null
        WORKING_PID=""
    fi
}

# Function to check installation status
check_installation_status() {
    local status=""
    local sah_installed=0
    local dotnet_installed=0
    local quiet=${1:-0}
    
    [ "$quiet" -eq 0 ] && log "Checking installation status..."
    [ "$quiet" -eq 0 ] && show_working "Status Check" "Checking installation status..."
    
    # Check if SAH is installed - use faster glob search instead of find
    local sah_found=0
    for lib in ~/.steam/steam ~/.local/share/Steam /mnt/*/SteamLibrary /mnt/*/*/SteamLibrary; do
        if [ -f "$lib/steamapps/compatdata/$SCUM_APPID/pfx/drive_c/users/steamuser/AppData/Local/SCUM_Admin_Helper/SCUM Admin Helper.exe" ]; then
            sah_found=1
            break
        fi
    done
    
    if [ $sah_found -eq 1 ]; then
        status="${status}✓ SCUM Admin Helper: INSTALLED\n"
        sah_installed=1
    else
        status="${status}✗ SCUM Admin Helper: NOT INSTALLED\n"
    fi
    
    # Check if .NET is installed - use same faster approach
    local dotnet_found=0
    for lib in ~/.steam/steam ~/.local/share/Steam /mnt/*/SteamLibrary /mnt/*/*/SteamLibrary; do
        if [ -d "$lib/steamapps/compatdata/$SCUM_APPID/pfx/drive_c/windows/Microsoft.NET/Framework/v4.0.30319" ]; then
            dotnet_found=1
            break
        fi
    done
    
    if [ $dotnet_found -eq 1 ]; then
        status="${status}✓ .NET Framework: INSTALLED\n"
        dotnet_installed=1
    else
        status="${status}✗ .NET Framework: NOT FOUND\n"
    fi
    
    # Check desktop shortcut
    if [ -f "$HOME/.local/share/applications/scum-admin-helper.desktop" ]; then
        status="${status}✓ Desktop Shortcut: INSTALLED\n"
    else
        status="${status}✗ Desktop Shortcut: NOT FOUND\n"
    fi
    
    # Check if processes are running
    if pgrep -f "SCUM Admin Helper.exe" > /dev/null 2>&1; then
        status="${status}✓ SAH Status: RUNNING\n"
    else
        status="${status}○ SAH Status: NOT RUNNING\n"
    fi
    
    if pgrep -f "SCUM.exe" > /dev/null 2>&1; then
        status="${status}✓ SCUM Status: RUNNING\n"
    else
        status="${status}○ SCUM Status: NOT RUNNING\n"
    fi
    
    [ "$quiet" -eq 0 ] && close_working
    
    echo "$status"
    
    # Return overall status
    if [ $sah_installed -eq 1 ] && [ $dotnet_installed -eq 1 ]; then
        return 0
    else
        return 1
    fi
}

# Function to run installation
run_installation() {
    log "User selected: Install"
    if [ ! -f "$SCRIPT_DIR/install-sah.sh" ]; then
        log "ERROR: Installation script not found"
        show_error "Installation script not found at:\n$SCRIPT_DIR/install-sah.sh"
        return 1
    fi
    
    # Show pre-installation info
    zenity --info --title="SCUM Admin Helper Installation" --width=500 --text="<b>Installation Requirements:</b>

• SCUM must be installed via Steam
• SCUM must be launched at least once
• Internet connection required
• protontricks must be installed

The installer will:
1. Download SCUM Admin Helper
2. Install to SCUM's Proton prefix
3. Install .NET Framework dependencies
4. Create helper scripts
5. Test the installation

This may take 10-30 minutes.

Continue?" 2>/dev/null || {
        log "User cancelled installation"
        return 1
    }
    
    log "Launching installation script in terminal..."
    # Run installation in terminal - the terminal process blocks until completion
    if command -v gnome-terminal &> /dev/null; then
        gnome-terminal -- bash -c "cd '$SCRIPT_DIR' && ./install-sah.sh; echo; echo 'Press Enter to close...'; read"
    elif command -v konsole &> /dev/null; then
        konsole -e bash -c "cd '$SCRIPT_DIR' && ./install-sah.sh; echo; echo 'Press Enter to close...'; read"
    elif command -v xterm &> /dev/null; then
        xterm -e bash -c "cd '$SCRIPT_DIR' && ./install-sah.sh; echo; echo 'Press Enter to close...'; read"
    else
        show_error "No terminal emulator found.\n\nPlease run manually:\n$SCRIPT_DIR/install-sah.sh"
        return 1
    fi
    
    # Brief pause then check installation
    sleep 0.5
    
    # Check if installation succeeded by verifying SAH was installed
    if find ~/.steam ~/.local/share/Steam /mnt -path "*/compatdata/$SCUM_APPID/*/SCUM Admin Helper.exe" 2>/dev/null | head -1 | grep -q .; then
        log "Installation verified successfully"
        show_info "✓ Installation completed!\n\nSCUM Admin Helper is now installed.\n\nYou can launch it from your application menu\nor use the 'Desktop Info' option to learn more."
        
        # Offer to remove intro videos to save space
        offer_video_removal
    else
        log "Installation verification failed"
        show_error "✗ Installation could not be verified.\n\nPlease check the terminal output for errors.\n\nCommon issues:\n• SCUM not launched at least once\n• Missing dependencies\n• Network connection problems"
    fi
}

# Function to create desktop shortcut
create_desktop_shortcut() {
    log "User selected: Create Desktop Shortcut"
    
    # Find SAH in SCUM prefix
    local sah_exe=""
    local wine_prefix=""
    for lib in ~/.steam/steam ~/.local/share/Steam /mnt/*/SteamLibrary /mnt/*/*/SteamLibrary; do
        local test_exe="$lib/steamapps/compatdata/$SCUM_APPID/pfx/drive_c/users/steamuser/AppData/Local/SCUM_Admin_Helper/SCUM Admin Helper.exe"
        if [ -f "$test_exe" ]; then
            sah_exe="$test_exe"
            wine_prefix="$lib/steamapps/compatdata/$SCUM_APPID/pfx"
            break
        fi
    done
    
    if [ -z "$sah_exe" ] || [ ! -f "$sah_exe" ]; then
        show_error "SAH not found in SCUM prefix!\\n\\nPlease run the installation first."
        return 1
    fi
    
    # Ask user which type of shortcut
    local shortcut_type
    shortcut_type=$(zenity --list --title="Desktop Shortcut Type" --width=500 --height=300 \
        --text="Select shortcut type:\\n" \
        --column="Type" --column="Description" \
        "SAH Only" "Launch only SCUM Admin Helper" \
        "SCUM + SAH" "Launch SCUM and SAH together with watchdog" \
        "Cancel" "Go back" \
        --cancel-label="Back" 2>/dev/null)
    
    case "$shortcut_type" in
        "SAH Only")
            local desktop_file="$HOME/.local/share/applications/scum-admin-helper.desktop"
            
            cat > "$desktop_file" << EOF
[Desktop Entry]
Name=SCUM Admin Helper
Comment=SCUM Server Administration Tool
Exec=protontricks-launch --appid $SCUM_APPID "$sah_exe"
Icon=applications-games
Terminal=false
Type=Application
Categories=Game;Utility;
EOF
            
            chmod +x "$desktop_file"
            log "Created SAH-only desktop shortcut"
            show_info "✓ Desktop shortcut created!\\n\\nSCUM Admin Helper\\n\\nFind it in your application menu or:\\n$desktop_file"
            ;;
            
        "SCUM + SAH")
            # Create launcher script
            local launcher_script="$HOME/.local/bin/launch-scum-with-sah.sh"
            mkdir -p "$HOME/.local/bin"
            
            # Write launcher script with embedded path to sah-env.sh
            cat > "$launcher_script" << EOFSCRIPT
#!/bin/bash
# Launch SCUM and SAH together with watchdog
# This script starts SCUM, waits for it to initialize, then launches SAH
# The watchdog monitors SCUM and offers to close SAH when SCUM exits

SCUM_APPID=513710
SAH_PREFIX=""
SAH_EXE=""
SAH_ENV_PATH="$SCRIPT_DIR/sah-env.sh"

echo "========================================"
echo "SCUM + Admin Helper Launcher with Watchdog"
echo "========================================"
echo

# Find SAH
echo "Searching for SCUM Admin Helper..."
for lib in ~/.steam/steam ~/.local/share/Steam /mnt/*/SteamLibrary /mnt/*/*/SteamLibrary; do
    test_exe="\\\$lib/steamapps/compatdata/\\\$SCUM_APPID/pfx/drive_c/users/steamuser/AppData/Local/SCUM_Admin_Helper/SCUM Admin Helper.exe"
    if [ -f "\\\$test_exe" ]; then
        SAH_EXE="\\\$test_exe"
        SAH_PREFIX="\\\$lib/steamapps/compatdata/\\\$SCUM_APPID/pfx"
        echo "✓ Found SAH at: \\\$SAH_EXE"
        break
    fi
done

# Verify SAH was found
if [ -z "\\\$SAH_EXE" ]; then
    echo "✗ ERROR: SCUM Admin Helper not found"
    echo "Please run installation first: ./scripts/install-sah.sh"
    exit 1
fi

echo

# Check if SCUM is already running
echo "Checking if SCUM is running..."
if pgrep -f "SCUM.exe" > /dev/null 2>&1; then
    echo "✓ SCUM is already running"
else
    # Launch SCUM via Steam
    echo "Launching SCUM via Steam..."
    steam steam://rungameid/\\\$SCUM_APPID > /tmp/scum-launcher.log 2>&1 &
    
    # Wait for SCUM process to appear (up to 30 seconds)
    echo "Waiting for SCUM to start..."
    SCUM_WAIT=0
    while ! pgrep -f "SCUM.exe" > /dev/null 2>&1 && [ \\\$SCUM_WAIT -lt 30 ]; do
        sleep 1
        SCUM_WAIT=\\\$((SCUM_WAIT + 1))
    done
    
    if ! pgrep -f "SCUM.exe" > /dev/null 2>&1; then
        echo "✗ ERROR: SCUM failed to start within 30 seconds"
        echo "Check /tmp/scum-launcher.log for details"
        exit 1
    fi
    echo "✓ SCUM process detected"
fi

# CRITICAL: Give SCUM's Wine prefix adequate time to fully initialize
# The Wine environment needs to set up the prefix, initialize graphics, load assets, etc.
# Too short a delay will cause SAH to fail silently
echo
echo "Initializing SCUM Wine environment..."
echo "This may take 15-30 seconds..."
for i in {15..1}; do
    echo -n "."
    sleep 1
done
echo
echo "✓ Ready to launch SAH"
echo

# Load environment settings
if [ -f "\\\$SAH_ENV_PATH" ]; then
    echo "Loading environment settings..."
    source "\\\$SAH_ENV_PATH"
fi

# Launch SAH
echo "Launching SCUM Admin Helper..."
protontricks-launch --appid \\\$SCUM_APPID "\\\$SAH_EXE" > /tmp/sah-launch.log 2>&1 &
SAH_PID=\\\$!
echo "Launched with PID: \\\$SAH_PID"
echo

# Wait for SAH process to appear (up to 10 seconds)
echo "Waiting for SAH to start..."
SAH_WAIT=0
while ! pgrep -f "SCUM Admin Helper.exe" > /dev/null 2>&1 && [ \\\$SAH_WAIT -lt 10 ]; do
    sleep 1
    SAH_WAIT=\\\$((SAH_WAIT + 1))
done

# Check if SAH started
if pgrep -f "SCUM Admin Helper.exe" > /dev/null 2>&1; then
    echo "✓ SCUM Admin Helper started successfully!"
    echo
else
    echo "✗ Failed to start SCUM Admin Helper"
    if [ -f /tmp/sah-launch.log ] && [ -s /tmp/sah-launch.log ]; then
        echo "Error details:"
        cat /tmp/sah-launch.log
    fi
    exit 1
fi

# Monitor SCUM and offer to close SAH when SCUM exits
echo "Monitoring SCUM process..."
while pgrep -f "SCUM.exe" > /dev/null 2>&1; do
    sleep 5
done

echo
echo "SCUM has closed"
echo

# Check if SAH is still running
if pgrep -f "SCUM Admin Helper.exe" > /dev/null 2>&1; then
    if zenity --question --title="SCUM Admin Helper Watchdog" \\
        --text="<b>SCUM has closed</b>\\n\\nSCUM Admin Helper is still running.\\nThis may cause Steam to show SCUM as 'Running'.\\n\\nClose SCUM Admin Helper now?" \\
        --width=450 --timeout=30 2>/dev/null; then
        echo "Closing SCUM Admin Helper..."
        pkill -f "SCUM Admin Helper.exe"
        sleep 1
        
        if pgrep -f "SCUM Admin Helper.exe" > /dev/null 2>&1; then
            echo "WARNING: SAH may still be running, trying force kill..."
            pkill -9 -f "SCUM Admin Helper.exe"
        else
            echo "✓ SCUM Admin Helper closed successfully"
        fi
    else
        echo "User chose to keep SAH running"
    fi
else
    echo "SAH already closed"
fi
EOFSCRIPT
EOFSCRIPT
            
            chmod +x "$launcher_script"
            
            # Create desktop file
            local desktop_file="$HOME/.local/share/applications/scum-with-sah.desktop"
            
            cat > "$desktop_file" << EOF
[Desktop Entry]
Name=SCUM + Admin Helper
Comment=Launch SCUM and SAH together with watchdog
Exec=$launcher_script
Icon=applications-games
Terminal=false
Type=Application
Categories=Game;Utility;
EOF
            
            chmod +x "$desktop_file"
            log "Created SCUM+SAH desktop shortcut with watchdog"
            show_info "✓ Desktop shortcut created!\\n\\nSCUM + Admin Helper\\n(with automatic watchdog)\\n\\nFind it in your application menu or:\\n$desktop_file\\n\\nLauncher script:\\n$launcher_script"
            ;;
    esac
}

# Function to create desktop launcher for this GUI
create_gui_launcher() {
    log "User selected: GUI Launcher options"

    local desktop_file="$HOME/.local/share/applications/sah-helper-gui.desktop"
    local script_path="$SCRIPT_DIR/sah-helper.sh"
    local action

    mkdir -p "$HOME/.local/share/applications"

    if [ -f "$desktop_file" ]; then
        action=$(zenity --list --title="GUI Launcher" --width=500 --height=280 \
            --text="A launcher already exists. Choose an action:" \
            --column="Action" --column="Description" \
            "Reinstall" "Rewrite launcher entry" \
            "Remove" "Delete launcher from menu" \
            "Cancel" "Do nothing" \
            --cancel-label="Close" 2>/dev/null)
    else
        action=$(zenity --list --title="GUI Launcher" --width=500 --height=240 \
            --text="Install the SCUM Admin Helper GUI launcher to your application menu." \
            --column="Action" --column="Description" \
            "Install" "Add launcher entry" \
            "Cancel" "Do nothing" \
            --cancel-label="Close" 2>/dev/null)
    fi

    case "$action" in
        "Install"|"Reinstall")
            # Ensure the GUI script is executable
            if [ ! -x "$script_path" ]; then
                chmod +x "$script_path" 2>/dev/null
            fi

            cat > "$desktop_file" << EOF
[Desktop Entry]
Version=1.0
Name=SCUM Admin Helper Manager
Comment=Launch the SCUM Admin Helper GUI
Exec=$script_path
Path=$(dirname "$script_path")
Icon=applications-system
Terminal=false
Type=Application
Categories=Utility;Game;
EOF

            chmod +x "$desktop_file"

            if command -v update-desktop-database > /dev/null 2>&1; then
                update-desktop-database "$HOME/.local/share/applications" > /dev/null 2>&1
            fi

            show_info "✓ GUI launcher ready!\n\nFind it in your application menu as:\nSCUM Admin Helper Manager\n\nDesktop file:\n$desktop_file"
            log "GUI desktop launcher created/updated at $desktop_file"
            ;;
        "Remove")
            if [ -f "$desktop_file" ]; then
                rm -f "$desktop_file" 2>/dev/null
                if command -v update-desktop-database > /dev/null 2>&1; then
                    update-desktop-database "$HOME/.local/share/applications" > /dev/null 2>&1
                fi
                show_info "Launcher removed from application menu."
                log "GUI desktop launcher removed"
            else
                show_info "No launcher found to remove."
                log "No GUI desktop launcher present"
            fi
            ;;
        *)
            log "GUI launcher action cancelled"
            ;;
    esac
}

# Function to show desktop shortcut info
show_desktop_info() {
    log "User selected: Desktop Shortcut Info"
    
    # Close any lingering loading indicators
    close_working 2>/dev/null
    
    local desktop_file="$HOME/.local/share/applications/scum-admin-helper.desktop"
    
    if [ ! -f "$desktop_file" ]; then
        show_error "Desktop shortcut not found!\n\nPlease run the installation first."
        return 1
    fi
    
    # Find the launch script path from desktop file
    local launch_script
    launch_script=$(grep "^Exec=" "$desktop_file" | cut -d'=' -f2)
    
    zenity --info --title="SCUM Admin Helper - Desktop Shortcut" --width=600 --text="<b>Desktop Shortcut Installed</b>

✓ Application menu: Search for 'SCUM Admin Helper'
✓ Launch script: $launch_script

<b>Usage:</b>
1. Launch SAH from your application menu or run the script directly
2. Launch SCUM from Steam normally
3. Close SAH window manually when done, or run:
   <tt>pkill -f 'SCUM Admin Helper.exe'</tt>

<b>Known Behavior:</b>
SAH uses SCUM's Proton prefix (App ID 513710). When SAH is running,
Steam may show SCUM as 'running' due to shared prefix activity.
This is expected and won't affect gameplay. Close SAH before SCUM
to avoid this, or ignore Steam's status indicator." 2>/dev/null
    
    log "Desktop shortcut info displayed"
}

# Function to test SAH launch
test_sah_launch() {
    log "User selected: Test Launch"
    
    # Find SAH in SCUM prefix
    local sah_exe=""
    local wine_prefix=""
    for lib in ~/.steam/steam ~/.local/share/Steam /mnt/*/SteamLibrary /mnt/*/*/SteamLibrary; do
        local test_exe="$lib/steamapps/compatdata/$SCUM_APPID/pfx/drive_c/users/steamuser/AppData/Local/SCUM_Admin_Helper/SCUM Admin Helper.exe"
        if [ -f "$test_exe" ]; then
            sah_exe="$test_exe"
            wine_prefix="$lib/steamapps/compatdata/$SCUM_APPID/pfx"
            break
        fi
    done
    
    if [ -z "$sah_exe" ] || [ ! -f "$sah_exe" ]; then
        log "ERROR: SAH not found in SCUM prefix"
        show_error "SAH not found in SCUM prefix!\n\nPlease run the installation first."
        return 1
    fi
    
    if ask_question "This will launch SCUM Admin Helper.\n\nYou'll need to close it manually.\n\nContinue?"; then
        log "Launching SCUM Admin Helper..."
        log "Using WINEPREFIX: $wine_prefix"
        show_working "Launching" "Starting SCUM Admin Helper..."
        
        # Launch SAH with Proton (Steam's Wine)
        source "$SCRIPT_DIR/sah-env.sh"
        protontricks-launch --appid $SCUM_APPID "$sah_exe" > /tmp/sah-launch.log 2>&1 &
        sleep 5
        
        if pgrep -f "SCUM Admin Helper.exe" > /dev/null 2>&1; then
            close_working
            log "SAH launched successfully (PID: $(pgrep -f 'SCUM Admin Helper.exe'))"
            show_info "✓ SCUM Admin Helper launched successfully!\n\nClose it when you're done testing."
        else
            close_working
            log "ERROR: SAH failed to launch"
            if [ -f /tmp/sah-launch.log ] && [ -s /tmp/sah-launch.log ]; then
                show_error "✗ Failed to launch SCUM Admin Helper.\n\nError details saved to:\n/tmp/sah-launch.log\n\nCommon causes:\n• .NET Framework not installed\n• Proton prefix issues\n• SAH not installed correctly"
            else
                show_error "✗ Failed to launch SCUM Admin Helper.\n\nThe process started but SAH didn't run.\n\nTry running manually with Wine."
            fi
        fi
    fi
}

# Function to manually control SAH
manual_control() {
    log "User selected: Manual Control"
    
    # Close any lingering loading indicators
    close_working 2>/dev/null
    
    local choice
    choice=$(zenity --list --title="Manual Control" --width=550 --height=350 \
        --text="Select an action:" \
        --column="Action" --column="Description" \
        "Launch SAH" "Start SCUM Admin Helper" \
        "Stop SAH" "Close SCUM Admin Helper" \
        "Status" "Check running processes" \
        "Back" "Return to main menu" \
        --cancel-label="Back" 2>/dev/null)
    
    case "$choice" in
        "Launch SAH")
            log "Manual Control: Launch SAH"
            # Find SAH in SCUM prefix
            local sah_exe=""
            local wine_prefix=""
            for lib in ~/.steam/steam ~/.local/share/Steam /mnt/*/SteamLibrary /mnt/*/*/SteamLibrary; do
                local test_exe="$lib/steamapps/compatdata/$SCUM_APPID/pfx/drive_c/users/steamuser/AppData/Local/SCUM_Admin_Helper/SCUM Admin Helper.exe"
                if [ -f "$test_exe" ]; then
                    sah_exe="$test_exe"
                    wine_prefix="$lib/steamapps/compatdata/$SCUM_APPID/pfx"
                    break
                fi
            done
            
            if [ -n "$sah_exe" ] && [ -f "$sah_exe" ]; then
                log "Found SAH at: $sah_exe"
                log "Using WINEPREFIX: $wine_prefix"
                show_working "Starting" "Launching SCUM Admin Helper..."
                source "$SCRIPT_DIR/sah-env.sh"
                protontricks-launch --appid $SCUM_APPID "$sah_exe" > /tmp/sah-manual-launch.log 2>&1 &
                sleep 5
                
                if pgrep -f "SCUM Admin Helper.exe" > /dev/null 2>&1; then
                    close_working
                    log "SAH started successfully"
                    show_info "✓ SCUM Admin Helper started successfully"
                else
                    close_working
                    log "ERROR: Failed to start SAH"
                    if [ -f /tmp/sah-manual-launch.log ] && [ -s /tmp/sah-manual-launch.log ]; then
                        show_error "✗ Failed to start SCUM Admin Helper\n\nCheck error log:\n/tmp/sah-manual-launch.log"
                    else
                        show_error "✗ Failed to start SCUM Admin Helper\n\nNo error details available.\nTry running manually from terminal."
                    fi
                fi
            else
                log "ERROR: SAH not found in SCUM prefix"
                show_error "✗ SAH not found in SCUM prefix\n\nPlease run the installation first."
            fi
            ;;
        "Stop SAH")
            log "Manual Control: Stop SAH"
            # Check if SAH is running first
            if ! pgrep -f "SCUM Admin Helper.exe" > /dev/null 2>&1; then
                log "SAH is not running"
                show_info "SCUM Admin Helper is not currently running."
            else
                show_working "Stopping" "Closing SCUM Admin Helper..."
                # Use pkill directly - simpler and more reliable
                pkill -f "SCUM Admin Helper.exe" 2>/dev/null
                sleep 1
                
                # Verify it stopped
                if pgrep -f "SCUM Admin Helper.exe" > /dev/null 2>&1; then
                    close_working
                    log "WARNING: SAH may still be running"
                    show_error "⚠ SCUM Admin Helper may still be running.\n\nTry force kill:\npkill -9 -f 'SCUM Admin Helper.exe'"
                else
                    close_working
                    log "SAH stopped successfully"
                    show_info "✓ SCUM Admin Helper stopped successfully"
                fi
            fi
            ;;
        "Status")
            log "Manual Control: Status check"
            local status
            status=$(check_installation_status 0)
            zenity --info --title="Status" --text="$status" --width=400 --no-wrap 2>/dev/null
            ;;
    esac
}

# Function to launch SCUM and SAH together
launch_scum_and_sah() {
    log "User selected: Launch SCUM + SAH"
    
    # Check if already running
    local scum_running=0
    local sah_running=0
    
    if pgrep -f "SCUM.exe" > /dev/null 2>&1; then
        scum_running=1
    fi
    
    if pgrep -f "SCUM Admin Helper.exe" > /dev/null 2>&1; then
        sah_running=1
    fi
    
    if [ $scum_running -eq 1 ] && [ $sah_running -eq 1 ]; then
        show_info "✓ Both SCUM and SAH are already running!"
        return 0
    fi
    
    # Launch SCUM if not running
    if [ $scum_running -eq 0 ]; then
        log "Launching SCUM via Steam"
        show_working "Launching" "Starting SCUM via Steam..."
        
        # Launch SCUM via Steam
        steam steam://rungameid/$SCUM_APPID > /tmp/scum-launch.log 2>&1 &
        SCUM_LAUNCH_PID=$!
        
        # Wait for SCUM process to appear (up to 30 seconds)
        local wait_count=0
        while [ $wait_count -lt 30 ]; do
            if pgrep -f "SCUM.exe" > /dev/null 2>&1; then
                log "SCUM process detected, waiting for full initialization..."
                break
            fi
            sleep 1
            ((wait_count++))
        done
        
        if [ $wait_count -ge 30 ]; then
            close_working
            log "ERROR: SCUM failed to start within 30 seconds"
            show_error "✗ SCUM failed to start within 30 seconds.\n\nPlease check:\n• Steam is running\n• SCUM is installed\n• You have permissions to run it"
            return 1
        fi
        
        # CRITICAL: Give SCUM's Wine prefix ample time to fully initialize
        # This is essential for SAH to launch successfully
        # The Wine environment needs to:
        # - Initialize the prefix
        # - Mount file systems
        # - Initialize graphics/audio
        # - Load game assets
        log "Initializing SCUM Wine environment (critical step)..."
        show_working "Initializing" "Setting up SCUM Wine environment...\n\nThis may take 15-30 seconds"
        
        # Use adaptive waiting - keep checking if SCUM is responsive
        local init_count=0
        local max_init_wait=30
        while [ $init_count -lt $max_init_wait ]; do
            if [ $init_count -ge 15 ]; then
                # After 15 seconds, we're good to try SAH
                log "SCUM initialization window complete, SAH should launch now"
                break
            fi
            sleep 1
            ((init_count++))
        done
        
        close_working
        log "SCUM ready, proceeding to launch SAH"
    else
        log "SCUM is already running"
    fi
    
    # Launch SAH if not running
    if [ $sah_running -eq 0 ]; then
        log "Launching SAH"
        show_working "Launching" "Starting SCUM Admin Helper..."
        
        # Find SAH in SCUM prefix
        local sah_exe=""
        local wine_prefix=""
        for lib in ~/.steam/steam ~/.local/share/Steam /mnt/*/SteamLibrary /mnt/*/*/SteamLibrary; do
            local test_exe="$lib/steamapps/compatdata/$SCUM_APPID/pfx/drive_c/users/steamuser/AppData/Local/SCUM_Admin_Helper/SCUM Admin Helper.exe"
            if [ -f "$test_exe" ]; then
                sah_exe="$test_exe"
                wine_prefix="$lib/steamapps/compatdata/$SCUM_APPID/pfx"
                break
            fi
        done
        
        if [ -n "$sah_exe" ] && [ -f "$sah_exe" ]; then
            log "Found SAH at: $sah_exe"
            log "Using WINEPREFIX: $wine_prefix"
            
            # Source environment settings
            log "Loading SAH environment settings..."
            if ! source "$SCRIPT_DIR/sah-env.sh" 2>/tmp/sah-env-error.log; then
                log "WARNING: Error loading sah-env.sh, continuing anyway"
            fi
            
            # Launch SAH with Proton (Steam's Wine)
            log "Executing: protontricks-launch --appid $SCUM_APPID \"$sah_exe\""
            show_working "Launching" "Starting SCUM Admin Helper..."
            
            protontricks-launch --appid $SCUM_APPID "$sah_exe" > /tmp/sah-launch.log 2>&1 &
            SAH_LAUNCH_PID=$!
            log "Launched SAH with PID: $SAH_LAUNCH_PID"
            
            # Wait up to 10 seconds for SAH process to appear
            local sah_wait_count=0
            local sah_found=0
            while [ $sah_wait_count -lt 10 ]; do
                if pgrep -f "SCUM Admin Helper.exe" > /dev/null 2>&1; then
                    log "SAH process detected!"
                    sah_found=1
                    break
                fi
                log "Waiting for SAH... ($sah_wait_count/10 seconds)"
                sleep 1
                ((sah_wait_count++))
            done
            
            if [ $sah_found -eq 1 ]; then
                close_working
                log "SAH started successfully"
                show_info "✓ SCUM and SAH launched successfully!\n\nSCUM Admin Helper is now running.\n\nWatchdog will monitor SCUM and offer to close SAH when SCUM exits."
                
                # Start watchdog in background
                start_watchdog &
                return 0
            else
                close_working
                log "ERROR: SAH process not detected after launch attempt"
                
                # Check if protontricks-launch had an error
                if [ -f /tmp/sah-launch.log ] && [ -s /tmp/sah-launch.log ]; then
                    log "Launch log contents:"
                    log "$(cat /tmp/sah-launch.log)"
                    show_error "✗ Failed to start SCUM Admin Helper\n\nLaunch failed - check /tmp/sah-launch.log\n\nCommon causes:\n• .NET Framework not installed\n• Proton/Wine initialization incomplete\n• SAH exe missing or corrupted\n\nTry: ./scripts/reinstall-dotnet.sh"
                else
                    # No error log, which is strange
                    log "No error log generated - may be a process detection issue"
                    
                    # Try one more check with longer timeout
                    log "Attempting extended wait (5 more seconds)..."
                    local extended_wait=5
                    while [ $extended_wait -gt 0 ]; do
                        if pgrep -f "SCUM Admin Helper.exe" > /dev/null 2>&1; then
                            log "SAH found on extended wait!"
                            show_info "✓ SCUM and SAH launched successfully!\n\nSCUM Admin Helper is now running.\n\nWatchdog will monitor SCUM and offer to close SAH when SCUM exits."
                            start_watchdog &
                            return 0
                        fi
                        sleep 1
                        ((extended_wait--))
                    done
                    
                    show_error "✗ Failed to start SCUM Admin Helper\n\nNo output or error details.\n\nTroubleshooting steps:\n1. Verify .NET is installed: ./scripts/reinstall-dotnet.sh\n2. Test manual launch: protontricks-launch --appid 513710 [exe path]\n3. Check: ~/.steam/steam/steamapps/compatdata/513710/pfx/ exists"
                fi
                return 1
            fi
        else
            close_working
            log "ERROR: SAH not found in SCUM prefix"
            show_error "✗ SAH not found in SCUM prefix\n\nPlease run the installation first."
            return 1
        fi
    else
        log "SAH is already running"
        show_info "✓ SCUM and SAH are both running!\n\nWatchdog will monitor SCUM and offer to close SAH when SCUM exits."
        
        # Start watchdog in background
        start_watchdog &
    fi
}

# Function to monitor SCUM and offer to close SAH when SCUM exits
start_watchdog() {
    log "Starting SCUM/SAH watchdog"
    
    # Wait for SCUM to be running
    while ! pgrep -f "SCUM.exe" > /dev/null 2>&1; do
        sleep 2
    done
    
    log "Watchdog: SCUM is running, monitoring..."
    
    # Monitor SCUM process
    while pgrep -f "SCUM.exe" > /dev/null 2>&1; do
        sleep 5
    done
    
    log "Watchdog: SCUM has exited"
    
    # Check if SAH is still running
    if pgrep -f "SCUM Admin Helper.exe" > /dev/null 2>&1; then
        log "Watchdog: SAH still running, prompting user"
        
        # Prompt user to close SAH
        if zenity --question --title="SCUM Admin Helper Watchdog" \
            --text="<b>SCUM has closed</b>\n\nSCUM Admin Helper is still running.\nThis may cause Steam to show SCUM as 'Running'.\n\nClose SCUM Admin Helper now?" \
            --width=400 --timeout=30 --ok-label="Close SAH" --cancel-label="Keep Running" 2>/dev/null; then
            
            log "Watchdog: User chose to close SAH"
            pkill -f "SCUM Admin Helper.exe" 2>/dev/null
            sleep 1
            
            if pgrep -f "SCUM Admin Helper.exe" > /dev/null 2>&1; then
                zenity --warning --title="SCUM Admin Helper Watchdog" \
                    --text="⚠ Failed to close SAH automatically.\n\nPlease close it manually or run:\npkill -9 -f 'SCUM Admin Helper.exe'" \
                    --width=400 2>/dev/null
            else
                log "Watchdog: SAH closed successfully"
                zenity --info --title="SCUM Admin Helper Watchdog" \
                    --text="✓ SCUM Admin Helper closed successfully" \
                    --timeout=5 --width=300 2>/dev/null
            fi
        else
            log "Watchdog: User chose to keep SAH running or timed out"
        fi
    else
        log "Watchdog: SAH already closed"
    fi
    
    log "Watchdog: Exiting"
}

# Function to view logs
view_logs() {
    log "User selected: View Logs"
    
    # Close any lingering loading indicators
    close_working 2>/dev/null
    
    local log_files=()
    
    # Check for log files
    [ -f "/tmp/sah-install-dotnet40.log" ] && log_files+=("FALSE" "/tmp/sah-install-dotnet40.log" ".NET 4.0 Installation")
    [ -f "/tmp/sah-install-dotnet48.log" ] && log_files+=("FALSE" "/tmp/sah-install-dotnet48.log" ".NET 4.8 Installation")
    [ -f "/tmp/sah-install-vcrun.log" ] && log_files+=("FALSE" "/tmp/sah-install-vcrun.log" "VC++ Runtime Installation")
    [ -f "/tmp/sah-unzip-error.log" ] && log_files+=("FALSE" "/tmp/sah-unzip-error.log" "Extraction Errors")
    
    if [ ${#log_files[@]} -eq 0 ]; then
        show_info "No log files found.\n\nLogs are created during installation."
        return
    fi
    
    local selected
    selected=$(zenity --list --title="View Logs" --width=500 --height=300 \
        --checklist --column="View" --column="File" --column="Description" \
        "${log_files[@]}" \
        --cancel-label="Close" 2>/dev/null)
    
    if [ -n "$selected" ]; then
        # Open selected logs in default text editor
        for log in $(echo "$selected" | tr '|' ' '); do
            if command -v xdg-open &> /dev/null; then
                xdg-open "$log" &
            elif command -v gedit &> /dev/null; then
                gedit "$log" &
            elif command -v kate &> /dev/null; then
                kate "$log" &
            else
                zenity --text-info --title="Log: $log" --filename="$log" --width=800 --height=600 2>/dev/null
            fi
        done
    fi
}

# Function to manage backups
manage_backups() {
    log "User selected: Backup Management"
    
    # Close any lingering loading indicators
    close_working 2>/dev/null
    
    # Find SCUM prefix first
    local compat_path=""
    for lib in ~/.steam/steam ~/.local/share/Steam /mnt/*/SteamLibrary /mnt/*/*/SteamLibrary; do
        local test_path="$lib/steamapps/compatdata/$SCUM_APPID"
        if [ -d "$test_path" ]; then
            compat_path="$test_path"
            break
        fi
    done
    
    if [ -z "$compat_path" ]; then
        show_error "SCUM Proton prefix not found.\n\nSCUM must be installed and launched at least once."
        return 1
    fi
    
    local choice
    choice=$(zenity --list --title="Backup Management" --width=550 --height=400 \
        --text="Manage SCUM Admin Helper backups:\n\nSCUM Prefix: $compat_path" \
        --column="Action" --column="Description" \
        "Create Backup" "Create new backup" \
        "List Backups" "View existing backups" \
        "Restore Backup" "Restore from backup" \
        "Delete Backups" "Remove old backups" \
        "Back" "Return to main menu" \
        --cancel-label="Back" 2>/dev/null)
    
    case "$choice" in
        "Create Backup")
            create_backup "$compat_path"
            ;;
        "List Backups")
            list_backups
            ;;
        "Restore Backup")
            restore_backup "$compat_path"
            ;;
        "Delete Backups")
            delete_backups
            ;;
    esac
}

# Function to create a backup
create_backup() {
    local compat_path="$1"
    
    local backup_type
    backup_type=$(zenity --list --title="Backup Type" --width=550 --height=260 \
        --text="Select backup type:" \
        --column="Type" --column="Size" --column="Description" \
        "SAH Only" "~100MB" "SAH app + settings + .NET info" \
        "Full Prefix" "~2-5GB" "Everything (SAH + .NET + all prefix data)" \
        --cancel-label="Back" 2>/dev/null)
    
    if [ -z "$backup_type" ]; then
        return 0
    fi
    
    local backup_dir
    backup_dir="$HOME/sah-backups/backup-$(date +%Y%m%d-%H%M%S)"
    
    case "$backup_type" in
        "SAH Only")
            log "Creating SAH-only backup"
            local sah_path="$compat_path/pfx/drive_c/users/steamuser/AppData/Local/SCUM_Admin_Helper"
            
            if [ ! -d "$sah_path" ]; then
                show_error "SAH not found at:\n$sah_path\n\nNothing to backup."
                return 1
            fi
            
            show_working "Backup" "Creating SAH backup..."
            
            mkdir -p "$backup_dir"
            cp -r "$sah_path" "$backup_dir/SCUM_Admin_Helper" 2>/dev/null
            
            # Backup winetricks log if exists
            if [ -f "$compat_path/pfx/winetricks.log" ]; then
                cp "$compat_path/pfx/winetricks.log" "$backup_dir/" 2>/dev/null
            fi
            
            # Save metadata
            cat > "$backup_dir/backup-info.txt" << EOF
Backup Date: $(date)
Backup Type: SAH Only
SCUM Prefix: $compat_path
SAH Path: $sah_path

To restore:
1. Use GUI: Backup Management > Restore Backup
2. Or manually: Copy SCUM_Admin_Helper folder back to:
   $sah_path
EOF
            
            close_working
            
            local size
            size=$(du -sh "$backup_dir" 2>/dev/null | cut -f1)
            show_info "✓ SAH backup created!\n\nLocation: $backup_dir\nSize: $size\n\nBacked up:\n• SAH application\n• SAH settings\n• Winetricks log"
            log "Backup created: $backup_dir ($size)"
            ;;
            
        "Full Prefix")
            log "Creating full prefix backup"
            
            # Calculate and show size first
            show_working "Calculating" "Calculating prefix size..."
            local size
            size=$(du -sh "$compat_path" 2>/dev/null | cut -f1)
            close_working
            
            if ! ask_question "This will backup the entire SCUM prefix.\n\nSize: $size\nTime: Several minutes\n\nContinue?"; then
                return 0
            fi
            
            show_working "Backup" "Copying prefix (this may take several minutes)..."
            
            mkdir -p "$backup_dir"
            cp -r "$compat_path" "$backup_dir/compatdata-$SCUM_APPID" 2>/dev/null
            
            # Save metadata
            cat > "$backup_dir/backup-info.txt" << EOF
Backup Date: $(date)
Backup Type: Full SCUM Prefix
SCUM Prefix: $compat_path
Backup Size: $size

To restore:
1. Use GUI: Backup Management > Restore Backup
2. Or manually:
   a. Delete current prefix: rm -rf $compat_path
   b. Restore backup: cp -r $backup_dir/compatdata-$SCUM_APPID $compat_path
EOF
            
            close_working
            
            local backup_size
            backup_size=$(du -sh "$backup_dir" 2>/dev/null | cut -f1)
            show_info "✓ Full prefix backup created!\n\nLocation: $backup_dir\nSize: $backup_size\n\nThis backup includes everything:\n• SAH installation\n• .NET Framework\n• All prefix modifications"
            log "Full backup created: $backup_dir ($backup_size)"
            ;;
    esac
}

# Function to list backups
list_backups() {
    log "Listing backups"
    
    if [ ! -d "$HOME/sah-backups" ]; then
        show_info "No backups found.\n\nBackups are stored in:\n$HOME/sah-backups"
        return 0
    fi
    
    show_working "Searching" "Finding backups..."
    
    local backup_list=()
    local backup_count=0
    
    for backup in "$HOME/sah-backups"/backup-*; do
        if [ -d "$backup" ] && [ -f "$backup/backup-info.txt" ]; then
            local backup_name
            backup_name=$(basename "$backup")
            local backup_size
            backup_size=$(du -sh "$backup" 2>/dev/null | cut -f1)
            local backup_type
            backup_type=$(grep "^Backup Type:" "$backup/backup-info.txt" 2>/dev/null | cut -d':' -f2- | xargs)
            local backup_date
            backup_date=$(grep "^Backup Date:" "$backup/backup-info.txt" 2>/dev/null | cut -d':' -f2- | xargs)
            
            backup_list+=("FALSE" "$backup_name" "$backup_type" "$backup_size" "$backup_date")
            ((backup_count++))
        fi
    done
    
    close_working
    
    if [ $backup_count -eq 0 ]; then
        show_info "No backups found.\n\nCreate a backup using:\nBackup Management > Create Backup"
        return 0
    fi
    
    local selected
    selected=$(zenity --list --title="Available Backups" --width=700 --height=400 \
        --text="Found $backup_count backup(s):\n" \
        --checklist --column="View" --column="Backup Name" --column="Type" --column="Size" --column="Date" \
        "${backup_list[@]}" \
        --cancel-label="Back" 2>/dev/null)
    
    if [ -n "$selected" ]; then
        # Show details for selected backup
        local backup_name
        backup_name=$(echo "$selected" | cut -d'|' -f1)
        local backup_path="$HOME/sah-backups/$backup_name"
        
        if [ -f "$backup_path/backup-info.txt" ]; then
            zenity --text-info --title="Backup Details: $backup_name" \
                --width=600 --height=400 --filename="$backup_path/backup-info.txt" 2>/dev/null
        fi
    fi
}

# Function to restore from backup
restore_backup() {
    local compat_path="$1"
    
    if [ ! -d "$HOME/sah-backups" ]; then
        show_error "No backups found.\n\nCreate a backup first:\nBackup Management > Create Backup"
        return 1
    fi
    
    log "Restore backup selected"
    show_working "Searching" "Finding backups..."
    
    local backup_list=()
    local backup_count=0
    
    for backup in "$HOME/sah-backups"/backup-*; do
        if [ -d "$backup" ] && [ -f "$backup/backup-info.txt" ]; then
            local backup_name
            backup_name=$(basename "$backup")
            local backup_type
            backup_type=$(grep "^Backup Type:" "$backup/backup-info.txt" 2>/dev/null | cut -d':' -f2- | xargs)
            local backup_date
            backup_date=$(grep "^Backup Date:" "$backup/backup-info.txt" 2>/dev/null | cut -d':' -f2- | xargs)
            
            backup_list+=("$backup_name" "$backup_type - $backup_date")
            ((backup_count++))
        fi
    done
    
    close_working
    
    if [ $backup_count -eq 0 ]; then
        show_error "No backups found.\n\nCreate a backup first:\nBackup Management > Create Backup"
        return 1
    fi
    
    local selected
    selected=$(zenity --list --title="Restore Backup" --width=600 --height=400 \
        --text="Select backup to restore:\n⚠ This will overwrite current installation!" \
        --column="Backup Name" --column="Details" \
        "${backup_list[@]}" \
        --cancel-label="Back" 2>/dev/null)
    
    if [ -z "$selected" ]; then
        return 0
    fi
    
    local backup_path="$HOME/sah-backups/$selected"
    local backup_type
    backup_type=$(grep "^Backup Type:" "$backup_path/backup-info.txt" 2>/dev/null | cut -d':' -f2- | xargs)
    
    # Confirm restore
    if ! ask_question "⚠ WARNING ⚠\n\nThis will restore:\n$selected\n\nType: $backup_type\n\nCurrent installation will be overwritten!\n\nContinue?"; then
        log "Restore cancelled by user"
        return 0
    fi
    
    log "Restoring backup: $selected"
    
    case "$backup_type" in
        *"SAH Only"*)
            show_working "Restoring" "Restoring SAH files..."
            
            local sah_path="$compat_path/pfx/drive_c/users/steamuser/AppData/Local/SCUM_Admin_Helper"
            
            # Remove current SAH
            if [ -d "$sah_path" ]; then
                rm -rf "$sah_path" 2>/dev/null
            fi
            
            # Restore from backup
            if [ -d "$backup_path/SCUM_Admin_Helper" ]; then
                cp -r "$backup_path/SCUM_Admin_Helper" "$sah_path" 2>/dev/null
                
                # Restore winetricks log if exists
                if [ -f "$backup_path/winetricks.log" ]; then
                    cp "$backup_path/winetricks.log" "$compat_path/pfx/" 2>/dev/null
                fi
                
                close_working
                show_info "✓ SAH restored successfully!\n\nFrom backup: $selected\n\nYou can now launch SAH from the application menu."
                log "SAH restored from: $backup_path"
            else
                close_working
                show_error "✗ Backup corrupted or invalid.\n\nSCUM_Admin_Helper folder not found in backup."
                log "ERROR: Invalid backup structure"
            fi
            ;;
            
        *"Full"*)
            show_working "Restoring" "Restoring full prefix (this may take several minutes)..."
            
            # Remove current prefix
            if [ -d "$compat_path" ]; then
                rm -rf "$compat_path" 2>/dev/null
            fi
            
            # Restore from backup
            if [ -d "$backup_path/compatdata-$SCUM_APPID" ]; then
                cp -r "$backup_path/compatdata-$SCUM_APPID" "$compat_path" 2>/dev/null
                
                close_working
                show_info "✓ Full prefix restored successfully!\n\nFrom backup: $selected\n\nEverything has been restored:\n• SAH installation\n• .NET Framework\n• All prefix modifications"
                log "Full prefix restored from: $backup_path"
            else
                close_working
                show_error "✗ Backup corrupted or invalid.\n\ncompatdata folder not found in backup."
                log "ERROR: Invalid backup structure"
            fi
            ;;
    esac
}

# Function to delete backups
delete_backups() {
    log "Delete backups selected"
    
    if [ ! -d "$HOME/sah-backups" ]; then
        show_info "No backups found."
        return 0
    fi
    
    show_working "Searching" "Finding backups..."
    
    local backup_list=()
    local backup_count=0
    
    for backup in "$HOME/sah-backups"/backup-*; do
        if [ -d "$backup" ] && [ -f "$backup/backup-info.txt" ]; then
            local backup_name
            backup_name=$(basename "$backup")
            local backup_size
            backup_size=$(du -sh "$backup" 2>/dev/null | cut -f1)
            local backup_type
            backup_type=$(grep "^Backup Type:" "$backup/backup-info.txt" 2>/dev/null | cut -d':' -f2- | xargs)
            
            backup_list+=("FALSE" "$backup_name" "$backup_type" "$backup_size")
            ((backup_count++))
        fi
    done
    
    close_working
    
    if [ $backup_count -eq 0 ]; then
        show_info "No backups found."
        return 0
    fi
    
    local selected
    selected=$(zenity --list --title="Delete Backups" --width=600 --height=400 \
        --text="Select backups to delete:\n⚠ This action cannot be undone!" \
        --checklist --column="Delete" --column="Backup Name" --column="Type" --column="Size" \
        "${backup_list[@]}" \
        --cancel-label="Back" 2>/dev/null)
    
    if [ -z "$selected" ]; then
        return 0
    fi
    
    # Confirm deletion
    local delete_count
    delete_count=$(echo "$selected" | tr '|' '\n' | wc -l)
    if ! ask_question "⚠ WARNING ⚠\n\nDelete $delete_count backup(s)?\n\nThis action CANNOT be undone!\n\nContinue?"; then
        log "Deletion cancelled by user"
        return 0
    fi
    
    show_working "Deleting" "Removing backups..."
    
    local deleted=0
    for backup_name in $(echo "$selected" | tr '|' ' '); do
        local backup_path="$HOME/sah-backups/$backup_name"
        if [ -d "$backup_path" ]; then
            rm -rf "$backup_path" 2>/dev/null
            log "Deleted backup: $backup_name"
            ((deleted++))
        fi
    done
    
    close_working
    
    show_info "✓ Deleted $deleted backup(s)\n\nRemaining backups can be viewed via:\nBackup Management > List Backups"
    log "Deleted $deleted backups"
}

# Function to offer video removal (called after installation)
offer_video_removal() {
    log "Offering video removal to user"
    
    # Check if SCUM videos exist
    local scum_movies_path=""
    for lib in ~/.steam/steam ~/.local/share/Steam /mnt/*/SteamLibrary /mnt/*/*/SteamLibrary; do
        local test_path="$lib/steamapps/common/SCUM/SCUM/Content/Movies"
        if [ -d "$test_path" ]; then
            scum_movies_path="$test_path"
            break
        fi
    done
    
    if [ -z "$scum_movies_path" ] || [ ! -d "$scum_movies_path" ]; then
        log "SCUM movies folder not found, skipping video removal offer"
        return 0
    fi
    
    # Check if intro videos exist
    local has_videos=false
    if [ -f "$scum_movies_path/Intro_Cinematic.mp4" ] || \
       [ -f "$scum_movies_path/Character_Creation_Cinematic.mp4" ] || \
       [ -f "$scum_movies_path/SCUMsplash.mp4" ]; then
        has_videos=true
    fi
    
    if [ "$has_videos" = false ]; then
        log "SCUM intro videos already removed, skipping offer"
        return 0
    fi
    
    # Offer to remove videos
    if zenity --question --title="Save Disk Space?" --width=500 \
        --text="<b>💡 Tip: Free Up ~940MB</b>

SCUM includes intro cinematics that can be removed to save space:

• Intro Cinematic (~289MB)
• Character Creation Cinematic (~650MB)
• Splash Videos (~1.4MB)

<b>Total space saved: ~940MB</b>

These videos only play once and can be safely removed.

<b>Note:</b> Steam may re-download when verifying files.

Would you like to remove them now?" \
        --ok-label="Remove Videos" --cancel-label="Keep Videos" 2>/dev/null; then
        log "User accepted video removal offer"
        remove_scum_videos
    else
        log "User declined video removal offer"
        show_info "No problem!\n\nYou can remove intro videos later from:\nAdvanced Tools > Remove SCUM Videos"
    fi
}

# Function to remove SCUM intro videos
remove_scum_videos() {
    log "User selected: Remove SCUM Videos"
    
    local video_script="$SCRIPT_DIR/remove-scum-videos.sh"
    
    if [ ! -f "$video_script" ]; then
        show_error "Video removal script not found at:\n$video_script"
        log "ERROR: Script not found: $video_script"
        return 1
    fi
    
    # Show confirmation dialog
    if zenity --question --title="Remove SCUM Intro Videos" --width=450 \
        --text="<b>Remove SCUM Intro Videos</b>

This will delete intro cinematics from SCUM:
• Intro Cinematic (~289MB)
• Character Creation Cinematic (~650MB)  
• Splash Videos (~1.4MB)

<b>Total space saved: ~940MB</b>

The videos will be removed from:
SCUM/SCUM/Content/Movies/

<b>Note:</b> Steam may re-download these when verifying game files.

Remove intro videos?" 2>/dev/null; then
        
        log "Launching video removal script in terminal..."
        
        # Run the script in a terminal
        if command -v gnome-terminal &> /dev/null; then
            gnome-terminal -- bash -c "'$video_script'; echo ''; echo 'Press Enter to close...'; read" 2>/dev/null
        elif command -v konsole &> /dev/null; then
            konsole -e bash -c "'$video_script'; echo ''; echo 'Press Enter to close...'; read" 2>/dev/null
        elif command -v xterm &> /dev/null; then
            xterm -e bash -c "'$video_script'; echo ''; echo 'Press Enter to close...'; read" 2>/dev/null
        else
            # Fallback: run in background and show completion
            show_working "Removing" "Removing SCUM intro videos..."
            bash "$video_script" &> /tmp/scum-video-removal.log
            local result=$?
            close_working
            
            if [ $result -eq 0 ]; then
                show_info "✓ SCUM intro videos removed!\n\nCheck /tmp/scum-video-removal.log for details."
            else
                show_error "✗ Failed to remove videos.\n\nCheck /tmp/scum-video-removal.log for details."
            fi
        fi
        
        log "Executed SCUM video removal script"
    else
        log "User cancelled video removal"
    fi
}

# Function to show troubleshooting guide
show_troubleshooting() {
    log "User selected: Troubleshooting"
    close_working 2>/dev/null
    
    # Show troubleshooting menu with actions
    local choice=$(zenity --list --title="Troubleshooting" --width=650 --height=400 \
        --column="Option" --column="Description" \
        "View Guide" "Show common issues and solutions" \
        "Reinstall .NET" "Fix 'DLL not verified' errors" \
        "View Logs" "Check installation and launch logs" \
        "Test Installation" "Verify SAH components" \
        "Back" "Return to main menu" \
        --cancel-label="Back" 2>/dev/null)
    
    case "$choice" in
        "View Guide")
            zenity --info --title="Troubleshooting Guide" --width=600 --height=500 --text="<b>Common Issues:</b>

<b>1. SAH doesn't launch:</b>
   • Ensure SCUM was run at least once (creates Proton prefix)
   • Check .NET Framework is installed
   • Run: protontricks --version
   • Check desktop shortcut: Desktop Info menu

<b>2. SAH doesn't close:</b>
   • Close manually: pkill -f 'SCUM Admin Helper.exe'
   • Or use Manual Control menu option

<b>3. 'DLL not verified' / .NET Assembly errors:</b>
   • Use 'Reinstall .NET' option in this menu
   • Or run: ./scripts/reinstall-dotnet.sh
   • Fixes corrupted .NET Framework registry entries

<b>4. Steam shows SCUM running when only SAH is open:</b>
   • This is expected behavior - SAH uses SCUM's prefix (App ID 513710)
   • Steam detects Proton/Wine activity and thinks SCUM is running
   • Workaround: Close SAH before launching SCUM, or ignore the indicator
   • Does not affect gameplay or Steam functionality

<b>5. File dialogs don't work:</b>
   • Run: ./scripts/fix-file-dialogs.sh
   • Or manually place files in SAH directory
   • See troubleshooting.md for detailed workarounds

<b>6. Installation fails:</b>
   • Check internet connection
   • Verify disk space available
   • Review log files (View Logs in this menu)
   • Ensure SCUM launched at least once

<b>7. Dependencies missing:</b>
   • protontricks: pip install protontricks
   • curl: Install via system package manager
   • unzip: Install via system package manager

<b>More help:</b>
See docs/troubleshooting.md" 2>/dev/null
            show_troubleshooting
            ;;
        "Reinstall .NET")
            if zenity --question --title="Reinstall .NET Framework" --width=500 \
                --text="This will force-reinstall .NET Framework 4.8 in SCUM's Proton prefix.\n\nThis fixes:\n• 'DLL not verified' errors\n• .NET assembly verification failures\n• Corrupted registry entries\n\nThe process takes 5-10 minutes.\n\nProceed?" \
                --ok-label="Reinstall" --cancel-label="Cancel" 2>/dev/null; then
                
                # Launch terminal with the reinstall script
                if command -v konsole &> /dev/null; then
                    konsole --hold -e "$SCRIPT_DIR/reinstall-dotnet.sh" &
                elif command -v gnome-terminal &> /dev/null; then
                    gnome-terminal -- bash -c "$SCRIPT_DIR/reinstall-dotnet.sh; echo ''; echo 'Press Enter to close...'; read" &
                elif command -v xfce4-terminal &> /dev/null; then
                    xfce4-terminal --hold -e "$SCRIPT_DIR/reinstall-dotnet.sh" &
                else
                    xterm -hold -e "$SCRIPT_DIR/reinstall-dotnet.sh" &
                fi
                
                zenity --info --title="Reinstall Started" --width=400 \
                    --text="The .NET Framework reinstallation has been started in a terminal window.\n\nFollow the on-screen instructions.\n\nYou'll see many 'fixme:' messages - these are normal.\n\nAfter completion, test SAH to verify the fix worked." 2>/dev/null
            fi
            show_troubleshooting
            ;;
        "View Logs")
            show_logs
            show_troubleshooting
            ;;
        "Test Installation")
            test_installation
            show_troubleshooting
            ;;
        "Back"|*)
            return
            ;;
    esac
}

# Advanced tools submenu
advanced_tools() {
    while true; do
        local choice
        choice=$(zenity --list --title="Advanced Tools" \
            --width=550 --height=450 \
            --text="<b>Advanced Configuration & Optimization</b>\n" \
            --column="Tool" --column="Description" \
            "Configure SAH Delays" "Optimize chat delays for Linux" \
            "Fix File Dialogs" "Enable import/export dialogs" \
            "Open SAH Folder" "Access import/export location" \
            "Create Desktop Shortcut" "Add desktop launcher" \
            "Install GUI Launcher" "Add the zenity GUI to application menu" \
            "Remove SCUM Videos" "Skip intro videos (~940MB)" \
            "Back" "Return to main menu" \
            --cancel-label="Back" 2>/dev/null)
        
        case "$choice" in
            "Configure SAH Delays")
                log "Advanced Tools: Configure SAH Delays"
                show_info "Configure SAH Delays\n\nThis will open a terminal to configure chat delay settings.\n\nRecommended for optimal Linux performance."
                if command -v konsole &> /dev/null; then
                    konsole -e "$SCRIPT_DIR/configure-sah-delays.sh" 2>/dev/null
                elif command -v gnome-terminal &> /dev/null; then
                    gnome-terminal -- "$SCRIPT_DIR/configure-sah-delays.sh" 2>/dev/null
                elif command -v xfce4-terminal &> /dev/null; then
                    xfce4-terminal -e "$SCRIPT_DIR/configure-sah-delays.sh" 2>/dev/null
                else
                    xterm -e "$SCRIPT_DIR/configure-sah-delays.sh" 2>/dev/null || \
                    show_error "Could not open terminal.\n\nRun manually: ./scripts/configure-sah-delays.sh"
                fi
                ;;
            "Fix File Dialogs")
                log "Advanced Tools: Fix File Dialogs"
                show_info "Fix File Dialogs\n\nThis will install Windows components to enable import/export dialogs.\n\nMay take 5-10 minutes."
                if command -v konsole &> /dev/null; then
                    konsole -e "$SCRIPT_DIR/fix-file-dialogs.sh" 2>/dev/null
                elif command -v gnome-terminal &> /dev/null; then
                    gnome-terminal -- "$SCRIPT_DIR/fix-file-dialogs.sh" 2>/dev/null
                elif command -v xfce4-terminal &> /dev/null; then
                    xfce4-terminal -e "$SCRIPT_DIR/fix-file-dialogs.sh" 2>/dev/null
                else
                    xterm -e "$SCRIPT_DIR/fix-file-dialogs.sh" 2>/dev/null || \
                    show_error "Could not open terminal.\n\nRun manually: ./scripts/fix-file-dialogs.sh"
                fi
                ;;
            "Open SAH Folder")
                log "Advanced Tools: Open SAH Folder"
                "$SCRIPT_DIR/open-sah-folder.sh" &
                show_info "Opening SAH folder...\n\nThis is where file dialogs save/load files.\n\nUse this location for import/export operations."
                ;;
            "Create Desktop Shortcut")
                create_desktop_shortcut
                ;;
            "Install GUI Launcher")
                create_gui_launcher
                ;;
            "Remove SCUM Videos")
                remove_scum_videos
                ;;
            "Back"|"")
                return
                ;;
        esac
    done
}

# System & maintenance submenu
system_maintenance() {
    while true; do
        # Count backups
        local backup_count=0
        if [ -d "$HOME/sah-backups" ]; then
            backup_count=$(find "$HOME/sah-backups" -maxdepth 1 -type d -name 'backup-*' 2>/dev/null | wc -l)
        fi
        
        local choice
        choice=$(zenity --list --title="System & Maintenance" \
            --width=550 --height=340 \
            --text="<b>Backup, Logs, and Troubleshooting</b>\n\nBackups available: $backup_count" \
            --column="Tool" --column="Description" \
            "Backup Management" "Create/restore SAH backups" \
            "View Logs" "Check error logs" \
            "Troubleshooting" "Common issues & fixes" \
            "Back" "Return to main menu" \
            --cancel-label="Back" 2>/dev/null)
        
        case "$choice" in
            "Backup Management")
                manage_backups
                ;;
            "View Logs")
                show_working "Logs" "Searching for log files..."
                view_logs
                close_working
                ;;
            "Troubleshooting")
                show_troubleshooting
                ;;
            "Back"|"")
                return
                ;;
        esac
    done
}

# Main menu loop
main_menu() {
    while true; do
        # Get current status (quiet mode for main menu) - no progress dialog to avoid zenity conflicts
        check_installation_status 1 > /dev/null
        local is_installed=$?
        
        if [ $is_installed -eq 0 ]; then
            status_summary="✓ Installation Complete"
        else
            status_summary="⚠ Setup Required"
        fi
        
        # Count backups for status
        local backup_count=0
        if [ -d "$HOME/sah-backups" ]; then
            backup_count=$(find "$HOME/sah-backups" -maxdepth 1 -type d -name 'backup-*' 2>/dev/null | wc -l)
        fi
        local backup_status=""
        if [ "$backup_count" -gt 0 ]; then
            backup_status="  |  $backup_count Backup(s)"
        fi
        
        local choice
        choice=$(zenity --list --title="SCUM Admin Helper Manager" \
            --width=550 --height=450 \
            --text="<b>Status:</b> $status_summary$backup_status\n\nSelect an action:" \
            --column="Action" --column="Description" \
            "Launch SCUM + SAH" "Start both with watchdog" \
            "Manual Control" "Start/Stop SAH manually" \
            "Install" "Run installation wizard" \
            "Status" "View detailed status" \
            "Advanced Tools" "Shortcuts, dialogs, optimization" \
            "System & Maintenance" "Backups, logs, troubleshooting" \
            "Quit" "Exit" \
            --cancel-label="Quit" 2>/dev/null) || true
        choice="${choice//[$'\r\n']}"
        choice="${choice#"${choice%%[![:space:]]*}"}"
        choice="${choice%"${choice##*[![:space:]]}"}"
        
        # Ensure any lingering loading indicators are closed
        close_working 2>/dev/null
        
        case "$choice" in
            "Launch SCUM + SAH")
                launch_scum_and_sah
                ;;
            "Manual Control")
                manual_control
                ;;
            "Install")
                run_installation
                ;;
            "Status")
                log "User selected: Status"
                
                # Run the external status script with --detailed flag
                local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
                
                # Capture both stdout and check if script exists
                if [ -f "$script_dir/status-sah.sh" ]; then
                    local detailed_output
                    detailed_output=$(bash "$script_dir/status-sah.sh" --detailed 2>&1)
                    
                    # Show in scrollable text window for better readability
                    zenity --text-info --title="Detailed Status" --width=700 --height=600 \
                        --filename=<(echo "$detailed_output") 2>/dev/null
                else
                    # Fallback to old behavior if script not found
                    local detailed_status
                    detailed_status=$(check_installation_status 0)
                    zenity --info --title="Status" --text="$detailed_status" --width=400 --no-wrap 2>/dev/null
                fi
                ;;
            "Advanced Tools")
                advanced_tools
                ;;
            "System & Maintenance")
                system_maintenance
                ;;
            "Quit"|"")
                log "User quit GUI"
                exit 0
                ;;
            *)
                log "Unexpected menu value: '$choice'"
                exit 1
                ;;
        esac
    done
}

# Show welcome screen on first run (no initial progress dialog - avoids zenity conflicts)
if ! check_installation_status 1 > /dev/null 2>&1; then
    zenity --info --title="Welcome to SCUM Admin Helper Manager" --width=500 --text="<b>Welcome!</b>

This tool helps you install and manage SCUM Admin Helper on Linux.

<b>Before starting:</b>
• Install SCUM via Steam
• Run SCUM at least once
• Install protontricks (pip install protontricks)

<b>What this does:</b>
• Installs SCUM Admin Helper into SCUM's Proton prefix
• Configures required dependencies (.NET Framework)
• Creates helper scripts for Steam integration
• Provides tools for testing and troubleshooting

Ready to begin?" 2>/dev/null
fi

# Start main menu
main_menu
