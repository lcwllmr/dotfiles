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

  config.users.users.${config.machine.core.user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPassword = "$y$j9T$5U3e8OIGQBqUg0kKEoScJ0$9R6aGDgyJ7CQmUKsXMxdKg.FgHlno.fFTtolDvYB6J8";
  };
}
