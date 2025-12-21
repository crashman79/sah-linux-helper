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
    zenity --question --title="SCUM Admin Helper" --text="$1" --width=400 --no-wrap 2>/dev/null
}

# Function to show a brief working notification
show_working() {
    local title="${1:-Working}"
    local message="${2:-Please wait...}"
    (
        echo "0"
        echo "# $message"
        while true; do
            sleep 0.2
            echo "# $message"
        done
    ) | zenity --progress --title="$title" --pulsate --auto-close --no-cancel --width=300 2>/dev/null &
    WORKING_PID=$!
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
    
    [ $quiet -eq 0 ] && log "Checking installation status..."
    [ $quiet -eq 0 ] && show_working "Status Check" "Checking installation status..."
    
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
    
    [ $quiet -eq 0 ] && close_working
    
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

Continue?" 2>/dev/null
    
    if [ $? -ne 0 ]; then
        log "User cancelled installation"
        return 1
    fi
    
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
    
    # Wait a moment for user to close terminal
    sleep 1
    
    # Check if installation succeeded by verifying SAH was installed
    if find ~/.steam ~/.local/share/Steam /mnt -path "*/compatdata/$SCUM_APPID/*/SCUM Admin Helper.exe" 2>/dev/null | head -1 | grep -q .; then
        log "Installation verified successfully"
        show_info "✓ Installation completed!\n\nSCUM Admin Helper is now installed.\n\nYou can launch it from your application menu\nor use the 'Desktop Info' option to learn more."
    else
        log "Installation verification failed"
        show_error "✗ Installation could not be verified.\n\nPlease check the terminal output for errors.\n\nCommon issues:\n• SCUM not launched at least once\n• Missing dependencies\n• Network connection problems"
    fi
}

# Function to show desktop shortcut info
show_desktop_info() {
    log "User selected: Desktop Shortcut Info"
    
    local desktop_file="$HOME/.local/share/applications/scum-admin-helper.desktop"
    
    if [ ! -f "$desktop_file" ]; then
        show_error "Desktop shortcut not found!\n\nPlease run the installation first."
        return 1
    fi
    
    # Find the launch script path from desktop file
    local launch_script=$(grep "^Exec=" "$desktop_file" | cut -d'=' -f2)
    
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
    
    # Find the launch script in the SCUM directory
    local launch_script=""
    for lib in ~/.steam/steam ~/.local/share/Steam /mnt/*/SteamLibrary /mnt/*/*/SteamLibrary; do
        if [ -d "$lib" ]; then
            local scum_script="$lib/steamapps/common/SCUM/launch-sah.sh"
            if [ -f "$scum_script" ]; then
                launch_script="$scum_script"
                break
            fi
        fi
    done
    
    if [ -z "$launch_script" ] || [ ! -f "$launch_script" ]; then
        log "ERROR: Launch script not found"
        show_error "Launch script not found!\n\nPlease run the installation first.\n\nThe script should be in:\nSCUM/launch-sah.sh"
        return 1
    fi
    
    if ask_question "This will launch SCUM Admin Helper.\n\nYou'll need to close it manually.\n\nContinue?"; then
        log "Launching SCUM Admin Helper..."
        show_working "Launching" "Starting SCUM Admin Helper..."
        
        # Run launch script and capture output
        if bash "$launch_script" > /tmp/sah-launch.log 2>&1 & then
            local launch_pid=$!
            sleep 3
            
            if pgrep -f "SCUM Admin Helper.exe" > /dev/null 2>&1; then
                close_working
                log "SAH launched successfully (PID: $(pgrep -f 'SCUM Admin Helper.exe'))"
                show_info "✓ SCUM Admin Helper launched successfully!\n\nClose it when you're done testing."
            else
                close_working
                log "ERROR: SAH failed to launch"
                # Check if launch script had errors
                if [ -f /tmp/sah-launch.log ] && [ -s /tmp/sah-launch.log ]; then
                    show_error "✗ Failed to launch SCUM Admin Helper.\n\nError details saved to:\n/tmp/sah-launch.log\n\nCommon causes:\n• .NET Framework not installed\n• Proton prefix issues\n• SAH not installed correctly"
                else
                    show_error "✗ Failed to launch SCUM Admin Helper.\n\nThe process started but SAH didn't run.\n\nTry running manually:\n$launch_script"
                fi
            fi
        else
            close_working
            log "ERROR: Failed to execute launch script"
            show_error "✗ Failed to execute launch script.\n\nCheck that it exists and is executable:\n$launch_script"
        fi
    fi
}

