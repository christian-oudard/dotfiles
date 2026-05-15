{ config, pkgs, username, homeDir, ... }:

let
  uid = toString config.users.users.${username}.uid;
in
{
  services.restic.backups.gcs = {
    user = username;
    environmentFile = "${homeDir}/.config/restic/env";
    paths = [ "${homeDir}/files" ];
    extraBackupArgs = [
      "--exclude-file=${homeDir}/.config/restic/excludes.txt"
    ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "30min";
    };
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 5"
      "--keep-monthly 12"
      "--keep-yearly 5"
    ];
  };

  # Fire backup-failed.service if restic-backups-gcs ever transitions to failed.
  systemd.services.restic-backups-gcs.unitConfig.OnFailure = [ "backup-failed.service" ];

  # Route the failure into the desktop session's DBus so mako shows it.
  # If the user isn't logged in graphically, /run/user/${uid}/bus is absent and
  # notify-send fails silently — the journal still records the original failure.
  systemd.services.backup-failed = {
    description = "Desktop notification for failed backup";
    serviceConfig = {
      Type = "oneshot";
      User = username;
      Environment = "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/${uid}/bus";
      ExecStart = "${pkgs.libnotify}/bin/notify-send -u critical 'Backup failed' 'restic-backups-gcs.service did not complete. journalctl -u restic-backups-gcs.service'";
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
