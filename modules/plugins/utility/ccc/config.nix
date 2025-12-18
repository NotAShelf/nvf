{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;
  cfg = config.vim.utility.ccc;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = ["ccc-nvim"];

    vim.pluginRC.ccc = entryAnywhere ''
      local ccc = require("ccc")
      ccc.setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
