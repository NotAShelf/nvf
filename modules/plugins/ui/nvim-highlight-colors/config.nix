{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.ui.nvim-highlight-colors;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = [
        "nvim-highlight-colors"
      ];

      options.termguicolors = true;

      pluginRC.nvim-highlight-colors = entryAnywhere ''
        require('nvim-highlight-colors').setup(${toLuaObject cfg.setupOpts})
      '';
    };
  };
}
