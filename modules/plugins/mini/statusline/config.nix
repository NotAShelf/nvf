{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.statusline;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-statusline"];

    pluginRC.mini-statusline = entryAnywhere ''
      require("mini.statusline").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
