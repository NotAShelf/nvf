{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.snippets;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-snippets"];

    pluginRC.mini-snippets = entryAnywhere ''
      require("mini.snippets").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
