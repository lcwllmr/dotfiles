{ lib, config, ... }:
with lib;
{
  config = mkIf config.desktop.i3 {
    home-manager.users.${config.core.user} = {
      programs.alacritty = {
        enable = true;
        settings = {
          terminal.shell = "fish";
        };
      };
    };
  };
}
