{ config, pkgs, username, homeDir, ... }:

let
  uid = toString config.users.users.${username}.uid;
  common = {
    user = username;
    environmentFile = "${homeDir}/.config/restic/env";
  };
  # Networks the phone hotspot may back up through: AS7922 is Comcast (the
  # phone on home Wi-Fi), AS15169 is Google (the phone's Wi-Fi routed through
  # Google Fi). The phone's cell network, T-Mobile (AS21928), is left out.
  notUsingCellData = "${pkgs.writeShellApplication {
    name = "not-using-cell-data";
    runtimeInputs = [ pkgs.systemd pkgs.dig ];
    text = builtins.readFile ./not-using-cell-data.sh;
  }}/bin/not-using-cell-data 7922 15169";
  # Touched after each successful backup, by the timer and by `backup`.
  lastSuccess = "${homeDir}/.local/state/backup-last-success";
  # Route a notice into the desktop session's DBus so mako shows it.
  # If the user isn't logged in graphically, /run/user/${uid}/bus is absent and
  # notify-send fails silently — the journal still records the cause.
  notifier = {
    Type = "oneshot";
    User = username;
    Environment = "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/${uid}/bus";
  };
in
{
  # Back up hourly, so a new file has a single copy for an hour at most.
  services.restic.backups.gcs = common // {
    paths = [ "${homeDir}/files" ];
    extraBackupArgs = [
      "--exclude-file=${homeDir}/.config/restic/excludes.txt"
      "--retry-lock=1h"
    ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
      RandomizedDelaySec = "5min";
    };
  };

  # Prune reads pack data back from the bucket, so it runs daily, not hourly.
  services.restic.backups.gcs-prune = common // {
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "30min";
    };
    # The hourly backup and the prune wait for each other's repo lock.
    pruneOpts = [
      "--retry-lock=1h"
      "--keep-daily 7"
      "--keep-weekly 5"
      "--keep-monthly 12"
      "--keep-yearly 5"
    ];
  };

  systemd.services.restic-backups-gcs.serviceConfig.ExecStartPost =
    "${pkgs.coreutils}/bin/touch ${lastSuccess}";

  # Cell data is too scarce for backups; Wi-Fi catches up on the next run.
  systemd.services.restic-backups-gcs.serviceConfig.ExecCondition = notUsingCellData;
  systemd.services.restic-backups-gcs-prune.serviceConfig.ExecCondition = notUsingCellData;

  # Fire backup-failed@<unit> if either unit ever transitions to failed.
  systemd.services.restic-backups-gcs.unitConfig.OnFailure = [ "backup-failed@%n.service" ];
  systemd.services.restic-backups-gcs-prune.unitConfig.OnFailure = [ "backup-failed@%n.service" ];

  # The notice shows the failed run's last log lines as the reason.
  systemd.services."backup-failed@" = {
    description = "Desktop notification for failed backup %i";
    serviceConfig = notifier // {
      ExecStart = "${pkgs.writeShellScript "backup-failed" ''
        id=$(${pkgs.systemd}/bin/systemctl show -p InvocationID --value "$1")
        ${pkgs.libnotify}/bin/notify-send -u critical "Backup failed: $1" \
          "$(${pkgs.systemd}/bin/journalctl _SYSTEMD_INVOCATION_ID="$id" -n 3 -o cat)"
      ''} %i";
    };
  };

  # Skipped runs are silent, so warn once a day, in a notice that stays until
  # dismissed, if no backup has succeeded in 24 hours.
  systemd.services.backup-stale = {
    description = "Desktop notification for a stale backup";
    serviceConfig = notifier // {
      ExecStart = pkgs.writeShellScript "backup-stale" ''
        if [ -e ${lastSuccess} ]; then
          last=$(${pkgs.coreutils}/bin/stat -c %Y ${lastSuccess})
          [ $(( $(${pkgs.coreutils}/bin/date +%s) - last )) -lt 86400 ] && exit 0
          since="since $(${pkgs.coreutils}/bin/date -d @"$last" '+%b %-d %H:%M')"
        else
          since="recorded"
        fi
        ${pkgs.libnotify}/bin/notify-send -u critical -t 0 "Backup stale" \
          "No successful backup $since. Run backup."
      '';
    };
  };
  systemd.timers.backup-stale = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "12:00";
      Persistent = true;
    };
  };

  # Let the user start the backup unit without sudo, so `backup` is one keystroke.
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.systemd1.manage-units" &&
          action.lookup("unit") == "restic-backups-gcs.service" &&
          subject.user == "${username}") {
        return polkit.Result.YES;
      }
    });
  '';
}
