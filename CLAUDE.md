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

## Important Security Notes

- The `password` file is read-only (chmod 400) and is excluded from git commits
- The passphrase and exported encryption key should be stored in a password manager (Bitwarden)
- The backup script uses BORG_REPO and BORG_PASSCOMMAND environment variables
- For recovery, you need both the exported encryption key AND the passphrase (both stored in Bitwarden)
