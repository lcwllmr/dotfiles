{ lib, config, ... }:
with lib;
{

  options.core = {
    laptop = mkEnableOption "Enable laptop-specific options";
  };

  config = mkIf config.core.laptop {
    # for energy efficiency
    powerManagement.enable = true;
    services.tlp.enable = true;

    # configure touchpad
    services.libinput = {
      enable = true;
      touchpad = {
        horizontalScrolling = true;
        tapping = true;
        naturalScrolling = true;
        disableWhileTyping = true;
      };
    };
  };

}
