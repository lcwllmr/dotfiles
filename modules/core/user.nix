{ lib, config, ... }:
with lib;
{

  options.core = {
    user = mkOption {
      type = types.str;
      description = "Primary system user";
    };
    passwordHash = mkOption {
      type = types.str;
      description = "User password hashed with mkpasswd";
    };
    homeManager = mkEnableOption "Enable home manager on the system";
  };

  config = {
    users.users.${config.core.user} = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      hashedPassword = config.core.passwordHash;
    };
    home-manager = {
      useUserPackages = true;
      useGlobalPkgs = true;
      users.${config.core.user} = {
        home.username = config.core.user;
        home.homeDirectory = "/home/${config.core.user}";
        programs.home-manager.enable = true;
      };
    };
  };

}
