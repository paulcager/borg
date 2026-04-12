# Borg Backup Setup (Linux Mint → rsync.net)

Backs up home directory with automatic exclusion of mounted filesystems (sshfs, NFS, etc.).

## Status

- ✅ Borg installed
- ✅ Repository initialized
- ✅ Backup script created (`borg-backup.sh` in this repo)
- ✅ Exclude patterns file created (`exclude-patterns.txt` in this repo)
- ⏳ TODO: Set up systemd timer for automated daily backups

## Prerequisites

- Account on rsync.net
- SSH key access configured

## Install

```bash
sudo apt install borgbackup
ssh-copy-id your-user@ch-s010.rsync.net
```

## Initialise the repo

```bash
borg init --encryption=repokey your-user@ch-s010.rsync.net:laptop
```

Export and store the key off-machine (password manager, print it, etc.):

```bash
borg key export your-user@ch-s010.rsync.net:laptop ~/borg-key-backup.txt
```

## Backup script

✅ **Implemented** in `borg-backup.sh` (in this repo)

The script includes:
- Creates encrypted backup with timestamp
- Uses `--one-file-system` to exclude mounted filesystems (sshfs, NFS, etc.)
- Reads exclusion patterns from `exclude-patterns.txt`
- Prunes old backups (keeps 7 daily, 4 weekly, 6 monthly)
- Compacts repository

Exclusion patterns are maintained in `exclude-patterns.txt` and include:
- Cache directories (.cache, .config/borg, .dbus, Trash, snap caches, thumbnails)
- Browser storage (.mozilla/firefox/*/storage, .config/google-chrome/)
- Development tools (.local/share/JetBrains/, .cache/JetBrains/)
- AI/ML caches (.cache/whisper/, pipx venvs)
- Embedded development (.arduino15/, .platformio/, .espressif/)
- Project-specific (work-chrome/, go/pkg/, git/prometheus/)

To run manually:
```bash
./borg-backup.sh
```

### Script structure

The script uses `$SCRIPT_DIR` to locate files relative to its own location, making it portable:

```bash
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
```

## Automate with systemd timer

⏳ **TODO**: Set up systemd timer for daily automated backups

Create `~/.config/systemd/user/borg-backup.service`:

```ini
[Unit]
Description=Borg backup to rsync.net

[Service]
Type=oneshot
ExecStart=%h/borg/borg-backup.sh
Nice=19
IOSchedulingClass=idle
```

`~/.config/systemd/user/borg-backup.timer`:

```ini
[Unit]
Description=Daily borg backup

[Timer]
OnCalendar=daily
Persistent=true
RandomizedDelaySec=30m

[Install]
WantedBy=timers.target
```

`Persistent=true` ensures the backup runs at next boot if the laptop was off at the scheduled time.

Enable the timer:
```bash
systemctl --user daemon-reload
systemctl --user enable --now borg-backup.timer
```

## Manual testing

List backups:

```bash
export BORG_REPO="your-user@ch-s010.rsync.net:laptop"
borg list
```

## Restoring a single file

```bash
export BORG_REPO="your-user@ch-s010.rsync.net:laptop"

# List files in a backup
borg list ::hostname-2026-04-08T02:00

# Extract one file (restores relative to current directory)
borg extract ::hostname-2026-04-08T02:00 home/pcager/path/to/file.txt
```

Or mount and browse:

```bash
mkdir -p /tmp/borg-mount
borg mount your-user@ch-s010.rsync.net:laptop /tmp/borg-mount
# Browse and copy what you need
borg umount /tmp/borg-mount
```
