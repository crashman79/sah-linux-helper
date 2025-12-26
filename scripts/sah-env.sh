#!/bin/bash
# Environment variables for running SCUM Admin Helper with Wine
# Source this file before launching SAH to ensure consistent rendering settings

# Reduce Wine debug output - suppress known harmless errors
# Shows critical errors but hides common Wine warnings that don't affect SAH
export WINEDEBUG=-all,err+all,err-ole,err-tabtip,err-quartz,err-seh,err-d3d,err-combase

# All rendering variables disabled - SAH works better without them!
# export LIBGL_ALWAYS_SOFTWARE=1
# export __GL_SYNC_TO_VBLANK=0
# export MESA_GL_VERSION_OVERRIDE=3.3
# export __GL_SHADER_DISK_CACHE=0

# File dialog compatibility settings
export WINE_WINDOWS_VERSION="win10"

# SCUM game AppID on Steam
export SCUM_APPID=513710

# Find SCUM Proton prefix and SAH installation paths
if [ -z "$SCUM_COMPAT_PATH" ]; then
    for lib in ~/.steam/steam ~/.local/share/Steam /mnt/*/SteamLibrary /mnt/*/*/SteamLibrary; do
        test_path="$lib/steamapps/compatdata/$SCUM_APPID"
        if [ -d "$test_path" ]; then
            export SCUM_COMPAT_PATH="$test_path"
            export SCUM_PREFIX="$test_path/pfx"
            export SAH_INSTALL_PATH="$test_path/pfx/drive_c/users/steamuser/AppData/Local/SCUM_Admin_Helper"
            export SAH_CONFIG_DIR="$SAH_INSTALL_PATH"
            break
        fi
    done
fi
