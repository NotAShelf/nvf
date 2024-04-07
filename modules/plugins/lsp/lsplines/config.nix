{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAfter;

  cfg = config.vim.lsp;
in {
  config = mkIf (cfg.enable && cfg.lsplines.enable) {
    vim.startPlugins = ["lsp-lines"];
    vim.luaConfigRC.lsplines = entryAfter ["lspconfig"] ''
      require("lsp_lines").setup()

      vim.diagnostic.config({
        virtual_text = false,
      })
    '';
  };
}
