{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.git;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-git"];

    pluginRC.mini-git = entryAnywhere ''
      require("mini.git").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
