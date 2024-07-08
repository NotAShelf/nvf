{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.binds.cheatsheet;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = ["cheatsheet-nvim"];

    vim.luaConfigRC.cheaetsheet-nvim = entryAnywhere ''
      require('cheatsheet').setup({})
    '';
  };
}
