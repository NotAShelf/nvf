{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.comment;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-comment"];

    pluginRC.mini-comment = entryAnywhere ''
      require("mini.comment").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
