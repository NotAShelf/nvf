{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.utility.surround;
  mkLznKey = mode: key: {
    inherit key mode;
  };
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["nvim-surround"];
      pluginRC.surround = entryAnywhere "require('nvim-surround').setup(${toLuaObject cfg.setupOpts})";

      lazy.plugins.nvim-surround = {
        package = "nvim-surround";
        setupModule = "nvim-surround";
        inherit (cfg) setupOpts;

        keys =
          [
            (mkLznKey ["i"] cfg.setupOpts.keymaps.insert)
            (mkLznKey ["i"] cfg.setupOpts.keymaps.insert_line)
            (mkLznKey ["x"] cfg.setupOpts.keymaps.visual)
            (mkLznKey ["x"] cfg.setupOpts.keymaps.visual_line)
            (mkLznKey ["n"] cfg.setupOpts.keymaps.normal)
            (mkLznKey ["n"] cfg.setupOpts.keymaps.normal_cur)
            (mkLznKey ["n"] cfg.setupOpts.keymaps.normal_line)
            (mkLznKey ["n"] cfg.setupOpts.keymaps.normal_cur_line)
            (mkLznKey ["n"] cfg.setupOpts.keymaps.delete)
            (mkLznKey ["n"] cfg.setupOpts.keymaps.change)
            (mkLznKey ["n"] cfg.setupOpts.keymaps.change_line)
          ]
          ++ map (mkLznKey ["n" "i" "v"]) [
            "<Plug>(nvim-surround-insert)"
            "<Plug>(nvim-surround-insert-line)"
            "<Plug>(nvim-surround-normal)"
            "<Plug>(nvim-surround-normal-cur)"
            "<Plug>(nvim-surround-normal-line)"
            "<Plug>(nvim-surround-normal-cur-line)"
            "<Plug>(nvim-surround-visual)"
            "<Plug>(nvim-surround-visual-line)"
            "<Plug>(nvim-surround-delete)"
            "<Plug>(nvim-surround-change)"
            "<Plug>(nvim-surround-change-line)"
          ];
      };
    };
  };
}
