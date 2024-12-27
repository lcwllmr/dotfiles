{ pkgs, lib, config, ... }:
with lib;
{
  options.core.tailscale = {
    enable = mkEnableOption "Set up for use in tailnet";
    isServer = mkOption { type = types.bool; description = "Machine acts as a server"; };
  };

  config = mkIf config.core.tailscale.enable {
    environment.systemPackages = with pkgs; [ tailscale ];
    services.tailscale.enable = true;

    # TODO: configure for server usage, too
    #   here is a good starting point: https://tailscale.com/kb/1096/nixos-minecraft

    core.impermanence.systemDirs = [
      "/var/cache/tailscale"
      "/var/lib/tailscale"
    ];
  };
}
