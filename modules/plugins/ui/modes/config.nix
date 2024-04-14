{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.ui.modes-nvim;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = [
      "modes-nvim"
    ];

    vim.luaConfigRC.modes-nvim = entryAnywhere ''
      require('modes').setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
