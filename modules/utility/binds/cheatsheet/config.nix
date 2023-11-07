{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf nvim;

  cfg = config.vim.binds.cheatsheet;
in {
  config = mkIf (cfg.enable) {
    vim.startPlugins = ["cheatsheet-nvim"];

    vim.luaConfigRC.cheaetsheet-nvim = nvim.dag.entryAnywhere ''
      require('cheatsheet').setup({})
    '';
  };
}
