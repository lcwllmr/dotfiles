{ pkgs, lib, config, ... }:
with lib;
{
  config = mkIf config.desktop.i3 (
  let
    lockCmd = "${pkgs.i3lock}/bin/i3lock --color 000000";
  in {
    environment.systemPackages = [ pkgs.i3lock ];

    # give user rights for running suspend, reboot and poweroff without password
    security.sudo = {
      enable = true;
      extraRules = [{
        commands = [
          {
            command = "/run/current-system/sw/bin/systemctl suspend";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/reboot";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/poweroff";
            options = [ "NOPASSWD" ];
          }
        ];
        users = [ config.core.user ];
      }];
    };

    # lock screen before going to sleep
    systemd.services."lock-before-suspend@${config.core.user}" = {
      enable = true;
      description = "Lock screen before suspending";
      before = [ "sleep.target" "suspend.target" ];
      wantedBy = [ "sleep.target" "suspend.target" ];
      environment = {
        DISPLAY = ":0"; # not sure if this is necessary
      };
      serviceConfig = {
        User = "%I";

          # This is important:
          # Apparently i3lock itself is not detectable after startup,
          # but some sub-process instead. Hence "simple" or "exec" will 
          # kill the lock right after launch.
        Type = "forking"; 
        ExecStart = lockCmd;
      };
    };

    # dmenu session exit script
    home-manager.users.${config.core.user} = {

      home.packages = [(
        pkgs.writeScriptBin "dmenu-session-exit" ''
          #!/usr/bin/env bash

          declare -A commands=(
            ["Lock screen"]="${lockCmd}"
            ["Suspend"]="sudo systemctl suspend"
            ["Reboot"]="sudo reboot"
            ["Power off"]="sudo poweroff"
          )

          choices=$(printf "%s\n" "''${!commands[@]}")
          selection=$(echo "$choices" | dmenu -i)

          if [[ -n "$selection" && -n "''${commands[$selection]}" ]]; then
            eval "''${commands[$selection]}"
          fi
        ''
      )];

    };
  });
}
