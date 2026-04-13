# Borg Backup Setup (Linux Mint → rsync.net)

Backs up home directory with automatic exclusion of mounted filesystems (sshfs, NFS, etc.).

## Status

- ✅ Borg installed
- ✅ Repository initialized
- ✅ Backup script created (`borg-backup.sh` in this repo)
- ✅ Exclude patterns file created (`exclude-patterns.txt` in this repo)
- ℹ️  Manual backups preferred (systemd timer reference below for other machines)

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

✅ **Implemented** - See `borg-backup.sh` and `exclude-patterns.txt` in this repo. The script automatically captures package lists before each backup.

Run manually:
```bash
./borg-backup.sh
```

## Automate with systemd timer (optional)

For automated daily backups on other machines:

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

## Operational procedures

For day-to-day operations (listing backups, checking changes, restoring files), see the "Common Operations" section in `CLAUDE.md`.
