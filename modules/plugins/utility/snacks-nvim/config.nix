{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.utility.snacks-nvim;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["snacks-nvim"];
      pluginRC.snacks-nvim = entryAnywhere ''
        require("snacks").setup(${toLuaObject cfg.setupOpts});
      '';
    };
  };
}
