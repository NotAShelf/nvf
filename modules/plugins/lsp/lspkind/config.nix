{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.lsp;
in {
  config = mkIf (cfg.enable && cfg.lspkind.enable) {
    vim.startPlugins = ["lspkind"];
    vim.luaConfigRC.lspkind = entryAnywhere ''
      local lspkind = require'lspkind'
      local lspkind_opts = {
        mode = '${cfg.lspkind.mode}'
      }
    '';
  };
}
