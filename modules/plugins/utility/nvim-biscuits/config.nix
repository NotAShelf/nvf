{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;
  cfg = config.vim.utility.nvim-biscuits;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["nvim-biscuits"];

      pluginRC.nvim-biscuits = entryAnywhere ''
        require('nvim-biscuits').setup(${toLuaObject cfg.setupOpts})
      '';
    };
  };
}
