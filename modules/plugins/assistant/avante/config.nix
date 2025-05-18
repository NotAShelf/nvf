{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.lists) optionals;

  cfg = config.vim.assistant.avante-nvim;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins =
        [
          "nvim-treesitter"
          "plenary-nvim"
          "dressing-nvim"
          "nui-nvim"
        ]
        ++ (optionals config.vim.mini.pick.enable ["mini-pick"])
        ++ (optionals config.vim.telescope.enable ["telescope"])
        ++ (optionals config.vim.autocomplete.nvim-cmp.enable ["nvim-cmp"])
        ++ (optionals config.vim.fzf-lua.enable ["fzf-lua"])
        ++ (optionals config.vim.visuals.nvim-web-devicons.enable ["nvim-web-devicons"])
        ++ (optionals config.vim.utility.images.img-clip.enable ["img-clip"]);

      lazy.plugins = {
        avante-nvim = {
          package = "avante-nvim";
          setupModule = "avante";
          inherit (cfg) setupOpts;
          event = ["DeferredUIEnter"];
        };
      };

      treesitter.enable = true;

      languages.markdown.extensions.render-markdown-nvim.setupOpts.file_types = lib.mkAfter ["Avante"];
    };
  };
}
