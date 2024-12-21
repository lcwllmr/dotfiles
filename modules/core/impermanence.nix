# NOTE: Using this modules assumes a few things:
#   - the file system is BTRFS
#   - the persistent subvolume is mounted as "/persist"
#   - /root is a subvolume that is mounted as "/"
#   - the whole disk can be addressed as /dev/mapper/crypted

# Some resources:
#   - https://github.com/nix-community/impermanence
#   - https://guekka.github.io/nixos-server-1/

{ lib, config, ... }:
with lib;
let
  cfg = config.core.impermanence;
in {

  options.core.impermanence = with types; {
    enable = mkEnableOption "Enable impermanence in the system";
    systemDirs = mkOption {
      type = listOf anything;
      default = [];
      description = "List of system directories to persist between boots";
    };
    systemFiles = mkOption {
      type = listOf anything;
      default = [];
      description = "List of system files to persist between boots";
    };
    userDirs = mkOption {
      type = listOf anything;
      default = [];
      description = "List of directories under home directory to persist between boots";
    };
    userFiles = mkOption {
      type = listOf anything;
      default = [];
      description = "List of files under home directory to persist between boots";
    };
  };

  config = mkIf cfg.enable {

    fileSystems."/persist".neededForBoot = true;

    environment.persistence."/persist" = {
      enable = true; # should be the default anyway according to docs
      hideMounts = true;
      directories = cfg.systemDirs ++ [
        "/var/log" # keep logs around for debugging
        "/var/lib/nixos" # contains declarative user and group info
      ];
      files = cfg.systemFiles;
      users.${config.core.user} = {
        directories = cfg.userDirs;
        files = cfg.userFiles;
      };
    };

    # previous roots are baked up under "old_roots" and will be deleted after 30 days
    boot.initrd.postDeviceCommands = lib.mkAfter ''
      mkdir /btrfs_tmp
      mount /dev/mapper/crypted /btrfs_tmp
      if [[ -e /btrfs_tmp/root ]]; then
          mkdir -p /btrfs_tmp/old_roots
          timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
          mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
      fi

      delete_subvolume_recursively() {
          IFS=$'\n'
          for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
              delete_subvolume_recursively "/btrfs_tmp/$i"
          done
          btrfs subvolume delete "$1"
      }

      for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
          delete_subvolume_recursively "$i"
      done

      btrfs subvolume create /btrfs_tmp/root
      umount /btrfs_tmp
    '';

    # disable stupid sudo warning after each reboot
    security.sudo.extraConfig = ''
      Defaults lecture = never
    '';

  };

}
