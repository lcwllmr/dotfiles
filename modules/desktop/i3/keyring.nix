{ lib, config, ... }:
with lib;
{
  config = mkIf config.desktop.i3 {

    services.gnome.gnome-keyring.enable = true;

    core.impermanence = mkIf config.core.impermanence.enable {
      userDirs = [ ".local/share/keyrings" ];
    };

  };
}
