{
  inputs,
  globals,
  ...
}:
inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    inputs.disko.nixosModules.disko
    inputs.impermanence.nixosModules.impermanence
    inputs.home-manager.nixosModules.home-manager
    inputs.stylix.nixosModules.stylix
    ./hardware.nix
    ./disko.nix
    ../../modules/core
    ../../modules/shell
    ../../modules/desktop
    ../../modules
    ../../modules/core/sops.nix
    {
      sops.secrets.cloud.hashedUserPassword.neededFOr
      # TODO: put this somewhere and forget about it. I can't nicely persist
      #       this file with impermanence so just generate one manually.
      #       see https://www.freedesktop.org/software/systemd/man/latest/machine-id.html
      environment.etc.machine-id = {
        user = "root";
        text = "49254d0ed2a807b6f3936d2d6eb42b22\n";
      };
      core = {
        stateVersion = "24.11";
        user = globals.ghName;
        passwordHash = "$y$j9T$5U3e8OIGQBqUg0kKEoScJ0$9R6aGDgyJ7CQmUKsXMxdKg.FgHlno.fFTtolDvYB6J8";
        homeManager = true;
        impermanence.enable = true;
        networking = {
          hostName = "dpt5810";
          wifi = false;
        };
        audio = true;
        laptop = false;
        autoMountDrives = true;

        tailscale = {
          enable = true;
          isServer = false;
        };

        stylix = {
          enable = true;
          fontSize = 9;
          colorScheme = "google-dark";
        };
      };

      shell = {
        fish = true;
        ssh = true;
        git = {
          enable = true;
          name = globals.ghName;
          email = globals.ghEmail;
        };
        develop = true;
        rclone = {
          enable = true;
          remoteName = "cloud";
          syncDrives = [
            {
              name = "zettelkasten";
              localPath = "~/.local/zettelkasten";
              cloudPath = "/zettelkasten";
            }
          ];
        };
      };

      desktop = {
        i3 = true;
        multipleDisplays = true;
        firefox = true;
        obsidian = true;
      };
    }
  ];
}
