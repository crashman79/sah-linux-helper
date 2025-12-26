#!/bin/bash
# Configure SAH delays for optimal Linux performance
# Sets recommended "Open Chat" delay for better window focus behavior

SCUM_APPID=513710

echo "======================================"
echo "SAH Delay Configuration for Linux"
echo "======================================"
echo
echo "This script adjusts SAH's chat delay settings for better"
echo "compatibility with Linux window managers."
echo
echo "Recommended setting:"
echo "  Open Chat Delay: 2000ms (2 seconds)"
echo
echo "This gives you time to switch focus back to SCUM after"
echo "activating a command in SAH."
echo
read -p "Continue? (y/N): " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

# Find SAH config directory
CONFIG_DIR=""
for lib in ~/.steam/steam ~/.local/share/Steam /mnt/*/SteamLibrary /mnt/*/*/SteamLibrary; do
    sah_config="$lib/steamapps/compatdata/$SCUM_APPID/pfx/drive_c/users/steamuser/AppData/Local/SCUM_Admin_Helper"
    if [ -d "$sah_config" ]; then
        CONFIG_DIR="$sah_config"
        break
    fi
done

if [ -z "$CONFIG_DIR" ]; then
    echo "✗ ERROR: SAH configuration directory not found."
    echo "Make sure SAH is installed and has been run at least once."
    exit 1
fi

# Find user.config file
CONFIG_FILE=$(find "$CONFIG_DIR" -name "user.config" -type f 2>/dev/null | head -1)

if [ -z "$CONFIG_FILE" ] || [ ! -f "$CONFIG_FILE" ]; then
    echo "✗ ERROR: user.config not found."
    echo "Please launch SAH at least once to create the config file."
    exit 1
fi

echo "Found config: $CONFIG_FILE"
echo

# Check current settings
CURRENT_DELAY=$(grep -o '"OpenDelay":"[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)

if [ -n "$CURRENT_DELAY" ]; then
    echo "Current Open Chat Delay: ${CURRENT_DELAY}ms"
else
    echo "Current Open Chat Delay: Not set (will use SAH default)"
fi

echo
echo "Select new Open Chat Delay:"
echo "  1) 1500ms (1.5 seconds) - Fast systems"
echo "  2) 2000ms (2 seconds)   - Recommended for most systems"
echo "  3) 2500ms (2.5 seconds) - Slower systems or multiple monitors"
echo "  4) 3000ms (3 seconds)   - Maximum compatibility"
echo "  5) Custom value"
echo "  6) Cancel"
echo
read -p "Select option [1-6]: " choice

case "$choice" in
    1) NEW_DELAY="1500" ;;
    2) NEW_DELAY="2000" ;;
    3) NEW_DELAY="2500" ;;
    4) NEW_DELAY="3000" ;;
    5)
        echo
        read -p "Enter custom delay in milliseconds (500-5000): " CUSTOM_DELAY
        if [[ "$CUSTOM_DELAY" =~ ^[0-9]+$ ]] && [ "$CUSTOM_DELAY" -ge 500 ] && [ "$CUSTOM_DELAY" -le 5000 ]; then
            NEW_DELAY="$CUSTOM_DELAY"
        else
            echo "✗ Invalid delay. Must be between 500 and 5000."
            exit 1
        fi
        ;;
    6)
        echo "Cancelled."
        exit 0
        ;;
    *)
        echo "✗ Invalid option."
        exit 1
        ;;
esac

# Backup config
BACKUP_FILE="${CONFIG_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
cp "$CONFIG_FILE" "$BACKUP_FILE"
echo "✓ Config backed up to: $BACKUP_FILE"

# Update the config
if grep -q '"spawning"' "$CONFIG_FILE"; then
    # spawning section exists, update OpenDelay
    sed -i "s/\"OpenDelay\":\"[^\"]*\"/\"OpenDelay\":\"$NEW_DELAY\"/" "$CONFIG_FILE"
    echo "✓ Updated OpenDelay to ${NEW_DELAY}ms"
else
    echo "⚠ Warning: spawning section not found in config."
    echo "This is normal if SAH hasn't been configured yet."
    echo "The setting will take effect when you configure spawning options in SAH."
fi

echo
echo "======================================"
echo "Configuration complete!"
echo "======================================"
echo
echo "New setting: Open Chat Delay = ${NEW_DELAY}ms"
echo
echo "Next steps:"
echo "1. Close SAH if it's running: pkill -f 'SCUM Admin Helper'"
echo "2. Launch SAH again"
echo "3. Test with a harmless command"
echo "4. Adjust delay if needed by running this script again"
echo
echo "Usage tip:"
echo "  1. Click command in SAH"
echo "  2. Immediately switch to SCUM (Alt+Tab)"
echo "  3. SAH will open chat after ${NEW_DELAY}ms delay"
echo "  4. Command executes in SCUM"
echo

read -p "Restart SAH now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Stopping SAH..."
    pkill -f "SCUM Admin Helper" 2>/dev/null
    sleep 2
    echo "✓ SAH stopped. Launching..."
    
    # Launch SAH and wait for it to exit
    source "$(dirname "$0")/sah-env.sh"
    protontricks-launch --appid 513710 "$SAH_INSTALL_PATH/SCUM Admin Helper.exe"
    
    echo
    echo "SAH closed."
fi
