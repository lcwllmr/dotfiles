{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
{
  config = {
    assertions = [
      {
        assertion = config.core.homeManager;
        warning = "Helix module needs core.homeManager to be enabled";
      }
    ];

    home-manager.users.${config.core.user} = {
      home.packages = with pkgs; [ nixfmt-rfc-style ];

      # options: https://home-manager-options.extranix.com/?query=programs.helix&release=master
      programs.helix = {
        enable = true;
        defaultEditor = true;
        languages = importTOML ./languages.toml;
        settings = importTOML ./config.toml;
      };
    };
  };
}
