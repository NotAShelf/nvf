{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.visuals.nvim-scrollbar;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["nvim-scrollbar"];
      pluginRC.nvim-scrollbar = entryAnywhere ''
        require("scrollbar").setup(${toLuaObject cfg.setupOpts})
      '';
    };
  };
}
