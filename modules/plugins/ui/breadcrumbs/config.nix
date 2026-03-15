{
  config,
  lib,
  ...
}: let
  inherit (lib.attrsets) filterAttrs mapAttrs';
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
      mappings =
        mapAttrs' (mapping-name: action: {
          name = cfg.navbuddy.mappings.${mapping-name};
          value = action;
        }) (filterAttrs (mapping-name: _action: cfg.navbuddy.mappings.${mapping-name} != null)
          {
            close = mkLuaInline "actions.close()";
            nextSibling = mkLuaInline "actions.next_sibling()";
            previousSibling = mkLuaInline "actions.previous_sibling()";
            parent = mkLuaInline "actions.parent()";
            children = mkLuaInline "actions.children()";
            root = mkLuaInline "actions.root()";

            visualName = mkLuaInline "actions.visual_name()";
            visualScope = mkLuaInline "actions.visual_scope()";

            yankName = mkLuaInline "actions.yank_name()";
            yankScope = mkLuaInline "actions.yank_scope()";

            insertName = mkLuaInline "actions.insert_name()";
            insertScope = mkLuaInline "actions.insert_scope()";

            appendName = mkLuaInline "actions.append_name()";
            appendScope = mkLuaInline "actions.append_scope()";

            rename = mkLuaInline "actions.rename()";

            delete = mkLuaInline "actions.delete()";

            foldCreate = mkLuaInline "actions.fold_create()";
            foldDelete = mkLuaInline "actions.fold_delete()";

            comment = mkLuaInline "actions.comment()";

            select = mkLuaInline "actions.select()";

            moveDown = mkLuaInline "actions.move_down()";
            moveUp = mkLuaInline "actions.move_up()";

            togglePreview = mkLuaInline "actions.toggle_preview()";

            vsplit = mkLuaInline "actions.vsplit()";
            hsplit = mkLuaInline "actions.hsplit()";

            telescope = mkLuaInline ''
              actions.telescope({
                layout_strategy = "horizontal",
                layout_config = {
                  height = 0.60,
                  width = 0.75,
                  prompt_position = "top",
                  preview_width = 0.50
                },
              })'';
            help = mkLuaInline "actions.help()";
          });
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
