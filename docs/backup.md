# Backup

`~/files` is backed up to Google Cloud (`gs:cwo-restic:/`) every hour, so a new file has a single copy for an hour at most. Runs are skipped on cell data. On a connection NetworkManager reports as metered (or guesses is metered), such as a phone hotspot, a run goes ahead only if the public IP belongs to an allowed wired network: Comcast or Google (the phone's Wi-Fi through Google Fi). Anything else, including the T-Mobile cell network or a failed lookup, skips the run. The next allowed run catches up.

Once a day, old snapshots are pruned, under the same network rule. Restic keeps the last 7 daily, 5 weekly, 12 monthly, and 5 yearly snapshots.

If a run fails, a desktop notification names the failed unit and shows its last log lines. Skipped runs do not notify. Instead, if no backup to Google Cloud has succeeded in 24 hours, a red notice appears once a day at noon and stays until dismissed. Both the hourly runs and the `backup` function count as successes.

The `backup` zsh function backs up on demand, on any connection. It writes to the USB repo (`/mnt/usb/restic-repo`) first if the drive is mounted, then to Google Cloud.

The trash is not backed up (see `trash.md`).
