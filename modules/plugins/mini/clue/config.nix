{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.clue;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-clue"];

    pluginRC.mini-clue = entryAnywhere ''
      require("mini.clue").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
