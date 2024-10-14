{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.visuals.nvim-web-devicons;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["nvim-web-devicons"];

      pluginRC.nvim-web-devicons = entryAnywhere ''
        require("nvim-web-devicons").setup(${toLuaObject cfg.setupOpts})
      '';
    };
  };
}
