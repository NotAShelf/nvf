{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.presence.neocord;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = ["neocord"];

    vim.pluginRC.neocord = entryAnywhere ''
      -- Description of each option can be found in https://github.com/IogaMaster/neocord#lua
      require("neocord").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
