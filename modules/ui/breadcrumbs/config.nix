{
  config,
  lib,
  ...
}: let
  inherit (lib.strings) optionalString;
  inherit (lib.trivial) boolToString;
  inherit (lib.modules) mkIf;
  inherit (lib.lists) optionals;
  inherit (lib.nvim.lua) nullString;
  inherit (lib.nvim.dag) entryAfter;

  cfg = config.vim.ui.breadcrumbs;
  nbcfg = cfg.navbuddy;
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
        navbuddy.setup {
            window = {
                border = "${nbcfg.window.border}",  -- "rounded", "double", "solid", "none"
                size = "60%",
                position = "50%",
                scrolloff = ${(nullString nbcfg.window.scrolloff)},
                sections = {
                    left = {
                        size = "20%",
                        border = ${(nullString nbcfg.window.sections.left.border)},
                    },

                    mid = {
                        size = "40%",
                        border = ${(nullString nbcfg.window.sections.mid.border)},
                    },

                    right = {
                        border = ${(nullString nbcfg.window.sections.right.border)},
                        preview = "leaf",
                    }
                },
            },
            node_markers = {
                enabled = ${boolToString nbcfg.nodeMarkers.enable},
                icons = {
                    leaf = "${nbcfg.nodeMarkers.icons.leaf}",
                    leaf_selected = "${nbcfg.nodeMarkers.icons.leafSelected}",
                    branch = "${nbcfg.nodeMarkers.icons.branch}",
                },
            },

            lsp = {
                auto_attach = ${boolToString nbcfg.lsp.autoAttach},
                -- preference = nil, -- TODO: convert list to lua table if not null
            },

            source_buffer = {
                follow_node = ${boolToString nbcfg.sourceBuffer.followNode},
                highlight = ${boolToString nbcfg.sourceBuffer.highlight},
                reorient = "${nbcfg.sourceBuffer.reorient}",
                scrolloff = ${nullString nbcfg.sourceBuffer.scrolloff}
            },

            icons = {
                File          = "${cfg.navbuddy.icons.file}",
                Module        = "${cfg.navbuddy.icons.module}",
                Namespace     = "${cfg.navbuddy.icons.namespace}",
                Package       = "${cfg.navbuddy.icons.package}",
                Class         = "${cfg.navbuddy.icons.class}",
                Method        = "${cfg.navbuddy.icons.method}",
                Property      = "${cfg.navbuddy.icons.property}",
                Field         = "${cfg.navbuddy.icons.field}",
                Constructor   = "${cfg.navbuddy.icons.constructor}",
                Enum          = "${cfg.navbuddy.icons.enum}",
                Interface     = "${cfg.navbuddy.icons.interface}",
                Function      = "${cfg.navbuddy.icons.function}",
                Variable      = "${cfg.navbuddy.icons.variable}",
                Constant      = "${cfg.navbuddy.icons.constant}",
                String        = "${cfg.navbuddy.icons.string}",
                Number        = "${cfg.navbuddy.icons.number}",
                Boolean       = "${cfg.navbuddy.icons.boolean}",
                Array         = "${cfg.navbuddy.icons.array}",
                Object        = "${cfg.navbuddy.icons.object}",
                Key           = "${cfg.navbuddy.icons.key}",
                Null          = "${cfg.navbuddy.icons.null}",
                EnumMember    = "${cfg.navbuddy.icons.enumMember}",
                Struct        = "${cfg.navbuddy.icons.struct}",
                Event         = "${cfg.navbuddy.icons.event}",
                Operator      = "${cfg.navbuddy.icons.operator}",
                TypeParameter = "${cfg.navbuddy.icons.typeParameter}"
            },

            -- make those configurable
            use_default_mappings = ${boolToString cfg.navbuddy.useDefaultMappings},
            mappings = {
                ["${cfg.navbuddy.mappings.close}"] = actions.close(),
                ["${cfg.navbuddy.mappings.nextSibling}"] = actions.next_sibling(),
                ["${cfg.navbuddy.mappings.previousSibling}"] = actions.previous_sibling(),
                ["${cfg.navbuddy.mappings.close}"] = actions.parent(),
                ["${cfg.navbuddy.mappings.children}"] = actions.children(),
                ["${cfg.navbuddy.mappings.root}"] = actions.root(),

                ["${cfg.navbuddy.mappings.visualName}"] = actions.visual_name(),
                ["${cfg.navbuddy.mappings.visualScope}"] = actions.visual_scope(),

                ["${cfg.navbuddy.mappings.yankName}"] = actions.yank_name(),
                ["${cfg.navbuddy.mappings.yankScope}"] = actions.yank_scope(),

                ["${cfg.navbuddy.mappings.insertName}"] = actions.insert_name(),
                ["${cfg.navbuddy.mappings.insertScope}"] = actions.insert_scope(),

                ["${cfg.navbuddy.mappings.appendName}"] = actions.append_name(),
                ["${cfg.navbuddy.mappings.appendScope}"] = actions.append_scope(),

                ["${cfg.navbuddy.mappings.rename}"] = actions.rename(),

                ["${cfg.navbuddy.mappings.delete}"] = actions.delete(),

                ["${cfg.navbuddy.mappings.foldCreate}"] = actions.fold_create(),
                ["${cfg.navbuddy.mappings.foldDelete}"] = actions.fold_delete(),

                ["${cfg.navbuddy.mappings.comment}"] = actions.comment(),

                ["${cfg.navbuddy.mappings.select}"] = actions.select(),

                ["${cfg.navbuddy.mappings.moveDown}"] = actions.move_down(),
                ["${cfg.navbuddy.mappings.moveUp}"] = actions.move_up(),

                ["${cfg.navbuddy.mappings.telescope}"] = actions.telescope({
                    layout_strategy = "horizontal",
                    layout_config = {
                        height = 0.60,
                        width = 0.75,
                        prompt_position = "top",
                        preview_width = 0.50
                    },
                }),

                ["${cfg.navbuddy.mappings.help}"] = actions.help(),            -- Open mappings help window
            },
        }
      ''}
    '';
  };
}
