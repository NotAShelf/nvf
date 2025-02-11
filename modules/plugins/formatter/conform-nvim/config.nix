{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.formatter.conform-nvim;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["conform-nvim"];
      pluginRC.conform-nvim = entryAnywhere ''
        require("conform").setup(${toLuaObject cfg.setupOpts})
      '';
    };
  };
}
