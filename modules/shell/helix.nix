{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
{
  options.shell = {
    helix = mkEnableOption "Enable Helix text editor";
  };

  config = mkIf config.shell.helix {
    home-manager.users.${config.core.user} = {
      # https://home-manager-options.extranix.com/?query=programs.helix&release=master
      programs.helix = {
        enable = true;
        defaultEditor = true;
        settings = {
          editor = {
            line-number = "relative";
          };
        };
        languages = {
          language = [
            {
              name = "nix";
              auto-format = true;
              formatter.command = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
            }
          ];
        };
      };
    };
  };
}
