{
  lib,
  config,
  ...
}:
with lib;
{
  options.machine.services = {
    sshd = mkEnableOption "Set up key-only SSH server";
  };

  config = mkIf config.machine.services.sshd {
    services.openssh = {
      enable = true;

      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
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
