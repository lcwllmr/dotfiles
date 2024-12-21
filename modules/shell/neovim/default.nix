{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
{
  options.shell = {
    neovim = mkEnableOption "Use my custom Neovim";
  };

  config = mkIf config.shell.neovim {
    home-manager.users.${config.core.user} = {
      programs.neovim = {
        enable = true;
        package = pkgs.neovim;
        extraPackages = with pkgs; [
          lua-language-server
          nixd
        ];
        plugins = with pkgs.vimPlugins; [
          base16-nvim # for color schemes; filled in by stylix
          fzf-vim # as a fuzzy file browser
          (pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [ p.lua p.nix p.python ]))
        ];

        extraLuaConfig = lib.readFile ./init.lua;

        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
      };
    };
  };
}
