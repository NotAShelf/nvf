{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.utility.surround;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["nvim-surround"];
      pluginRC.surround = entryAnywhere "require('nvim-surround').setup(${toLuaObject cfg.setupOpts})";

      utility.surround.setupOpts.keymaps = mkIf cfg.useVendoredKeybindings {
        insert = "<C-g>z";
        insert_line = "<C-g>Z";
        normal = "gz";
        normal_cur = "gZ";
        normal_line = "gzz";
        normal_cur_line = "gZZ";
        visual = "gz";
        visual_line = "gZ";
        delete = "gzd";
        change = "gzr";
        change_line = "gZR";
      };
    };
  };
}
