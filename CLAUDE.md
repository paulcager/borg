# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a documentation repository for Borg backup setup on Linux Mint with rsync.net. It contains setup instructions and configuration examples for automated backups using BorgBackup.

## Repository Structure

- `borg-backup-setup.md` - Complete setup guide covering installation, initialization, backup scripts, systemd timer configuration, and restore procedures
- `borg-backup.sh` - The backup script that creates, prunes, and compacts Borg backups
- `borg-diff-latest.sh` - Helper script to show what changed in the most recent backup
- `exclude-patterns.txt` - List of paths to exclude from backups (relative to $HOME)
- `password` - Repository passphrase (read-only, chmod 400)
- Generated files (gitignored, included in backups):
  - `installed-packages.txt` - List of manually installed packages
  - `dpkg-selections.txt` - Complete package selection state
  - `apt-sources.txt` - APT repository sources
  - `etc.git.tar.gz` - etckeeper git history (manually created)

## Key Information

The backup setup uses:
- **BorgBackup** with repokey encryption
- **rsync.net** as the remote storage provider
- **systemd user timers** for daily automated backups (TODO: not yet configured)
- **--one-file-system** flag to automatically exclude mounted filesystems (sshfs, NFS, etc.)
- **--exclude-from** to read exclusion patterns from `exclude-patterns.txt`

File locations:
- Backup script: `./borg-backup.sh` (in this repo)
- Diff helper: `./borg-diff-latest.sh` (in this repo)
- Exclude patterns: `./exclude-patterns.txt` (in this repo)
- Systemd service/timer: `~/.config/systemd/user/borg-backup.{service,timer}` (TODO: not yet created)

Scripts use `$SCRIPT_DIR` to locate files relative to themselves, making them portable.

## Backup Script Details

The `borg-backup.sh` script:
- Creates encrypted backup with timestamp format: `{hostname}-{YYYY-MM-DDTHH:MM}`
- Uses `--one-file-system` to exclude mounted filesystems (sshfs, NFS, etc.)
- Reads exclusion patterns from `exclude-patterns.txt`
- Captures package lists before each backup (apt-mark, dpkg selections, apt sources)
- Prunes old backups (keeps 7 daily, 4 weekly, 6 monthly)
- Compacts repository after pruning

### Exclusion patterns

Maintained in `exclude-patterns.txt` using `sh:**` pattern syntax:
- Sensitive files (borg/password - stored in Bitwarden)
- Cache directories (.cache, .config/borg, .dbus, Trash, snap caches, thumbnails)
- Browser storage (.mozilla/firefox/*/storage, .config/google-chrome/)
- Development tools (.local/share/JetBrains/, .cache/JetBrains/, esp-idf)
- AI/ML caches (.cache/whisper/, pipx venvs)
- Embedded development (.arduino15/, .platformio/, .espressif/)
- Project-specific (work-chrome/, go/pkg/, git/prometheus/)

### System state capture

The script generates these files (gitignored, included in backups):
- `installed-packages.txt` - Manually installed packages (apt-mark showmanual)
- `dpkg-selections.txt` - All package selections
- `apt-sources.txt` - APT repository sources
- `etc.git.tar.gz` - etckeeper git history (created manually when /etc changes)

## Common Operations

### Run backup manually
```bash
./borg-backup.sh
```

### List all backups
```bash
export BORG_REPO="rsync:laptop"
export BORG_PASSCOMMAND="cat $PWD/password"
borg list
```

### Check what changed in latest backup
```bash
# See all changes
./borg-diff-latest.sh

# See changes in a specific directory
./borg-diff-latest.sh home/paul/Documents
```

### Restore a single file
```bash
export BORG_REPO="rsync:laptop"
export BORG_PASSCOMMAND="cat $PWD/password"

# List files in a backup
borg list ::hostname-2026-04-08T02:00

# Extract one file (restores relative to current directory)
borg extract ::hostname-2026-04-08T02:00 home/paul/path/to/file.txt
```

### Mount and browse backups
```bash
mkdir -p /tmp/borg-mount
borg mount rsync:laptop /tmp/borg-mount
# Browse and copy what you need
borg umount /tmp/borg-mount
```

## Important Security Notes

- The `password` file is read-only (chmod 400) and is excluded from git commits
- The passphrase and exported encryption key should be stored in a password manager (Bitwarden)
- The backup script uses BORG_REPO and BORG_PASSCOMMAND environment variables
- For recovery, you need both the exported encryption key AND the passphrase (both stored in Bitwarden)
