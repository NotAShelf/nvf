{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.trailspace;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-trailspace"];

    pluginRC.mini-trailspace = entryAnywhere ''
      require("mini.trailspace").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
