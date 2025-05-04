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
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.ui.breadcrumbs;
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
        ${cfg.navbuddy.mappings.close} = mkLuaInline "actions.close()";
        ${cfg.navbuddy.mappings.nextSibling} = mkLuaInline "actions.next_sibling()";
        ${cfg.navbuddy.mappings.previousSibling} = mkLuaInline "actions.previous_sibling()";
        ${cfg.navbuddy.mappings.parent} = mkLuaInline "actions.parent()";
        ${cfg.navbuddy.mappings.children} = mkLuaInline "actions.children()";
        ${cfg.navbuddy.mappings.root} = mkLuaInline "actions.root()";

        ${cfg.navbuddy.mappings.visualName} = mkLuaInline "actions.visual_name()";
        ${cfg.navbuddy.mappings.visualScope} = mkLuaInline "actions.visual_scope()";

        ${cfg.navbuddy.mappings.yankName} = mkLuaInline "actions.yank_name()";
        ${cfg.navbuddy.mappings.yankScope} = mkLuaInline "actions.yank_scope()";

        ${cfg.navbuddy.mappings.insertName} = mkLuaInline "actions.insert_name()";
        ${cfg.navbuddy.mappings.insertScope} = mkLuaInline "actions.insert_scope()";

        ${cfg.navbuddy.mappings.appendName} = mkLuaInline "actions.append_name()";
        ${cfg.navbuddy.mappings.appendScope} = mkLuaInline "actions.append_scope()";

        ${cfg.navbuddy.mappings.rename} = mkLuaInline "actions.rename()";

        ${cfg.navbuddy.mappings.delete} = mkLuaInline "actions.delete()";

        ${cfg.navbuddy.mappings.foldCreate} = mkLuaInline "actions.fold_create()";
        ${cfg.navbuddy.mappings.foldDelete} = mkLuaInline "actions.fold_delete()";

        ${cfg.navbuddy.mappings.comment} = mkLuaInline "actions.comment()";

        ${cfg.navbuddy.mappings.select} = mkLuaInline "actions.select()";

        ${cfg.navbuddy.mappings.moveDown} = mkLuaInline "actions.move_down()";
        ${cfg.navbuddy.mappings.moveUp} = mkLuaInline "actions.move_up()";

        ${cfg.navbuddy.mappings.togglePreview} = mkLuaInline "actions.toggle_preview()";

        ${cfg.navbuddy.mappings.vsplit} = mkLuaInline "actions.vsplit()";
        ${cfg.navbuddy.mappings.hsplit} = mkLuaInline "actions.hsplit()";

        ${cfg.navbuddy.mappings.telescope} = mkLuaInline ''
          actions.telescope({
            layout_strategy = "horizontal",
            layout_config = {
              height = 0.60,
              width = 0.75,
              prompt_position = "top",
              preview_width = 0.50
            },
          })'';
        ${cfg.navbuddy.mappings.help} = mkLuaInline "actions.help()";
      };
    };

    vim.pluginRC.breadcrumbs = entryAfter ["lspconfig"] ''

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
