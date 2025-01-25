{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.files;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-files"];

    pluginRC.mini-files = entryAnywhere ''
      require("mini.files").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
