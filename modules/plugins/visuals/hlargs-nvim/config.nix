{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;
  cfg = config.vim.visuals.hlargs-nvim;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["hlargs-nvim"];

    pluginRC.hlargs-nvim = entryAnywhere ''
      require('hlargs').setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
