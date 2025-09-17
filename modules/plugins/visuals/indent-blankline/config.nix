{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.visuals.indent-blankline;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["indent-blankline-nvim"];

      pluginRC.indent-blankline = entryAnywhere ''
        require("ibl").setup(${toLuaObject cfg.setupOpts})
      '';
    };
  };
}
