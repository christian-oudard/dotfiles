# Backup

`~/files` is backed up to Google Cloud (`gs:cwo-restic:/`) every hour, so a new file has a single copy for an hour at most. Runs are skipped while NetworkManager reports a metered connection, such as a phone hotspot. The next run on an unmetered connection catches up.

Once a day, old snapshots are pruned. Restic keeps the last 7 daily, 5 weekly, 12 monthly, and 5 yearly snapshots.

If a run fails, a desktop notification appears.

The `backup` zsh function backs up on demand, on any connection. It writes to the USB repo (`/mnt/usb/restic-repo`) first if the drive is mounted, then to Google Cloud.

The trash is not backed up (see `trash.md`).
