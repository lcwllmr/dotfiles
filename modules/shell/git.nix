{
  lib, config, ...
}:
with lib;
let
  cfg = config.shell.git;
in {
  options.shell.git = {
    enable = mkEnableOption "Enable git";
    name = mkOption {
      type = types.str;
      description = "Git commit name";
    };
    email = mkOption {
      type = types.str;
      description = "Git commit email";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.core.user} = {
      programs.git = {
        enable = true;
        userName = cfg.name;
        userEmail = cfg.email;
        extraConfig = {
          init.defaultBranch = "main";
        };
      };
    };
  };
}
