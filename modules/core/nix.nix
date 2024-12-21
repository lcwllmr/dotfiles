{ lib, config, ... }:
with lib;
let
  c = config.core;
in {
  options.core = {
    stateVersion = mkOption {
      type = types.str;
      description = "State version for both NixOS and Home Manager";
    };
  };

  config = {
    system.stateVersion = c.stateVersion;
    home-manager.users.${c.user}.home.stateVersion
      = mkIf c.homeManager c.stateVersion;

    nix.settings = {
      experimental-features = [
        "nix-command" "flakes"
      ];

      # NOTE: needed by devenv.sh but figured I can just put it here
      trusted-users = [ "@wheel" ];
    };
  };
}
