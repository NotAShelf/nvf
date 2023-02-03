{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.minimap.codewindow;
in {
  options.vim.minimap.codewindow = {
    enable = mkEnableOption "Enable minimap-vim plugin";
  };

  config = mkIf cfg.enable {
    vim.startPlugins = [
      "codewindow-nvim"
    ];

    vim.luaConfigRC.codewindow = nvim.dag.entryAnywhere ''
      local codewindow = require('codewindow')
      codewindow.setup({
        exclude_filetypes = { 'NvimTree'},
      }
      )
      codewindow.apply_default_keybinds()
    '';
  };
}
