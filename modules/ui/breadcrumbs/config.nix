{
  config,
  lib,
  ...
}: let
  inherit (lib.strings) optionalString;
  inherit (lib.modules) mkIf;
  inherit (lib.lists) optionals;
  inherit (lib.nvim.dag) entryAfter;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.ui.breadcrumbs;
  mkRawLua = code: {__raw = code;};
in {
  config = mkIf cfg.enable {
    vim.startPlugins =
      [
        "nvim-lspconfig"
      ]
      ++ optionals (cfg.source == "nvim-navic") [
        "nvim-navic"
      ]
      ++ optionals (config.vim.lsp.lspsaga.enable && cfg.source == "lspsaga") [
        "lspsaga"
      ]
      ++ optionals cfg.navbuddy.enable [
        "nvim-navbuddy"
        "nui-nvim"
        "nvim-navic"
      ];

    vim.ui.breadcrumbs.navbuddy.setupOpts = {
      mappings = {
        ${cfg.navbuddy.mappings.close} = mkRawLua "actions.close()";
        ${cfg.navbuddy.mappings.nextSibling} = mkRawLua "actions.next_sibling()";
        ${cfg.navbuddy.mappings.previousSibling} = mkRawLua "actions.previous_sibling()";
        ${cfg.navbuddy.mappings.parent} = mkRawLua "actions.parent()";
        ${cfg.navbuddy.mappings.children} = mkRawLua "actions.children()";
        ${cfg.navbuddy.mappings.root} = mkRawLua "actions.root()";

        ${cfg.navbuddy.mappings.visualName} = mkRawLua "actions.visual_name()";
        ${cfg.navbuddy.mappings.visualScope} = mkRawLua "actions.visual_scope()";

        ${cfg.navbuddy.mappings.yankName} = mkRawLua "actions.yank_name()";
        ${cfg.navbuddy.mappings.yankScope} = mkRawLua "actions.yank_scope()";

        ${cfg.navbuddy.mappings.insertName} = mkRawLua "actions.insert_name()";
        ${cfg.navbuddy.mappings.insertScope} = mkRawLua "actions.insert_scope()";

        ${cfg.navbuddy.mappings.appendName} = mkRawLua "actions.append_name()";
        ${cfg.navbuddy.mappings.appendScope} = mkRawLua "actions.append_scope()";

        ${cfg.navbuddy.mappings.rename} = mkRawLua "actions.rename()";

        ${cfg.navbuddy.mappings.delete} = mkRawLua "actions.delete()";

        ${cfg.navbuddy.mappings.foldCreate} = mkRawLua "actions.fold_create()";
        ${cfg.navbuddy.mappings.foldDelete} = mkRawLua "actions.fold_delete()";

        ${cfg.navbuddy.mappings.comment} = mkRawLua "actions.comment()";

        ${cfg.navbuddy.mappings.select} = mkRawLua "actions.select()";

        ${cfg.navbuddy.mappings.moveDown} = mkRawLua "actions.move_down()";
        ${cfg.navbuddy.mappings.moveUp} = mkRawLua "actions.move_up()";

        ${cfg.navbuddy.mappings.telescope} = mkRawLua ''
          actions.telescope({
            layout_strategy = "horizontal",
            layout_config = {
              height = 0.60,
              width = 0.75,
              prompt_position = "top",
              preview_width = 0.50
            },
          })'';
        ${cfg.navbuddy.mappings.help} = mkRawLua "actions.help()";
      };
    };

    vim.luaConfigRC.breadcrumbs = entryAfter ["lspconfig"] ''

      ${optionalString (cfg.source == "nvim-navic") ''
        local navic = require("nvim-navic")
        require("nvim-navic").setup {
          highlight = true
        }
      ''}

      ${optionalString cfg.navbuddy.enable ''
        local navbuddy = require("nvim-navbuddy")
        local actions = require("nvim-navbuddy.actions")
        navbuddy.setup ${toLuaObject cfg.navbuddy.setupOpts}
      ''}
    '';
  };
}
