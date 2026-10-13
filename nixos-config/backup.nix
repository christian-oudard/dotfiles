{ config, pkgs, username, homeDir, ... }:

let
  uid = toString config.users.users.${username}.uid;
  common = {
    user = username;
    environmentFile = "${homeDir}/.config/restic/env";
  };
  # Exit 1 skips the run; exit 255 fails it, so a missing NetworkManager is loud.
  unmetered = pkgs.writeShellScript "unmetered" ''
    metered=$(${pkgs.systemd}/bin/busctl get-property org.freedesktop.NetworkManager \
      /org/freedesktop/NetworkManager org.freedesktop.NetworkManager Metered) || exit 255
    # NMMetered: 1 = yes, 3 = guess-yes.
    case $metered in "u 1" | "u 3") exit 1 ;; esac
  '';
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

  # Cell data is too scarce for backups; Wi-Fi catches up on the next run.
  systemd.services.restic-backups-gcs.serviceConfig.ExecCondition = unmetered;
  systemd.services.restic-backups-gcs-prune.serviceConfig.ExecCondition = unmetered;

  # Fire backup-failed.service if either unit ever transitions to failed.
  systemd.services.restic-backups-gcs.unitConfig.OnFailure = [ "backup-failed.service" ];
  systemd.services.restic-backups-gcs-prune.unitConfig.OnFailure = [ "backup-failed.service" ];

  # Route the failure into the desktop session's DBus so mako shows it.
  # If the user isn't logged in graphically, /run/user/${uid}/bus is absent and
  # notify-send fails silently — the journal still records the original failure.
  systemd.services.backup-failed = {
    description = "Desktop notification for failed backup";
    serviceConfig = {
      Type = "oneshot";
      User = username;
      Environment = "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/${uid}/bus";
      ExecStart = "${pkgs.libnotify}/bin/notify-send -u critical 'Backup failed' 'A restic-backups-gcs unit did not complete. journalctl -u restic-backups-gcs*'";
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
