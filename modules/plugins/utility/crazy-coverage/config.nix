{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;
  cfg = config.vim.utility.crazy-coverage;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = ["crazy-coverage"];

    vim.pluginRC.crazy-coverage = entryAnywhere ''
      require("crazy-coverage").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
