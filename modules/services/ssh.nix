{
  lib,
  config,
  ...
}:
with lib;
{
  options.constructor.services = {
    ssh = mkEnableOption "Set up key-only SSH server";
  };

  config = mkIf config.constructor.services.ssh {
    services.openssh = {
      enable = true;

      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        AllowUsers = [ "lcwllmr" ];
      };
    };

    # authorize all public keys from this repo
    users.users.lcwllmr.openssh.authorizedKeys = {
      keys =
        let
          publicKeyPath = ../../misc/ssh-public-keys;
          publicKeyFilesAttrset = builtins.readDir publicKeyPath;
          publicKeyFilesnames = attrNames publicKeyFilesAttrset;
          publicKeyFiles = map (fn: publicKeyPath + ("/" + fn)) publicKeyFilesnames;
        in
        map readFile publicKeyFiles;
    };
  };
}