# Function to manually control SAH
manual_control() {
    log "User selected: Manual Control"
    local choice=$(zenity --list --title="Manual Control" --width=400 --height=300 \
        --text="Select an action:" \
        --column="Action" --column="Description" \
        "Launch SAH" "Start SCUM Admin Helper" \
        "Stop SAH" "Close SCUM Admin Helper" \
        "Status" "Check running processes" \
        "Back" "Return to main menu" 2>/dev/null)
    
    case "$choice" in
        "Launch SAH")
            log "Manual Control: Launch SAH"
            # Find the launch script in the SCUM directory
            local launch_script=""
            for lib in ~/.steam/steam ~/.local/share/Steam /mnt/*/SteamLibrary /mnt/*/*/SteamLibrary; do
                if [ -d "$lib" ]; then
                    local scum_script="$lib/steamapps/common/SCUM/launch-sah.sh"
                    if [ -f "$scum_script" ]; then
                        launch_script="$scum_script"
                        break
                    fi
                fi
            done
            
            if [ -n "$launch_script" ] && [ -f "$launch_script" ]; then
                show_working "Starting" "Launching SCUM Admin Helper..."
                bash "$launch_script" > /tmp/sah-manual-launch.log 2>&1 &
                sleep 2
                
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
                log "ERROR: Launch script not found"
                show_error "✗ Launch script not found\n\nPlease run the installation first.\n\nThe script should be in:\nSCUM/launch-sah.sh"
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
            local status=$(check_installation_status 0)
            zenity --info --title="Status" --text="$status" --width=400 --no-wrap 2>/dev/null
            zenity --info --title="Status" --text="$status" --width=400 --no-wrap 2>/dev/null
            ;;
    esac
}

# Function to view logs
view_logs() {
    log "User selected: View Logs"
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
    
    local selected=$(zenity --list --title="View Logs" --width=500 --height=300 \
        --checklist --column="View" --column="File" --column="Description" \
        "${log_files[@]}" 2>/dev/null)
    
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
    
    local choice=$(zenity --list --title="Backup Management" --width=450 --height=350 \
        --text="Manage SCUM Admin Helper backups:\n\nSCUM Prefix: $compat_path" \
        --column="Action" --column="Description" \
        "Create Backup" "Create new backup" \
        "List Backups" "View existing backups" \
        "Restore Backup" "Restore from backup" \
        "Delete Backups" "Remove old backups" \
        "Back" "Return to main menu" 2>/dev/null)
    
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
    
    local backup_type=$(zenity --list --title="Backup Type" --width=450 --height=250 \
        --text="Select backup type:" \
        --column="Type" --column="Size" --column="Description" \
        "SAH Only" "~100MB" "SAH app + settings + .NET info" \
        "Full Prefix" "~2-5GB" "Everything (SAH + .NET + all prefix data)" 2>/dev/null)
    
    if [ -z "$backup_type" ]; then
        return 0
    fi
    
    local backup_dir="$HOME/sah-backups/backup-$(date +%Y%m%d-%H%M%S)"
    
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
            
            local size=$(du -sh "$backup_dir" 2>/dev/null | cut -f1)
            show_info "✓ SAH backup created!\n\nLocation: $backup_dir\nSize: $size\n\nBacked up:\n• SAH application\n• SAH settings\n• Winetricks log"
            log "Backup created: $backup_dir ($size)"
            ;;
            
        "Full Prefix")
            log "Creating full prefix backup"
            
            # Calculate and show size first
            show_working "Calculating" "Calculating prefix size..."
            local size=$(du -sh "$compat_path" 2>/dev/null | cut -f1)
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
            
            local backup_size=$(du -sh "$backup_dir" 2>/dev/null | cut -f1)
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
            local backup_name=$(basename "$backup")
            local backup_size=$(du -sh "$backup" 2>/dev/null | cut -f1)
            local backup_type=$(grep "^Backup Type:" "$backup/backup-info.txt" 2>/dev/null | cut -d':' -f2- | xargs)
            local backup_date=$(grep "^Backup Date:" "$backup/backup-info.txt" 2>/dev/null | cut -d':' -f2- | xargs)
            
            backup_list+=("FALSE" "$backup_name" "$backup_type" "$backup_size" "$backup_date")
            ((backup_count++))
        fi
    done
    
    close_working
    
    if [ $backup_count -eq 0 ]; then
        show_info "No backups found.\n\nCreate a backup using:\nBackup Management > Create Backup"
        return 0
    fi
    
    local selected=$(zenity --list --title="Available Backups" --width=700 --height=400 \
        --text="Found $backup_count backup(s):\n" \
        --checklist --column="View" --column="Backup Name" --column="Type" --column="Size" --column="Date" \
        "${backup_list[@]}" 2>/dev/null)
    
    if [ -n "$selected" ]; then
        # Show details for selected backup
        local backup_name=$(echo "$selected" | cut -d'|' -f1)
        local backup_path="$HOME/sah-backups/$backup_name"
        
        if [ -f "$backup_path/backup-info.txt" ]; then
            local info=$(cat "$backup_path/backup-info.txt")
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
            local backup_name=$(basename "$backup")
            local backup_type=$(grep "^Backup Type:" "$backup/backup-info.txt" 2>/dev/null | cut -d':' -f2- | xargs)
            local backup_date=$(grep "^Backup Date:" "$backup/backup-info.txt" 2>/dev/null | cut -d':' -f2- | xargs)
            
            backup_list+=("$backup_name" "$backup_type - $backup_date")
            ((backup_count++))
        fi
    done
    
    close_working
    
    if [ $backup_count -eq 0 ]; then
        show_error "No backups found.\n\nCreate a backup first:\nBackup Management > Create Backup"
        return 1
    fi
    
    local selected=$(zenity --list --title="Restore Backup" --width=600 --height=400 \
        --text="Select backup to restore:\n⚠ This will overwrite current installation!" \
        --column="Backup Name" --column="Details" \
        "${backup_list[@]}" 2>/dev/null)
    
    if [ -z "$selected" ]; then
        return 0
    fi
    
    local backup_path="$HOME/sah-backups/$selected"
    local backup_type=$(grep "^Backup Type:" "$backup_path/backup-info.txt" 2>/dev/null | cut -d':' -f2- | xargs)
    
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
            local backup_name=$(basename "$backup")
            local backup_size=$(du -sh "$backup" 2>/dev/null | cut -f1)
            local backup_type=$(grep "^Backup Type:" "$backup/backup-info.txt" 2>/dev/null | cut -d':' -f2- | xargs)
            
            backup_list+=("FALSE" "$backup_name" "$backup_type" "$backup_size")
            ((backup_count++))
        fi
    done
    
    close_working
    
    if [ $backup_count -eq 0 ]; then
        show_info "No backups found."
        return 0
    fi
    
    local selected=$(zenity --list --title="Delete Backups" --width=600 --height=400 \
        --text="Select backups to delete:\n⚠ This action cannot be undone!" \
        --checklist --column="Delete" --column="Backup Name" --column="Type" --column="Size" \
        "${backup_list[@]}" 2>/dev/null)
    
    if [ -z "$selected" ]; then
        return 0
    fi
    
    # Confirm deletion
    local delete_count=$(echo "$selected" | tr '|' '\n' | wc -l)
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

