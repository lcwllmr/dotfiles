{ pkgs, lib, config, ... }:
with lib;
{
  options.shell.rclone = {
    enable = mkEnableOption "Enable rclone and various cloud syncing utilities";
    remoteName = mkOption {
      type = types.str;
      description = "Name of the remote as configured by 'rclone config' in rclone.conf";
    };
    syncDrives = mkOption {
      description = "List of local-cloud path mappings";
      default = [];
      type = with types; listOf (submodule {
        options = {
          name = mkOption { type = str; description = "Local identifier for reference in scripts"; };
          localPath = mkOption { type = str; };
          cloudPath = mkOption { type = str; };
        };
      });
    };
  };

  config = mkIf config.shell.rclone.enable {
    environment.systemPackages = [ pkgs.rclone ];
    core.impermanence.userDirs = [ ".config/rclone" ];

    home-manager.users.${config.core.user} = {
      home.packages = [
        (pkgs.writeScriptBin "cloudsync" (
          let
            remoteName = config.shell.rclone.remoteName;
            drives = config.shell.rclone.syncDrives;
            driveNames = map (getAttr "name") drives;
            driveNamesString = lib.strings.concatStringsSep " " driveNames;
            makeDriveCase = driveConfig: ''
              case ${driveConfig.name}
                set localPath "${driveConfig.localPath}"
                set cloudPath "${remoteName}:${driveConfig.cloudPath}"
            '';
            driveCases = map makeDriveCase drives;
            driveCasesString = lib.strings.concatLines driveCases;
          in ''
            #!/usr/bin/env fish

            set modes up down
            set modearg 'm/mode=!contains $_flag_value $modes'

            set drives ${driveNamesString}
            set drivearg 'd/drive=!contains $_flag_value $drives'

            argparse --name=cloudsync $modearg $drivearg -- $argv


            if not set -q _flag_mode
              echo "Expected flag -m/--mode with one the following values: $modes"
              return
            end

            if not set -q _flag_drive
              echo "Expected flag -d/--drive with one the following values: $drives"
              return
            end


            switch $_flag_drive
              ${driveCasesString}
              case '*'
                # sanity check
                echo "error: unknown drive $_flag_drive"
                return
            end

            switch $_flag_mode
              case up
                set src $localPath
                set dst $cloudPath
              case down
                set src $cloudPath
                set dst $localPath
              case '*'
                # sanity check
                echo "error: unknown mode $_flag_mode"
                return
            end

            echo Starting sync
            echo "Source: $src"
            echo "Destination: $dst"
            ${pkgs.rclone}/bin/rclone sync -P --metadata $src $dst
          '')
        )
      ];
    };
  };
}
