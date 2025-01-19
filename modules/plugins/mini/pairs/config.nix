{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.pairs;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-pairs"];

    pluginRC.mini-pairs = entryAnywhere ''
      require("mini.pairs").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
