{ lib, config, ... }:
with lib;
{
  config = mkIf config.desktop.i3 {
    services.picom = {
      enable = true;
      backend = "glx";

      # helps with getting rid of tearing in Firefox on my old vertical monitor
      vSync = true;

      activeOpacity = 1.0;
      inactiveOpacity = 0.8;

      opacityRules = [
        "100:class_g = 'i3lock'" # Important: screen contents revealed otherwise
      ];
    };

    home-manager.users.${config.core.user} = {
      xsession.windowManager.i3 = {
        config.startup = [
          # BUG: see https://github.com/nix-community/home-manager/issues/1217
          { command = "systemctl --user restart picom.service"; notification = false; } 
        ];
      };
    };
  };
}
