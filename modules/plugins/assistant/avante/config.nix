{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.assistant.avante-nvim;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = [
        "plenary-nvim"
        "dressing-nvim"
        "nui-nvim"
      ];

      lazy.plugins = {
        "avante.nvim" = with pkgs.vimPlugins; {
          package = avante-nvim;
          setupModule = "avante";
          inherit (cfg) setupOpts;
          after =
            /*
            lua
            */
            ''
              vim.opt.laststatus = 3
            '';
        };
      };

      treesitter.enable = true;

      autocomplete.nvim-cmp = {
        sources = {"avante.nvim" = "[avante]";};
        sourcePlugins = ["avante-nvim"];
      };

      languages.markdown.extensions.render-markdown-nvim.setupOpts.file_types = lib.mkAfter ["Avante"];
    };
  };
}
