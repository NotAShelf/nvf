{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.utility.new-file-template;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = [
        "new-file-template-nvim"
      ];

      pluginRC.new-file-template = entryAnywhere ''
        require('new-file-template').setup(${toLuaObject cfg.setupOpts})
      '';
    };
  };
}
