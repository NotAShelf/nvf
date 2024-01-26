{
  config,
  lib,
  ...
}: let
  cfg = config.vim.statusline.lualine;
  breadcrumbsCfg = config.vim.ui.breadcrumbs;
  inherit (lib) mkIf nvim boolToString optionalString;
in {
  config = (mkIf cfg.enable) {
    vim.startPlugins = [
      "lualine"
    ];

    vim.luaConfigRC.lualine = nvim.dag.entryAnywhere ''
      local lualine = require('lualine')
      lualine.setup {
        options = {
          icons_enabled = ${boolToString cfg.icons.enable},
          theme = "${cfg.theme}",
          component_separators = {"${cfg.componentSeparator.left}","${cfg.componentSeparator.right}"},
          section_separators = {"${cfg.sectionSeparator.left}","${cfg.sectionSeparator.right}"},
          disabled_filetypes = ${nvim.lua.listToLuaTable cfg.disabledFiletypes},
          always_divide_middle = ${boolToString cfg.alwaysDivideMiddle},
          globalstatus = ${boolToString cfg.globalStatus},
          ignore_focus = ${nvim.lua.listToLuaTable cfg.ignoreFocus},
          extensions = {${optionalString config.vim.filetree.nvimTree.enable "'nvim-tree'"}},
          refresh = {
            statusline = ${toString cfg.refresh.statusline},
            tabline = ${toString cfg.refresh.tabline},
            winbar = ${toString cfg.refresh.winbar},
          },
        },

        -- active sections
        sections = {
          lualine_a = ${nvim.lua.luaTable (cfg.activeSection.a ++ cfg.extraActiveSection.a)},
          lualine_b = ${nvim.lua.luaTable (cfg.activeSection.b ++ cfg.extraActiveSection.b)},
          lualine_c = ${nvim.lua.luaTable (cfg.activeSection.c ++ cfg.extraActiveSection.c)},
          lualine_x = ${nvim.lua.luaTable (cfg.activeSection.x ++ cfg.extraActiveSection.x)},
          lualine_y = ${nvim.lua.luaTable (cfg.activeSection.y ++ cfg.extraActiveSection.y)},
          lualine_z = ${nvim.lua.luaTable (cfg.activeSection.z ++ cfg.extraActiveSection.z)},
        },

        -- inactive sections
        inactive_sections = {
          lualine_a = ${nvim.lua.luaTable (cfg.inactiveSection.a ++ cfg.extraInactiveSection.a)},
          lualine_b = ${nvim.lua.luaTable (cfg.inactiveSection.b ++ cfg.extraInactiveSection.b)},
          lualine_c = ${nvim.lua.luaTable (cfg.inactiveSection.c ++ cfg.extraInactiveSection.c)},
          lualine_x = ${nvim.lua.luaTable (cfg.inactiveSection.x ++ cfg.extraInactiveSection.x)},
          lualine_y = ${nvim.lua.luaTable (cfg.inactiveSection.y ++ cfg.extraInactiveSection.y)},
          lualine_z = ${nvim.lua.luaTable (cfg.inactiveSection.z ++ cfg.extraInactiveSection.z)},
        },

        -- tabline (currently unsupported)
        tabline = {},

        ${optionalString (breadcrumbsCfg.enable && breadcrumbsCfg.source == "nvim-navic") ''
        -- enable winbar if nvim-navic is enabled
        winbar = {
          lualine_c = {
            {
                "navic",
                draw_empty = ${boolToString config.vim.ui.breadcrumbs.alwaysRender}
            }
          }
        },
      ''}
      }
    '';
  };
}
