{
  inputs,
  globals,
  ...
}:
inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    ../modules/services
    ../modules/core/user.nix
    ../modules/core/sops.nix
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

          # manual
          "r8169" # output of lshw -C network; needed for dropbear
        ];
        boot.initrd.kernelModules = [ ];
        boot.kernelModules = [ "kvm-amd" ];
        boot.extraModulePackages = [ ];

        boot.initrd.network = {
          enable = true;
          ssh = {
            enable = true;
            port = 2222;
            hostKeys = [
              "/boot/dropbear_ed25519_host_key"
            ];
            authorizedKeys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIy3L442S1wAPtaa92tw+XYx0G2VXj+XjtbxCZ5+xE21"
            ];
          };
          postCommands = ''
            echo 'cryptsetup-askpass' >> /root/.profile
          '';
        };

        time.timeZone = "Europe/Berlin";
        i18n.defaultLocale = "en_US.UTF-8";

        networking.hostName = "cloud";
        networking.useDHCP = true;
        networking.enableIPv6 = true;
        networking.nameservers = [ "1.1.1.1" ];

        machine = {
          core = {
            user = globals.ghName;
          };
          services = {
            sshd = true;
          };
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
