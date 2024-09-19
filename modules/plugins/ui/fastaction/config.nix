{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.ui.fastaction;
  borderCfg = config.vim.ui.borders.plugins.fastaction;
in {
  config = mkIf cfg.enable {
    vim = {
      ui.fastaction.setupOpts = {
        register_ui_select = mkDefault true;
        popup.border = mkIf borderCfg.enable borderCfg.style;
      };

      startPlugins = ["fastaction-nvim"];
      pluginRC.fastaction = entryAnywhere "require('fastaction').setup(${toLuaObject cfg.setupOpts})";
    };
  };
}
