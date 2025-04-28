{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.utility.oil-nvim;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["oil-nvim"];
      pluginRC.oil-nvim = entryAnywhere ''
        require("oil").setup(${toLuaObject cfg.setupOpts});
      '';
    };
  };
}
