{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.visuals.cinnamon-nvim;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["cinnamon-nvim"];

      pluginRC.cursorline = entryAnywhere ''
        require("cinnamon").setup(${toLuaObject cfg.setupOpts})
      '';
    };
  };
}
