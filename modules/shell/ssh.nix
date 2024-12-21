{ pkgs, lib, config, ... }:
with lib;
{

  options.shell = {
    ssh = mkEnableOption "Enable client-side SSH";
  };

  config = mkIf config.shell.ssh {
    core.impermanence = mkIf config.core.impermanence.enable {
      userDirs = [
        ".ssh"
      ];
    };

    home-manager.users.${config.core.user} =  {
      programs.ssh = {
        enable = true;
        addKeysToAgent = "yes";
      };

      services.ssh-agent.enable = true;

      home.packages = [
        # restore SSH keys from seed phrases
        pkgs.melt
      ];
    };
  };

}
