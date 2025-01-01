{
  inputs,
  globals,
  ...
}:
inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    (
      { pkgs, ... }:
      {
        # this switches on enableRedistributableFirmware which in turn enables amd microcodes through nixos-hardware
        nixpkgs.config.allowUnfree = true;
        hardware.enableAllFirmware = true;

        boot.loader.grub.enable = true;
        boot.loader.grub.device = "nodev";
        boot.loader.grub.efiSupport = true;
        boot.loader.grub.efiInstallAsRemovable = true;

        # TPM2 setup
        # https://discourse.nixos.org/t/full-disk-encryption-tpm2/29454/2
        boot.initrd.systemd.enable = true;
        environment.systemPackages = [ pkgs.tpm2-tss ];

        boot.initrd.availableKernelModules = [
          "ehci_pci"
          "nvme"
          "xhci_pci"
          "ahci"
          "usbhid"
          "usb_storage"
          "sd_mod"
          "sr_mod"
        ];
        boot.initrd.kernelModules = [ ];
        boot.kernelModules = [ "kvm-amd" ];
        boot.extraModulePackages = [ ];

        time.timeZone = "Europe/Berlin";
        i18n.defaultLocale = "en_US.UTF-8";

        networking.hostName = "cloud";
        networking.interfaces.enp1s0f0.useDHCP = true;
        networking.enableIPv6 = true;
        networking.nameservers = [ "1.1.1.1" ];

        users.users.root.hashedPassword = "$y$j9T$5U3e8OIGQBqUg0kKEoScJ0$9R6aGDgyJ7CQmUKsXMxdKg.FgHlno.fFTtolDvYB6J8";
        users.users.lcwllmr = {
          isNormalUser = true;
          extraGroups = [ "wheel" ];
          hashedPassword = "$y$j9T$5U3e8OIGQBqUg0kKEoScJ0$9R6aGDgyJ7CQmUKsXMxdKg.FgHlno.fFTtolDvYB6J8";
        };

        services.openssh = {
          enable = true;
          settings.PermitRootLogin = "yes";
        };

        services.tailscale.enable = true;

        nixpkgs.hostPlatform = "x86_64-linux";
        nix = {
          # populate nix path to avoid warning with nix-shell etc.
          nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

          settings = {
            trusted-users = [ "@wheel" ]; # needed for nixos-rebuild from remote machine
            experimental-features = [
              "nix-command"
              "flakes"
            ];
          };
        };
        system.stateVersion = "24.11";
      }
    )
    inputs.disko.nixosModules.disko
    {
      disko.devices = {
        disk = {
          main = {
            type = "disk";
            device = "/dev/nvme0n1";
            content = {
              type = "gpt";
              partitions = {
                ESP = {
                  size = "512M";
                  type = "EF00";
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                    mountOptions = [ "umask=0077" ];
                  };
                };
                luks = {
                  size = "100%";
                  content = {
                    type = "luks";
                    name = "cryptmain";
                    extraOpenArgs = [
                      "--allow-discards"
                      "--perf-no_read_workqueue"
                      "--perf-no_write_workqueue"
                    ];
                    content = {
                      type = "btrfs";
                      extraArgs = [ "-f" ];
                      subvolumes = {
                        "/root" = {
                          mountpoint = "/";
                          mountOptions = [
                            "subvol=root"
                            "compress=zstd"
                            "noatime"
                          ];
                        };
                        "/swap" = {
                          mountpoint = "/swap";
                          swap.swapfile.size = "8G";
                        };
                      };
                    };
                  };
                };
              };
            };
          };
          storage = {
            type = "disk";
            device = "/dev/sda";
            content = {
              type = "gpt";
              partitions = {
                luks = {
                  size = "100%";
                  content = {
                    type = "luks";
                    name = "cryptstore";
                    extraOpenArgs = [
                      "--allow-discards"
                      "--perf-no_read_workqueue"
                      "--perf-no_write_workqueue"
                    ];
                    content = {
                      type = "btrfs";
                      extraArgs = [ "-f" ];
                      subvolumes = {
                        "/store" = {
                          mountpoint = "/store";
                          mountOptions = [
                            "subvol=store"
                            "compress=zstd"
                            "noatime"
                          ];
                        };
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
    }
  ];
}
