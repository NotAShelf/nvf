{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.ui.zen-nvim;
in {
  config = mkIf cfg.enable {
    vim = {
      # Setup must run before VimEnter to initialize the centered layout.
      startPlugins = ["zen-nvim"];
      pluginRC.zen-nvim = entryAnywhere ''
        require("zen").setup(${toLuaObject cfg.setupOpts})
      '';
    };
  };
}
