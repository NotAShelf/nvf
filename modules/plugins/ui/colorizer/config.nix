{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.ui.colorizer;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = [
      "nvim-colorizer-lua"
    ];

    vim.pluginRC.colorizer = entryAnywhere ''
      require('colorizer').setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
