{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.utility.trim-nvim;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["trim-nvim"];

      pluginRC.trim-nvim = entryAnywhere ''
        require('trim').setup(${toLuaObject cfg.setupOpts});
      '';
    };
  };
}
