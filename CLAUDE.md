# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a documentation repository for Borg backup setup on Linux Mint with rsync.net. It contains setup instructions and configuration examples for automated backups using BorgBackup.

## Repository Structure

- `borg-backup-setup.md` - Complete setup guide covering installation, initialization, backup scripts, systemd timer configuration, and restore procedures
- `borg-backup.sh` - The backup script that creates, prunes, and compacts Borg backups
- `exclude-patterns.txt` - List of paths to exclude from backups (relative to $HOME)
- `password` - Repository passphrase (read-only, chmod 400)
- `password.hint` - Hint for the repository passphrase

## Key Information

The backup setup uses:
- **BorgBackup** with repokey encryption
- **rsync.net** as the remote storage provider
- **systemd user timers** for daily automated backups (TODO: not yet configured)
- **--one-file-system** flag to automatically exclude mounted filesystems (sshfs, NFS, etc.)
- **--exclude-from** to read exclusion patterns from `exclude-patterns.txt`

File locations:
- Backup script: `./borg-backup.sh` (in this repo)
- Exclude patterns: `./exclude-patterns.txt` (in this repo)
- Systemd service/timer: `~/.config/systemd/user/borg-backup.{service,timer}` (TODO: not yet created)

The script uses `$SCRIPT_DIR` to locate files relative to itself, making it portable.

## Important Security Notes

- The `password` file is read-only (chmod 400) and should never be committed to version control if this becomes a git repository
- The backup script requires BORG_REPO and BORG_PASSPHRASE/BORG_PASSCOMMAND environment variables
- The encryption key should be exported and stored securely off-machine using `borg key export`
