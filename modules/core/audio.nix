{ pkgs, lib, config, ... }:
with lib;
{
  options.core = {
    audio = mkEnableOption "Enable audio using PipeWire";
  };

  config = mkIf config.core.audio {
    environment.systemPackages = with pkgs; [
      wireplumber
      pulsemixer
    ];

    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # preserve audio settings between boots
    core.impermanence = mkIf config.core.impermanence.enable {
      userDirs = [ ".local/state/wireplumber" ];
    };
  };
}
