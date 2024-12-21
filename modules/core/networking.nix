{ lib, config, ... }:
with lib;
{
  options.core.networking = {
    hostName = mkOption {
      type = types.str;
      description = "System host name";
    };

    wifi = mkEnableOption "Enable Wifi";
  };

  config = let
    n = config.core.networking;
  in {
    networking.hostName = n.hostName;

    # enable DHCP on all interfaces
    networking.useDHCP = mkDefault true;

    networking.enableIPv6 = true;

    # use Cloudflare DNS
    networking.nameservers = [ "1.1.1.1" ];

    # systemd-networkd not needed since I use NetworkManager (plus it can cause some freezes on rebuild when waiting for wait-online.target I think)
    systemd.network.enable = mkForce false;

    # enable NetworkManager and give system user privileges
    networking.networkmanager.enable = true;
    users.users.${config.core.user}.extraGroups = [ "networkmanager" ];

    # use iwd as backend for Wifi connections
    networking.networkmanager.wifi.backend = mkIf n.wifi "iwd";
    networking.wireless.iwd = mkIf n.wifi {
      enable = true;
      settings = {
        IPv6 = {
          Enabled = true;
        };
        Settings = {
          AutoConnect = true;
        };
      };
    };

    # make sure not to lose state on reboot (e.g. Wifi connections)
    core.impermanence.systemDirs = mkIf config.core.impermanence.enable (
      [ "/etc/NetworkManager" "/var/lib/NetworkManager" ] 
        ++ (if n.wifi then [ "/var/lib/iwd" ] else [])
    );
  };
}
