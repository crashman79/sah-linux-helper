#!/bin/bash
# Wrapper: run GUI and keep terminal open so output/errors are visible
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/sah-helper.sh"
r=$?
echo
echo "Press Enter to close..."
read
exit $r
