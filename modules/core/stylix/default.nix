{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.core.stylix;
in {

  options.core.stylix = {
    enable = mkEnableOption "Enable centralized theming using Stylix";

    fontSize = mkOption {
      type = types.ints.positive;
      description = "Base font size";
    };

    # choose theme from: https://tinted-theming.github.io/base16-gallery/
    colorScheme = mkOption {
      type = types.str;
      description = "Name of base16 color scheme";
    };
  };

  config = mkIf cfg.enable {
    stylix = {
      enable = true;
      polarity = "dark";
      image = ./black.jpg;

      base16Scheme = "${pkgs.base16-schemes}/share/themes/${cfg.colorScheme}.yaml";

      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Ice";
        size = 20;
      };

      opacity = {
        applications = 1.0;
        terminal = 1.0;
        desktop = 1.0;
        popups = 1.0;
      };

      fonts = {
        sizes = {
          applications = cfg.fontSize;
          terminal = cfg.fontSize;
          desktop = cfg.fontSize;
          popups = cfg.fontSize;
        };
        monospace = {
          package = pkgs.fira-code;
          name = "Fira Code";
        };
        sansSerif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Sans";
        };
        serif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Serif";
        };
      };
    };
  };

}

