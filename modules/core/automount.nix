{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
{
  options.core = {
    autoMountDrives = mkEnableOption "Mount removable drives automatically to /media";
  };

  config = mkIf config.core.autoMountDrives {

    # launch udisks2 but mount to /media instead of /run/user/*/media
    # NOTE: on multi-user systems you probably don't want to do that
    services.udisks2.enable = true;
    services.udisks2.mountOnMedia = true;

    # user owns the /media directory
    systemd.tmpfiles.rules = [
      "d /media 0755 ${config.core.user} wheel -"
    ];

    # launch udiskie as a systemd user-level service
    systemd.user.services.udiskie = {
      enable = true;
      description = "Auto-mount removable drives etc. to /media";
      # NOTE: multi-user.target doesn't exist for user-level services
      wantedBy = [ "default.target" ]; 
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.udiskie}/bin/udiskie --no-notify"; };
    };

  };
}
