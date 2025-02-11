{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.diagnostics.nvim-lint;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["nvim-lint"];
      pluginRC.nvim-lint = entryAnywhere ''
        require("lint").setup(${toLuaObject cfg.setupOpts})
      '';
    };
  };
}
