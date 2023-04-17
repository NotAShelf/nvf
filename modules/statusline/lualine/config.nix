{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.vim.statusline.lualine;
in {
  config = (mkIf cfg.enable) {
    vim.startPlugins = [
      "lualine"
    ];

    vim.luaConfigRC.lualine = nvim.dag.entryAnywhere ''
      require('lualine').setup {
        options = {
          icons_enabled = ${boolToString cfg.icons.enable},
          theme = "${cfg.theme}",
          component_separators = {"${cfg.componentSeparator.left}","${cfg.componentSeparator.right}"},
          section_separators = {"${cfg.sectionSeparator.left}","${cfg.sectionSeparator.right}"},
          disabled_filetypes = { 'alpha' }, -- 'NvimTree'
          always_divide_middle = true,
          globalstatus = ${boolToString cfg.globalStatus},
          ignore_focus = {'NvimTree'},
          extensions = {${optionalString config.vim.filetree.nvimTreeLua.enable "'nvim-tree'"}},
          refresh = {
            statusline = ${toString cfg.refresh.statusline},
            tabline = ${toString cfg.refresh.tabline},
            winbar = ${toString cfg.refresh.winbar},
          },
        },
        -- active sections
        sections = {
          lualine_a = ${cfg.activeSection.a},
          lualine_b = ${cfg.activeSection.b},
          lualine_c = ${cfg.activeSection.c},
          lualine_x = ${cfg.activeSection.x},
          lualine_y = ${cfg.activeSection.y},
          lualine_z = ${cfg.activeSection.z},
        },
        --
        inactive_sections = {
          lualine_a = ${cfg.inactiveSection.a},
          lualine_b = ${cfg.inactiveSection.b},
          lualine_c = ${cfg.inactiveSection.c},
          lualine_x = ${cfg.inactiveSection.x},
          lualine_y = ${cfg.inactiveSection.y},
          lualine_z = ${cfg.inactiveSection.z},
        },
        tabline = {},
        extensions = {${
        if (config.vim.filetree.nvimTreeLua.enable)
        then "\"nvim-tree\""
        else ""
      }},
      }
    '';
  };
}
