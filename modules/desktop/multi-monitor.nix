{ config, lib, pkgs, ... }:
with lib;
{
  options.desktop = {
    multipleDisplays = mkEnableOption "Set up for multi-monitor usage";
  };

  config = mkIf config.desktop.multipleDisplays {

    environment.systemPackages = with pkgs; [
      arandr
    ];

    core.impermanence = mkIf config.core.impermanence.enable {
      userDirs = [
        ".screenlayout"
      ];
    };

    home-manager.users.${config.core.user} = {
      home.packages = [
        (pkgs.writeScriptBin "try-default-monitor-layout" ''
          #!/usr/bin/env fish

          if test -f /home/${config.core.user}/.screenlayout/default.sh
            bash ~/.screenlayout/default.sh
          end
        '')
      ];

      xsession.windowManager.i3.config.startup = [
        {
          command = "try-default-monitor-layout";
          notification = false;
        }
      ];
    };

  };
}
