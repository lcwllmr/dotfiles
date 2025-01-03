{
  lib,
  config,
  ...
}:
with lib;
{
  options.machine.core = {
    user = mkOption {
      type = types.str;
      description = "Primary user of the machine";
    };
  };

  config = {
    users.users.${config.machine.core.user} = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      hashedPasswordFile = config.sops.secrets.hashedUserPassword.path;
    };
  };
}
