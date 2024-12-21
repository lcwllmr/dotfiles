{ pkgs, lib, config, ... }:
with lib;
{
  config = mkIf config.desktop.i3 {
    fonts.packages = with pkgs; [
      fira-code
      fira-code-symbols
    ];

    home-manager.users.${config.core.user} = {
      xsession.windowManager.i3.config.startup = [
        {
          command = "pkill polybar; polybar -r main";
          notification = false;
          always = true;
        }
      ];

      services.polybar = {
        enable = true;
        package = pkgs.polybar.override {
          pulseSupport = true;
          i3Support = true;
        };
        script = "polybar &";
        config = {
          "bar/main" = {
            bottom = true;
            width = "100%";
            height = "16pt";
            separator = "|";
            font-0 = "Fira Code:size=8";
            radius = 0;
            line-size = "1pt";
            padding-left = 2;
            padding-right = 2;
            module-margin = 1;
            modules-left = "i3";
            modules-right = "pulseaudio date";
            cursor-click = "pointer";
            cursor-scroll = "ns-resize";
            enable-ipc = true;
          };

          "module/i3" = {
            type = "internal/i3";
            format = "<label-state> <label-mode>";
            index-sort = true;
            label-focused-underline = "#fba922";
            label-focused-padding = 1;
            enable-click = "false";
            enable-scroll = "false";
          };
          "module/pulseaudio" = {
            type = "internal/pulseaudio";
            use-ui-max = "true";
            interval = "5";
            reverse-scroll = (if config.core.laptop then "true" else "false");
            format-volume = "VOL <label-volume>";
            format-muted = "<label-muted>";
            label-volume = "%percentage%%";
            label-muted = "MUTE";
          };
          "module/date" = {
            type = "internal/date";
            interval = 1;
            date = "%Y-%m-%d %H:%M";
            label = "%date%";
          };
        };
      };
    };
  };
}
