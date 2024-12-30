{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
{
  options.desktop = {
    i3 = mkEnableOption "Enable my custom i3 desktop environment";
  };

  imports = [
    ./keymap.nix
    ./polybar.nix
    ./picom.nix
    ./session.nix
    ./xdg.nix
    ./keyring.nix
    ./alacritty.nix
  ];

  config = mkIf config.desktop.i3 {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
    services.libinput.enable = true;

    environment.systemPackages = [
      pkgs.dmenu
      pkgs.xclip
    ];

    services.xserver = {
      enable = true;
      windowManager.i3 = {
        enable = true;
      };
      displayManager = {
        lightdm.enable = true;
      };
    };

    services.displayManager = {
      defaultSession = "none+i3";

      # rely on disk encryption password for the first security stage at boot
      autoLogin = {
        enable = true;
        user = config.core.user;
      };
    };

    home-manager.users.${config.core.user} = {

      xsession.windowManager.i3 = {
        enable = true;

        config = rec {
          # disable i3bar in favor of polybar
          bars = [ { command = "echo"; } ];

          gaps = {
            inner = 6;
            smartGaps = true;
          };

          window = {
            titlebar = false;
            border = 0;
          };

          defaultWorkspace = "workspace number 1";

          menu = "dmenu_run";
          terminal = "alacritty";

          # Hard-code all keybindings instead of using mkDefault.
          # Gives me an exhaustive overview and no hidden features.
          # See the defaults here: https://github.com/nix-community/home-manager/blob/master/modules/services/window-managers/i3-sway/i3.nix

          #modifier = "Mod1"; # alt
          modifier = "Mod4"; # super

          keybindings = {
            "${modifier}+Return" = "exec --no-startup-id ${terminal}";
            "${modifier}+d" = "exec --no-startup-id ${menu}";
            "${modifier}+b" = "exec --no-startup-id firefox";
            "${modifier}+Shift+e" = "exec --no-startup-id dmenu-session-exit"; # see ./session.nix
            "${modifier}+Shift+q" = "kill";

            "${modifier}+h" = "focus left";
            "${modifier}+j" = "focus down";
            "${modifier}+k" = "focus up";
            "${modifier}+l" = "focus right";

            "${modifier}+Shift+h" = "move left";
            "${modifier}+Shift+j" = "move down";
            "${modifier}+Shift+k" = "move up";
            "${modifier}+Shift+l" = "move right";

            "${modifier}+Ctrl+Shift+h" = "move container to output left";
            "${modifier}+Ctrl+Shift+j" = "move container to output down";
            "${modifier}+Ctrl+Shift+k" = "move container to output up";
            "${modifier}+Ctrl+Shift+l" = "move container to output right";

            "${modifier}+i" = "split h"; # avoid collision with vim key h
            "${modifier}+v" = "split v";
            "${modifier}+f" = "fullscreen toggle";

            "${modifier}+s" = "layout stacking";
            "${modifier}+w" = "layout tabbed";
            "${modifier}+e" = "layout toggle split";

            "${modifier}+Shift+space" = "floating toggle";
            "${modifier}+space" = "focus mode_toggle";

            "${modifier}+a" = "focus parent";

            "${modifier}+Shift+minus" = "move scratchpad";
            "${modifier}+minus" = "scratchpad show";

            "${modifier}+1" = "workspace number 1";
            "${modifier}+2" = "workspace number 2";
            "${modifier}+3" = "workspace number 3";
            "${modifier}+4" = "workspace number 4";
            "${modifier}+5" = "workspace number 5";
            "${modifier}+6" = "workspace number 6";
            "${modifier}+7" = "workspace number 7";
            "${modifier}+8" = "workspace number 8";
            "${modifier}+9" = "workspace number 9";
            "${modifier}+0" = "workspace number 10";

            "${modifier}+Shift+1" = "move container to workspace number 1";
            "${modifier}+Shift+2" = "move container to workspace number 2";
            "${modifier}+Shift+3" = "move container to workspace number 3";
            "${modifier}+Shift+4" = "move container to workspace number 4";
            "${modifier}+Shift+5" = "move container to workspace number 5";
            "${modifier}+Shift+6" = "move container to workspace number 6";
            "${modifier}+Shift+7" = "move container to workspace number 7";
            "${modifier}+Shift+8" = "move container to workspace number 8";
            "${modifier}+Shift+9" = "move container to workspace number 9";
            "${modifier}+Shift+0" = "move container to workspace number 10";

            "${modifier}+Shift+c" = "reload";
            "${modifier}+Shift+r" = "restart";

            "${modifier}+r" = "mode resize";
          };

          modes = {
            resize = {
              "h" = "resize shrink width 10 px or 10 ppt";
              "k" = "resize shrink height 10 px or 10 ppt";
              "j" = "resize grow height 10 px or 10 ppt";
              "l" = "resize grow width 10 px or 10 ppt";
              "Escape" = "mode default";
            };
          };
        };
      };
    };
  };
}
