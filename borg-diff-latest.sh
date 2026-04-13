#!/bin/bash
set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export BORG_REPO="rsync:laptop"
export BORG_PASSCOMMAND="cat $SCRIPT_DIR/password"

echo "Fetching backup list..."
ARCHIVES=$(borg list --short)
LATEST=$(echo "$ARCHIVES" | tail -1)
PREVIOUS=$(echo "$ARCHIVES" | tail -2 | head -1)

if [ -z "$PREVIOUS" ]; then
    echo "Only one backup exists, nothing to compare."
    exit 0
fi

echo ""
echo "Comparing backups:"
echo "  Previous: $PREVIOUS"
echo "  Latest:   $LATEST"
echo ""

# Show diff with optional path filter
if [ $# -gt 0 ]; then
    echo "Filtering path: $1"
    borg diff --content-only ::$PREVIOUS $LATEST "$1"
else
    borg diff --content-only ::$PREVIOUS $LATEST
fi
