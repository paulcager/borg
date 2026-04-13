#!/bin/bash
set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export BORG_REPO="rsync:laptop"
export BORG_PASSCOMMAND="cat $SCRIPT_DIR/password"

# Capture system state before backup
echo "Capturing package lists..."
apt-mark showmanual > "$SCRIPT_DIR/installed-packages.txt"
dpkg --get-selections > "$SCRIPT_DIR/dpkg-selections.txt"
grep -r --include '*.list' '^deb ' /etc/apt/sources.list /etc/apt/sources.list.d/ > "$SCRIPT_DIR/apt-sources.txt" 2>/dev/null || true

borg create                              \
    --verbose --stats --progress         \
    --one-file-system                    \
    --exclude-caches                     \
    --exclude-from "$SCRIPT_DIR/exclude-patterns.txt" \
    ::'{hostname}-{now:%Y-%m-%dT%H:%M}'  \
    "$HOME"

borg prune --verbose --list  \
    --keep-daily=7           \
    --keep-weekly=4          \
    --keep-monthly=6

borg compact --verbose
