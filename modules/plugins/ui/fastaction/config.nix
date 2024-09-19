{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.ui.fastaction;
in {
  config = mkIf cfg.enable {
    vim = {
      ui.fastaction.setupOpts.register_ui_select = mkDefault true;

      startPlugins = ["fastaction-nvim"];
      pluginRC.fastaction-nvim = entryAnywhere "require('fastaction').setup(${toLuaObject cfg.setupOpts})";
    };
  };
}
