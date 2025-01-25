{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.surround;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-surround"];

    pluginRC.mini-surround = entryAnywhere ''
      require("mini.surround").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
