{ pkgs, lib, config, ... }:
with lib;
{
  options.shell = {
    develop = mkEnableOption "Prepare local development shell tools";
  };

  config = mkIf config.shell.develop {

    # install direnv and devenv
    environment.systemPackages = [ pkgs.devenv ];
    home-manager.users.${config.core.user} = {
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
    };

    # create, own and persist the projects directory
    systemd.tmpfiles.rules = [
      "d /projects 0755 ${config.core.user} wheel -"
    ];
    core.impermanence = mkIf config.core.impermanence.enable {
      systemDirs =  [ "/projects" ];
    };

  };
}
