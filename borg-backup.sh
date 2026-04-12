#!/bin/bash
set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export BORG_REPO="rsync:laptop"
export BORG_PASSCOMMAND="cat $SCRIPT_DIR/password"

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
