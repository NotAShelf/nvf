{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.visuals.tiny-devicons-auto-colors;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["tiny-devicons-auto-colors-nvim" "nvim-web-devicons"];

      pluginRC.tiny-devicons-auto-colors = entryAnywhere ''
        require("tiny-devicons-auto-colors").setup(${toLuaObject cfg.setupOpts})
      '';
    };
  };
}
