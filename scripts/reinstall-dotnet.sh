#!/bin/bash

# reinstall-dotnet.sh - Force reinstall .NET Framework to fix DLL verification errors
# Part of SAH Helper for Linux

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Header
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       .NET Framework Reinstaller for SCUM/SAH         ║${NC}"
echo -e "${BLUE}║                 Fixes DLL Verification Errors          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check for protontricks
if ! command -v protontricks &> /dev/null; then
    log_error "protontricks is not installed"
    echo "Install with: pip3 install protontricks"
    exit 1
fi

# Find SCUM prefix
SCUM_APPID="513710"
STEAM_DIRS=(
    "$HOME/.steam/steam"
    "$HOME/.local/share/Steam"
)

SCUM_PREFIX=""
for STEAM_DIR in "${STEAM_DIRS[@]}"; do
    if [ -d "$STEAM_DIR/steamapps/compatdata/$SCUM_APPID/pfx" ]; then
        SCUM_PREFIX="$STEAM_DIR/steamapps/compatdata/$SCUM_APPID/pfx"
        log_info "Found SCUM prefix: $SCUM_PREFIX"
        break
    fi
done

if [ -z "$SCUM_PREFIX" ]; then
    log_error "SCUM Proton prefix not found!"
    echo "Make sure SCUM has been launched at least once to create the prefix."
    exit 1
fi

# Show current .NET status
echo ""
log_info "Checking current .NET Framework status..."
echo ""

echo "Installed .NET components:"
protontricks -c 'wine uninstaller --list' $SCUM_APPID 2>/dev/null | grep -i "\.NET" || echo "  None found"
echo ""

echo "Registry status:"
if protontricks -c 'wine reg query "HKLM\\Software\\Microsoft\\.NETFramework\\v4.0.30319" /v InstallPath' $SCUM_APPID 2>&1 | grep -q "InstallPath"; then
    log_success ".NET registry entries found"
    protontricks -c 'wine reg query "HKLM\\Software\\Microsoft\\.NETFramework\\v4.0.30319" /v InstallPath' $SCUM_APPID 2>&1 | grep InstallPath
else
    log_warn ".NET registry entries MISSING (this is the problem)"
fi
echo ""

# Explain the issue
log_warn "Common Issue: DLL Not Verified Errors"
echo ""
echo "This error occurs when .NET Framework registry entries are corrupted or missing,"
echo "even though the framework appears installed. This prevents proper DLL verification."
echo ""
echo "The reinstallation will:"
echo "  1. Force-reinstall .NET Framework 4.8"
echo "  2. Recreate all registry entries"
echo "  3. Re-verify assemblies in Global Assembly Cache (GAC)"
echo "  4. Configure runtime loader overrides"
echo ""

# Confirmation
read -p "Proceed with .NET Framework reinstallation? [Y/n] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ ! -z $REPLY ]]; then
    log_info "Reinstallation cancelled"
    exit 0
fi

echo ""
log_info "Starting .NET Framework 4.8 reinstallation..."
log_warn "This may take 5-10 minutes. You'll see many 'fixme:' messages - these are normal."
echo ""

# Create log file
LOG_FILE="/tmp/sah-reinstall-dotnet-$(date +%Y%m%d-%H%M%S).log"
log_info "Logging to: $LOG_FILE"
echo ""

# Perform reinstallation
if protontricks $SCUM_APPID --force dotnet48 2>&1 | tee "$LOG_FILE"; then
    log_success ".NET Framework 4.8 reinstallation completed!"
else
    log_error "Reinstallation failed. Check log: $LOG_FILE"
    exit 1
fi

echo ""
log_info "Verifying installation..."
echo ""

# Verify registry entries
if protontricks -c 'wine reg query "HKLM\\Software\\Microsoft\\.NETFramework\\v4.0.30319" /v InstallPath' $SCUM_APPID 2>&1 | grep -q "InstallPath"; then
    log_success "✓ Registry entries created successfully"
    protontricks -c 'wine reg query "HKLM\\Software\\Microsoft\\.NETFramework\\v4.0.30319" /v InstallPath' $SCUM_APPID 2>&1 | grep InstallPath
else
    log_warn "⚠ Registry entries not found - reinstallation may need to be repeated"
fi

# Verify uninstaller entry
echo ""
if protontricks -c 'wine uninstaller --list' $SCUM_APPID 2>/dev/null | grep -q "\.NET Framework 4.8"; then
    log_success "✓ .NET Framework 4.8 is registered in uninstaller"
else
    log_warn "⚠ .NET Framework 4.8 not found in uninstaller list"
fi

# Check for marker file
echo ""
MARKER_FILE="$SCUM_PREFIX/dosdevices/c:/windows/dotnet48.installed.workaround"
if [ -f "$MARKER_FILE" ]; then
    log_success "✓ Installation marker file exists"
else
    log_warn "⚠ Installation marker file not found"
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║            .NET Framework Reinstalled!                 ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

log_info "Next steps:"
echo "  1. Launch SAH to test: ./scripts/sah-helper.sh"
echo "  2. Launch SCUM from Steam"
echo "  3. Check for 'DLL not verified' errors - they should be gone"
echo ""

# Offer to launch SAH
read -p "Launch SCUM Admin Helper now to test? [Y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
    echo ""
    log_info "Launching SAH..."
    
    # Source environment to get SAH_INSTALL_PATH
    source "$(dirname "$0")/sah-env.sh"
    SAH_EXE="$SAH_INSTALL_PATH/SCUM Admin Helper.exe"
    
    if [ -f "$SAH_EXE" ]; then
        # Kill any existing SAH instances
        pkill -f "SCUM Admin Helper.exe" 2>/dev/null || true
        sleep 1
        
        # Launch SAH
        protontricks-launch --appid $SCUM_APPID "$SAH_EXE" &
        sleep 3
        
        if pgrep -f "SCUM Admin Helper.exe" > /dev/null; then
            log_success "SAH launched successfully! Check for any DLL errors."
        else
            log_warn "SAH may not have started. Check /tmp/sah-launch.log for errors."
        fi
    else
        log_error "SAH executable not found. You may need to reinstall SAH."
        echo "Run: ./scripts/install-sah.sh"
    fi
fi

echo ""
log_info "If you still experience 'DLL not verified' errors:"
echo "  1. Try running this script again"
echo "  2. Check troubleshooting guide: docs/troubleshooting.md"
echo "  3. Consider full prefix rebuild (last resort)"
echo ""

log_success "Reinstallation complete! Log saved to: $LOG_FILE"