# Function to show troubleshooting guide
show_troubleshooting() {
    log "User selected: Troubleshooting"
    zenity --info --title="Troubleshooting" --width=600 --height=500 --text="<b>Common Issues:</b>

<b>1. SAH doesn't launch:</b>
   • Ensure SCUM was run at least once (creates Proton prefix)
   • Check .NET Framework is installed
   • Run: protontricks --version
   • Check desktop shortcut: Desktop Info menu

<b>2. SAH doesn't close:</b>
   • Close manually: pkill -f 'SCUM Admin Helper.exe'
   • Or use Manual Control menu option

<b>3. Steam shows SCUM running when only SAH is open:</b>
   • This is expected behavior - SAH uses SCUM's prefix (App ID 513710)
   • Steam detects Proton/Wine activity and thinks SCUM is running
   • Workaround: Close SAH before closing SCUM, or ignore the indicator
   • Does not affect gameplay or Steam functionality

<b>4. Installation fails:</b>
   • Check internet connection
   • Verify disk space available
   • Review log files (View Logs menu)
   • Ensure SCUM launched at least once

<b>5. Dependencies missing:</b>
   • protontricks: pip install protontricks
   • curl: Install via system package manager
   • unzip: Install via system package manager

<b>More help:</b>
See docs/troubleshooting.md" 2>/dev/null
}

# Main menu loop
main_menu() {
    while true; do
        # Show loading before checking status
        show_working "Loading" "Checking system status..."
        
        # Get current status (quiet mode for main menu)
        local status_text=$(check_installation_status 1)
        local is_installed=$?
        
        close_working
        
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
        if [ $backup_count -gt 0 ]; then
            backup_status="  |  Backups: $backup_count"
        fi
        
        local choice=$(zenity --list --title="SCUM Admin Helper Manager" \
            --width=500 --height=450 \
            --text="<b>Status:</b> $status_summary$backup_status\n\nSelect an action:" \
            --column="Action" --column="Description" \
            "Install" "Run full installation wizard" \
            "Desktop Info" "Show desktop shortcut info" \
            "Test Launch" "Test SAH launch manually" \
            "Status" "View detailed status" \
            "Manual Control" "Start/Stop SAH manually" \
            "Backup Management" "Create/restore/manage backups" \
            "View Logs" "View installation logs" \
            "Troubleshooting" "Common issues and fixes" \
            "Quit" "Exit this program" 2>/dev/null)
        
        case "$choice" in
            "Install")
                run_installation
                ;;
            "Desktop Info")
                show_desktop_info
                ;;
            "Test Launch")
                test_sah_launch
                ;;
            "Status")
                log "User selected: Status"
                local detailed_status=$(check_installation_status 0)
                zenity --info --title="Detailed Status" --text="$detailed_status" --width=400 --no-wrap 2>/dev/null
                ;;
            "Manual Control")
                manual_control
                ;;
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
            "Quit"|"")
                log "User quit GUI"
                exit 0
                ;;
        esac
    done
}

# Show initial loading screen
show_working "SCUM Admin Helper" "Initializing GUI..."

# Show welcome screen on first run
if ! check_installation_status 1 > /dev/null 2>&1; then
    close_working
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
else
    # Close the loading screen after a brief moment
    sleep 0.5
    close_working
fi

# Start main menu
main_menu
