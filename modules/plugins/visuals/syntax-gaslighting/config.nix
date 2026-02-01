{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.fun.syntax-gaslighting;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["syntax-gaslighting"];
      pluginRC.colorful-menu-nvim = entryAnywhere ''
        require("syntax-gaslighting").setup(${toLuaObject cfg.setupOpts})
      '';
    };
  };
}
