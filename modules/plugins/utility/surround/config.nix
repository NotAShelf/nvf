{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.utility.surround;
  vendoredKeybinds = {
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
  mkLznKey = mode: key: {
    inherit key mode;
  };
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["nvim-surround"];
      pluginRC.surround = entryAnywhere "require('nvim-surround').setup(${toLuaObject cfg.setupOpts})";

      lazy.plugins = [
        {
          package = "nvim-surround";
          setupModule = "nvim-surround";
          inherit (cfg) setupOpts;

          keys =
            map (mkLznKey ["i"]) (with vendoredKeybinds; [insert insert_line])
            ++ map (mkLznKey ["x"]) (with vendoredKeybinds; [visual visual_line])
            ++ map (mkLznKey ["n"]) (with vendoredKeybinds; [
              normal
              normal_cur
              normal_line
              normal_cur_line
              delete
              change
              change_line
            ]);
        }
      ];

      utility.surround.setupOpts.keymaps = mkIf cfg.useVendoredKeybindings vendoredKeybinds;
    };
  };
}
