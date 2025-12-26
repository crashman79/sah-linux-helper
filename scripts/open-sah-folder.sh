#!/bin/bash
# Open Wine Desktop folder where SAH saves exports by default

SCUM_APPID=513710

# Find Wine Desktop directory (default location for file dialogs)
DESKTOP_DIR=""
for lib in ~/.steam/steam ~/.local/share/Steam /mnt/*/SteamLibrary /mnt/*/*/SteamLibrary; do
    test_dir="$lib/steamapps/compatdata/$SCUM_APPID/pfx/drive_c/users/steamuser/Desktop"
    if [ -d "$test_dir" ]; then
        DESKTOP_DIR="$test_dir"
        break
    fi
done

if [ -z "$DESKTOP_DIR" ]; then
    echo "ERROR: Wine Desktop directory not found."
    echo "Make sure SCUM and SAH are installed."
    exit 1
fi

echo "Opening Wine Desktop folder (default for SAH exports/imports):"
echo "$DESKTOP_DIR"
echo

# Open in file manager
if command -v xdg-open &> /dev/null; then
    xdg-open "$DESKTOP_DIR" &
elif command -v dolphin &> /dev/null; then
    dolphin "$DESKTOP_DIR" &
elif command -v nautilus &> /dev/null; then
    nautilus "$DESKTOP_DIR" &
elif command -v thunar &> /dev/null; then
    thunar "$DESKTOP_DIR" &
else
    echo "No file manager found. Path copied to clipboard (if available)."
    echo "$DESKTOP_DIR" | xclip -selection clipboard 2>/dev/null || echo "$DESKTOP_DIR"
fi

echo ""
echo "This is where SAH's file dialogs save exports and look for imports."
echo "Tip: Place files here before importing, or retrieve exported files from here."
