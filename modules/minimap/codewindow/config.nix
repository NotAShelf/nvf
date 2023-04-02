{
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.minimap.codewindow;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = [
      "codewindow-nvim"
    ];

    vim.luaConfigRC.codewindow = nvim.dag.entryAnywhere ''
      local codewindow = require('codewindow')
      codewindow.setup({
        exclude_filetypes = { 'NvimTree', 'orgagenda'},
      }
      )
      codewindow.apply_default_keybinds()
    '';
  };
}
