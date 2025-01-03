{ inputs, config, ... }:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  config = {
    sops = {
      defaultSopsFile = ../../misc/secrets.yaml;

      # TODO: must point to /persist on impermanent systems
      age.keyFile = "/var/lib/sops-nix/key.txt";

      secrets.hashedUserPassword.neededForUsers = true;
    };
  };
}
