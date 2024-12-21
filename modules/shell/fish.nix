{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
{
  options.shell = {
    fish = mkEnableOption "Activate fish shell";
  };

  config = mkIf config.shell.fish {

    environment.systemPackages = with pkgs; [
      nnn       # nice CLI file browser
      busybox   # basic unix utilities in single binary
      curl wget # web requests
    ];

    programs.fish.enable = true;

    users.users.${config.core.user}.shell = pkgs.fish;

    home-manager.users.${config.core.user} = {
      # basic config with git-aware prompt and vi mode
      programs.fish = {
        enable = true;
        interactiveShellInit = ''
          set -g fish_greeting

          fish_vi_key_bindings
          bind yy fish_clipboard_copy
          bind Y fish_clipboard_copy
          bind -M visual y fish_clipboard_copy
          bind -M default p fish_clipboard_paste
          set -g fish_vi_force_cursor
          set -g fish_cursor_default block
          set -g fish_cursor_insert line
          set -g fish_cursor_visual block
          set -g fish_cursor_replace_one underscore

          set -g __fish_git_prompt_showdirtystate 1
        '';
        functions = {
          fish_prompt = {
            body = ''
              echo (prompt_pwd --full-length-dirs 1) (fish_git_prompt) '> '
            '';
          };
          fish_mode_prompt.body = "";
          fish_right_prompt.body = "";
        };
      };

      # basic utilities for finding things on the system and in projects
      programs.ripgrep.enable = true;
      programs.fd = {
        enable = true;
        ignores = [ ".git/" ];
      };
      programs.fzf = {
        enable = true;
        enableFishIntegration = true;
        defaultCommand = "fd --type f --hidden --no-require-git";
      };
    };

    core.impermanence = mkIf config.core.impermanence.enable {
      userDirs =  [
        ".local/share/fish" # keep fish history
      ];
    };

    # speed up nixos-rebuilds when using fish
    #     https://discourse.nixos.org/t/slow-build-at-building-man-cache/52365
    documentation.man.generateCaches = false;

  };
}
