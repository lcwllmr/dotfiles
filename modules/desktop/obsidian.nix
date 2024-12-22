{ pkgs, lib, config, ... }:
with lib;
{
  options.desktop = {
    obsidian = mkEnableOption "Enable Obsidian zettelkasten";
  };

  config = mkIf config.desktop.obsidian {

    # Obsidian is unfree so allow it
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [ "obsidian" ];

    environment.systemPackages = [ pkgs.obsidian ];

    # create and own the zettelkasten directory
    systemd.tmpfiles.rules = [
      "d /home/${config.core.user}/.local/zettelkasten 0755 ${config.core.user} wheel -"
    ];

    # persist vault, Obsidian cache etc. between boots
    core.impermanence = mkIf config.core.impermanence.enable {
      userDirs = [
        ".local/zettelkasten"

        # NOTE: I believe the .config directory is not the right choice
        #       from the developer's side. It looks more like XDG_DATA_DIR
        #       to me but boh.
        ".config/obsidian"
      ];
    };

  };
}
