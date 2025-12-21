#!/bin/bash
# Restore SCUM Admin Helper from backup

echo "======================================"
echo "SCUM Admin Helper Restore Tool"
echo "======================================"
echo

BACKUP_BASE="$HOME/sah-backups"

if [ ! -d "$BACKUP_BASE" ]; then
    echo "ERROR: No backups found at $BACKUP_BASE"
    exit 1
fi

# List available backups
echo "Available backups:"
echo
BACKUPS=($(ls -1dt "$BACKUP_BASE"/backup-* 2>/dev/null))

if [ ${#BACKUPS[@]} -eq 0 ]; then
    echo "No backups found."
    exit 1
fi

i=1
for backup in "${BACKUPS[@]}"; do
    echo "$i) $(basename "$backup")"
    if [ -f "$backup/backup-info.txt" ]; then
        grep "Backup Type\|Backup Date" "$backup/backup-info.txt" | sed 's/^/   /'
        echo
    fi
    ((i++))
done

read -p "Select backup to restore [1-${#BACKUPS[@]}] or 0 to cancel: " choice

if [ "$choice" -eq 0 ] 2>/dev/null || [ "$choice" -gt ${#BACKUPS[@]} ] 2>/dev/null; then
    echo "Cancelled."
    exit 0
fi

SELECTED_BACKUP="${BACKUPS[$((choice-1))]}"

echo
echo "Selected: $(basename "$SELECTED_BACKUP")"
echo

if [ -f "$SELECTED_BACKUP/backup-info.txt" ]; then
    cat "$SELECTED_BACKUP/backup-info.txt"
    echo
fi

read -p "Restore this backup? (y/N): " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

# Determine backup type
if [ -d "$SELECTED_BACKUP/SCUM_Admin_Helper" ]; then
    # SAH only backup
    echo "Restoring SAH only backup..."
    
    SCUM_APPID=513710
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
    
    SAH_DEST="$COMPAT_PATH/pfx/drive_c/users/steamuser/AppData/Local/SCUM_Admin_Helper"
    
    # Remove existing
    if [ -d "$SAH_DEST" ]; then
        echo "Removing current SAH installation..."
        rm -rf "$SAH_DEST"
    fi
    
    # Restore
    echo "Copying SAH files..."
    mkdir -p "$(dirname "$SAH_DEST")"
    cp -r "$SELECTED_BACKUP/SCUM_Admin_Helper" "$SAH_DEST"
    
    # Restore winetricks log if present
    if [ -f "$SELECTED_BACKUP/winetricks.log" ]; then
        echo "Restoring winetricks log..."
        cp "$SELECTED_BACKUP/winetricks.log" "$COMPAT_PATH/pfx/"
    fi
    
    echo "✓ SAH restored successfully!"
    
elif [ -d "$SELECTED_BACKUP/compatdata-513710" ]; then
    # Full prefix backup
    echo "Restoring full SCUM prefix..."
    echo "WARNING: This will replace your current SCUM prefix!"
    echo
    read -p "Are you sure? (type 'yes'): " confirm
    
    if [ "$confirm" != "yes" ]; then
        echo "Cancelled."
        exit 0
    fi
    
    SCUM_APPID=513710
    COMPAT_PATH=""
    for lib in ~/.steam/steam ~/.local/share/Steam /mnt/*/SteamLibrary; do
        test_path="$lib/steamapps/compatdata/$SCUM_APPID"
        if [ -d "$test_path" ]; then
            COMPAT_PATH="$test_path"
            break
        fi
    done
    
    if [ -z "$COMPAT_PATH" ]; then
        echo "ERROR: SCUM installation location not found."
        exit 1
    fi
    
    echo "Removing current prefix..."
    rm -rf "$COMPAT_PATH"
    
    echo "Restoring prefix (this may take a while)..."
    cp -r "$SELECTED_BACKUP/compatdata-513710" "$COMPAT_PATH"
    
    echo "✓ SCUM prefix restored successfully!"
else
    echo "ERROR: Unknown backup format."
    exit 1
fi

echo
echo "Restore complete!"
echo
