#!/bin/bash
# Remove SCUM intro videos to speed up game startup

SCUM_APPID=513710

# Find SCUM installation directory
find_scum_dir() {
    for lib in ~/.steam/steam ~/.local/share/Steam /mnt/*/SteamLibrary /mnt/*/*/SteamLibrary; do
        if [ -d "$lib/steamapps/common/SCUM" ]; then
            echo "$lib/steamapps/common/SCUM"
            return 0
        fi
    done
    return 1
}

SCUM_DIR=$(find_scum_dir)

if [ -z "$SCUM_DIR" ]; then
    echo "Error: SCUM installation not found"
    echo ""
    echo "Searched locations:"
    echo "  ~/.steam/steam/steamapps/common/SCUM"
    echo "  ~/.local/share/Steam/steamapps/common/SCUM"
    echo "  /mnt/*/SteamLibrary/steamapps/common/SCUM"
    exit 1
fi

MOVIES_DIR="$SCUM_DIR/SCUM/Content/Movies"

if [ ! -d "$MOVIES_DIR" ]; then
    echo "Error: SCUM Movies directory not found at:"
    echo "  $MOVIES_DIR"
    exit 1
fi

echo "==============================================="
echo "    SCUM Intro Video Removal"
echo "==============================================="
echo ""
echo "SCUM Location: $SCUM_DIR"
echo "Movies Folder: $MOVIES_DIR"
echo ""
echo "This will remove intro videos to speed up game startup"
echo "and save disk space (~940MB)."
echo ""

VIDEOS=(
    "IntroCinematic.bk2"
    "CharacterCreationCinematic.bk2"
    "SplashVideoGamepires.bk2"
    "SplashVideoTechnologies.bk2"
)

REMOVED=0
TOTAL_SIZE=0

for video in "${VIDEOS[@]}"; do
    VIDEO_PATH="$MOVIES_DIR/$video"
    if [ -f "$VIDEO_PATH" ]; then
        SIZE=$(stat -c%s "$VIDEO_PATH" 2>/dev/null || echo 0)
        TOTAL_SIZE=$((TOTAL_SIZE + SIZE))
        rm -f "$VIDEO_PATH"
        if [ $? -eq 0 ]; then
            echo "✓ Removed: $video"
            REMOVED=$((REMOVED + 1))
        else
            echo "✗ Failed to remove: $video"
        fi
    else
        echo "- Already removed: $video"
    fi
done

echo ""
echo "==============================================="
if [ $REMOVED -gt 0 ]; then
    SIZE_MB=$((TOTAL_SIZE / 1024 / 1024))
    echo "✓ Success! Removed $REMOVED video(s), freed ${SIZE_MB}MB"
    echo ""
    echo "To restore videos, use Steam's file verification:"
    echo "  1. Right-click SCUM in Steam Library"
    echo "  2. Properties → Installed Files"
    echo "  3. Click 'Verify integrity of game files'"
    echo ""
    echo "Or run: xdg-open 'steam://validate/513710'"
else
    echo "No videos to remove (already removed or not found)"
fi
echo "==============================================="
