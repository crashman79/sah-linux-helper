#!/bin/bash
# Backup SCUM Admin Helper and/or SCUM Prefix
# This allows you to restore your setup after testing

SCUM_APPID=513710
BACKUP_DIR="$HOME/sah-backups/backup-$(date +%Y%m%d-%H%M%S)"

echo "======================================"
echo "SCUM Admin Helper Backup Tool"
echo "======================================"
echo

# Find SCUM prefix
COMPAT_PATH=""
for lib in ~/.steam/steam ~/.local/share/Steam /mnt/*/SteamLibrary; do
    test_path="$lib/steamapps/compatdata/$SCUM_APPID"
    if [ -d "$test_path" ]; then
        COMPAT_PATH="$test_path"
        break
    fi
done

if [ -z "$COMPAT_PATH" ]; then
    echo "ERROR: SCUM Proton prefix not found."
    exit 1
fi

echo "Found SCUM prefix at:"
echo "$COMPAT_PATH"
echo

# Show backup options
echo "Backup options:"
echo "  1) Backup SAH only (~100MB)"
echo "  2) Backup entire SCUM prefix (~2-5GB)"
echo "  3) Cancel"
echo
read -p "Select option [1-3]: " choice

case $choice in
    1)
        echo
        echo "Backing up SCUM Admin Helper only..."
        
        SAH_PATH="$COMPAT_PATH/pfx/drive_c/users/steamuser/AppData/Local/SCUM_Admin_Helper"
        
        if [ ! -d "$SAH_PATH" ]; then
            echo "ERROR: SAH not found at $SAH_PATH"
            exit 1
        fi
        
        mkdir -p "$BACKUP_DIR"
        
        # Backup SAH
        echo "Copying SAH files..."
        cp -r "$SAH_PATH" "$BACKUP_DIR/SCUM_Admin_Helper"
        
        # Backup winetricks log
        if [ -f "$COMPAT_PATH/pfx/winetricks.log" ]; then
            cp "$COMPAT_PATH/pfx/winetricks.log" "$BACKUP_DIR/"
        fi
        
        # Save metadata
        cat > "$BACKUP_DIR/backup-info.txt" << EOF
Backup Date: $(date)
Backup Type: SAH Only
SCUM Prefix: $COMPAT_PATH
SAH Path: $SAH_PATH

To restore:
1. Copy SCUM_Admin_Helper folder back to:
   $SAH_PATH
EOF
        
        echo "✓ Backup complete!"
        ;;
        
    2)
        echo
        echo "Backing up entire SCUM prefix..."
        echo "This may take several minutes..."
        
        mkdir -p "$BACKUP_DIR"
        
        # Calculate size
        SIZE=$(du -sh "$COMPAT_PATH" | cut -f1)
        echo "Prefix size: $SIZE"
        echo
        
        read -p "Continue? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Cancelled."
            exit 0
        fi
        
        # Backup entire prefix
        echo "Copying prefix (this will take a while)..."
        cp -r "$COMPAT_PATH" "$BACKUP_DIR/compatdata-$SCUM_APPID"
        
        # Save metadata
        cat > "$BACKUP_DIR/backup-info.txt" << EOF
Backup Date: $(date)
Backup Type: Full SCUM Prefix
SCUM Prefix: $COMPAT_PATH
Backup Size: $SIZE

To restore:
1. Delete current prefix:
   rm -rf $COMPAT_PATH
2. Restore backup:
   cp -r $BACKUP_DIR/compatdata-$SCUM_APPID $COMPAT_PATH
EOF
        
        echo "✓ Backup complete!"
        ;;
        
    *)
        echo "Cancelled."
        exit 0
        ;;
esac

echo
echo "Backup saved to:"
echo "$BACKUP_DIR"
echo
echo "Backup size:"
du -sh "$BACKUP_DIR"
echo

# Offer to clean current installation
echo "======================================"
echo "Clean Current Installation?"
echo "======================================"
echo
echo "Would you like to remove the current SAH installation"
echo "to test fresh installation?"
echo
read -p "Remove SAH? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    SAH_PATH="$COMPAT_PATH/pfx/drive_c/users/steamuser/AppData/Local/SCUM_Admin_Helper"
    
    if [ -d "$SAH_PATH" ]; then
        echo "Removing SAH..."
        rm -rf "$SAH_PATH"
        echo "✓ SAH removed"
    fi
    
    # Remove helper scripts
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if [ -f "$SCRIPT_DIR/launch-sah.sh" ]; then
        echo "Removing launch-sah.sh..."
        rm -f "$SCRIPT_DIR/launch-sah.sh"
    fi
    
    if [ -f "$SCRIPT_DIR/close-sah.sh" ]; then
        echo "Removing close-sah.sh..."
        rm -f "$SCRIPT_DIR/close-sah.sh"
    fi
    
    echo
    echo "✓ Clean installation ready!"
    echo "You can now run install-sah.sh to test fresh installation."
fi

echo
echo "======================================"
echo "To restore from backup:"
echo "======================================"
echo "See: $BACKUP_DIR/backup-info.txt"
echo
