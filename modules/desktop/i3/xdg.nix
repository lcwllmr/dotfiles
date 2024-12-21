{ pkgs, lib, config, ... }:
with lib;
{
  config = mkIf config.desktop.i3 {
    home-manager.users.${config.core.user} = 
    let 
      homeDir = "/home/${config.core.user}";
    in {
      xdg = {
        enable = true;
        portal = {
          enable = true;
          extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
          config.common.default = "*";
        };
        userDirs = {
          createDirectories = false;
          desktop = homeDir;
          documents = homeDir;
          download = homeDir;
          music = homeDir;
          pictures = homeDir;
          publicShare = homeDir;
          templates = homeDir;
          videos = homeDir;
        };
      };
    };
  };
}
