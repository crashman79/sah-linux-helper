#!/bin/bash
# Kill SCUM Admin Helper process

HELPER_PROCESS="SCUM Admin Helper.exe"

if ! pgrep -f "$HELPER_PROCESS" > /dev/null 2>&1; then
    echo "SCUM Admin Helper is not running."
    exit 0
fi

echo "Stopping SCUM Admin Helper..."
pkill -f "$HELPER_PROCESS"
sleep 1

if ! pgrep -f "$HELPER_PROCESS" > /dev/null 2>&1; then
    echo "✓ SCUM Admin Helper stopped successfully"
else
    echo "Force killing SCUM Admin Helper..."
    pkill -9 -f "$HELPER_PROCESS"
    echo "✓ Force killed"
fi
