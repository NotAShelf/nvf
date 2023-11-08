{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf nvim;

  cfg = config.vim.lsp;
in {
  config = mkIf (cfg.enable && cfg.lspkind.enable) {
    vim.startPlugins = ["lspkind"];
    vim.luaConfigRC.lspkind = nvim.dag.entryAnywhere ''
      local lspkind = require'lspkind'
      local lspkind_opts = {
        mode = '${cfg.lspkind.mode}'
      }
    '';
  };
}
