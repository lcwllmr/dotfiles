{ pkgs, lib, config, ... }:
with lib;
{
  options.desktop = {
    zed = mkEnableOption "Enable Zed editor";
  };

  config = mkIf config.desktop.zed {

    # NOTE: zed needs a secret manager for storing login cookies;
    #       see ./i3/keyring.nix
    fonts.packages = with pkgs; [ fira-code fira-code-symbols ];

    home-manager.users.${config.core.user} = {
      programs.zed-editor = {
        enable = true;
        extensions = [
          "nix"
        ];
        userSettings = {
          # see: https://zed.dev/docs/configuring-zed
          restore_on_startup = "none";
          auto_update = false;
          load_direnv = "direct";
          git_status = true;
          format_on_save = "on";
          telemetry = {
            diagnostics = false;
            metrics = false;
          };
          theme = {
            mode = "dark";
            dark = "One Dark";
            light = "One Light";
          };
          vim_mode = true;
          buffer_font_size = 12;
          buffer_font_family = "Fira Code";
          languages = {
            Nix = {
              tab_size = 2;
            };
          };
        };
      };
    };

    core.impermanence = mkIf config.core.impermanence.enable {
      userDirs = [ ".local/share/zed" ];
    };

  };
}
