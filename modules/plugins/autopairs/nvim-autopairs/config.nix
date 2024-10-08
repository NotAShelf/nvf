{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.autopairs.nvim-autopairs;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["nvim-autopairs"];
      pluginRC.autopairs = entryAnywhere ''
        require('nvim-autopairs').setup(${toLuaObject cfg.setupOpts})
      '';
    };
  };
}
