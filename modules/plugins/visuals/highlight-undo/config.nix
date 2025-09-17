{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.visuals.highlight-undo;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["highlight-undo-nvim"];

      pluginRC.highlight-undo = entryAnywhere ''
        require("highlight-undo").setup(${toLuaObject cfg.setupOpts})
      '';
    };
  };
}
