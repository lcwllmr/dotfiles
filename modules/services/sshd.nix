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
        PermitRootLogin = "yes";
        PasswordAuthentication = false;
      };
    };

    # authorize all public keys from this repo
    users.users =
      let
        publicKeyPath = ../../misc/ssh-public-keys;
        publicKeyFilesAttrset = builtins.readDir publicKeyPath;
        publicKeyFilesnames = attrNames publicKeyFilesAttrset;
        publicKeyFiles = map (fn: publicKeyPath + ("/" + fn)) publicKeyFilesnames;
        publicKeys = map readFile publicKeyFiles;
      in
      {
        ${config.machine.core.user}.openssh.authorizedKeys.keys = publicKeys;
        root.openssh.authorizedKeys.keys = publicKeys;
      };
  };
}
