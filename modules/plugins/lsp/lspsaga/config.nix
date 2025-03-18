{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkDefault;

  cfg = config.vim.lsp;
in {
  config = mkIf (cfg.enable && cfg.lspsaga.enable) {
    vim = {
      lazy.plugins.lspsaga-nvim = {
        package = "lspsaga-nvim";
        setupModule = "lspsaga";
        inherit (cfg.lspsaga) setupOpts;

        event = ["LspAttach"];
      };

      # Optional dependencies, pretty useful to enhance default functionality of
      # Lspsaga.
      treesitter.enable = mkDefault true;
      visuals.nvim-web-devicons.enable = mkDefault true;
    };
  };
}
