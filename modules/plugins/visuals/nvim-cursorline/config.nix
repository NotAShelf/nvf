{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.visuals.nvim-cursorline;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["nvim-cursorline"];

      pluginRC.nvim-cursorline = entryAnywhere ''
        require("nvim-cursorline").setup(${toLuaObject cfg.setupOpts})
      '';
    };
  };
}
