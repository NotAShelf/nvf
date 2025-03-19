{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.ui.illuminate;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["vim-illuminate"];

      # vim-illuminate does not have a setup function. It is instead called 'configure'
      # and does what you expect from a setup function. Wild.
      pluginRC.vim-illuminate = entryAnywhere ''
        require('illuminate').configure(${toLuaObject cfg.setupOpts})
      '';
    };
  };
}
