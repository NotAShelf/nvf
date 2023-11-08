{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf nvim;

  cfg = config.vim.lsp;
in {
  config = mkIf (cfg.enable && cfg.lsplines.enable) {
    vim.startPlugins = ["lsp-lines"];
    vim.luaConfigRC.lsplines = nvim.dag.entryAfter ["lspconfig"] ''
      require("lsp_lines").setup()

      vim.diagnostic.config({
        virtual_text = false,
      })
    '';
  };
}
