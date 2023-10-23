{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.vim.statusline.lualine;
  luaTable = items: ''{${builtins.concatStringsSep "," items}}'';
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
          disabled_filetypes = { 'alpha' },
          always_divide_middle = true,
          globalstatus = ${boolToString cfg.globalStatus},
          ignore_focus = {'NvimTree'},
          extensions = {${optionalString config.vim.filetree.nvimTree.enable "'nvim-tree'"}},
          refresh = {
            statusline = ${toString cfg.refresh.statusline},
            tabline = ${toString cfg.refresh.tabline},
            winbar = ${toString cfg.refresh.winbar},
          },
        },
        -- active sections
        sections = {
          lualine_a = ${luaTable (cfg.activeSection.a ++ cfg.extraActiveSection.a)},
          lualine_b = ${luaTable (cfg.activeSection.b ++ cfg.extraActiveSection.b)},
          lualine_c = ${luaTable (cfg.activeSection.c ++ cfg.extraActiveSection.c)},
          lualine_x = ${luaTable (cfg.activeSection.x ++ cfg.extraActiveSection.x)},
          lualine_y = ${luaTable (cfg.activeSection.y ++ cfg.extraActiveSection.y)},
          lualine_z = ${luaTable (cfg.activeSection.z ++ cfg.extraActiveSection.z)},
        },
        --
        inactive_sections = {
          lualine_a = ${luaTable (cfg.inactiveSection.a ++ cfg.extraInactiveSection.a)},
          lualine_b = ${luaTable (cfg.inactiveSection.b ++ cfg.extraInactiveSection.b)},
          lualine_c = ${luaTable (cfg.inactiveSection.c ++ cfg.extraInactiveSection.c)},
          lualine_x = ${luaTable (cfg.inactiveSection.x ++ cfg.extraInactiveSection.x)},
          lualine_y = ${luaTable (cfg.inactiveSection.y ++ cfg.extraInactiveSection.y)},
          lualine_z = ${luaTable (cfg.inactiveSection.z ++ cfg.extraInactiveSection.z)},
        },
        tabline = {},

        ${optionalString (config.vim.ui.breadcrumbs.source == "nvim-navic") ''
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
