{
  inputs,
  ...
}:
inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    (
      { modulesPath, lib, ... }:
      with lib;
      {
        imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];
        networking.hostName = mkForce "endor";
        services.getty.autologinUser = mkForce "root";
        users.users.root.openssh.authorizedKeys.keys =
          let
            publicKeyPath = ../misc/ssh-public-keys;
            publicKeyFilesAttrset = builtins.readDir publicKeyPath;
            publicKeyFilesnames = attrNames publicKeyFilesAttrset;
            publicKeyFiles = map (fn: publicKeyPath + ("/" + fn)) publicKeyFilesnames;
            publicKeys = map readFile publicKeyFiles;
          in
          publicKeys;
      }
    )
  ];
}
