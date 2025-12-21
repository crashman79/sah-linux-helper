#!/bin/bash
# Check SCUM Admin Helper status

HELPER_PROCESS="SCUM Admin Helper.exe"
SCUM_PROCESS="SCUM-Win64-Shipping.exe"

echo "======================================"
echo "SCUM Admin Helper Status"
echo "======================================"
echo

# Check if SAH is running
if pgrep -f "$HELPER_PROCESS" > /dev/null 2>&1; then
    echo "✓ SCUM Admin Helper: RUNNING"
    pgrep -f "$HELPER_PROCESS" | while read pid; do
        echo "  PID: $pid"
    done
else
    echo "✗ SCUM Admin Helper: NOT RUNNING"
fi

echo

# Check if SCUM is running
if pgrep -f "$SCUM_PROCESS" > /dev/null 2>&1; then
    echo "✓ SCUM: RUNNING"
    pgrep -f "$SCUM_PROCESS" | while read pid; do
        echo "  PID: $pid"
    done
else
    echo "✗ SCUM: NOT RUNNING"
fi

echo
