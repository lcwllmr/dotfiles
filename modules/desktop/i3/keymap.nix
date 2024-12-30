{ pkgs, ... }:
{
  # from https://nixos.wiki/wiki/Keyboard_Layout_Customization#Using_xmodmap
  config = {
    services.xserver.xkb.layout = "us";
    services.xserver.displayManager.sessionCommands =
      let
        germanUmlauts = ''
          ! Map umlauts to RIGHT ALT + <key>
          keycode 108 = Mode_switch
          keysym e = e E EuroSign
          keysym a = a A adiaeresis Adiaeresis
          keysym o = o O odiaeresis Odiaeresis
          keysym u = u U udiaeresis Udiaeresis
          keysym s = s S ssharp

          ! disable capslock
          ! remove Lock = Caps_Lock
        '';
        germanUmlautsFile = pkgs.writeText "xkb-custom-layout" germanUmlauts;
      in
      ''
        ${pkgs.xorg.xmodmap}/bin/xmodmap "${germanUmlautsFile}"
      '';
  };
}
