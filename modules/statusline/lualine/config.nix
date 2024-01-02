{
  config,
  lib,
  ...
}: let
  cfg = config.vim.statusline.lualine;
  breadcrumbsCfg = config.vim.ui.breadcrumbs;
  rawLua = code: {"__raw" = code;};
  inherit (lib) mkIf nvim boolToString mkMerge;
in {
  config = mkMerge [
    # TODO: move into nvim-tree file
    (mkIf (config.vim.filetree.nvimTree.enable) {
      vim.statusline.lualine.setupOpts = {
        extensions = ["nvim-tree"];
      };
    })
    (mkIf (breadcrumbsCfg.enable && breadcrumbsCfg.source == "nvim-navic") {
      vim.statusline.lualine.setupOpts = {
        # TODO: rewrite in new syntax
        winbar.lualine_c = [
          "navic"
          (rawLua "draw_empty = ${boolToString config.vim.ui.breadcrumbs.alwaysRender}")
        ];
      };
    })
    (mkIf cfg.enable {
      vim.startPlugins = [
        "lualine"
      ];

      vim.luaConfigRC.lualine = nvim.dag.entryAnywhere ''
        local lualine = require('lualine')
        lualine.setup ${lib.nvim.lua.toLuaObject cfg.setupOpts}
      '';

      # this is for backwards-compatibility
      vim.statusline.lualine.setupOpts = {
        options = {
          icons_enabled = cfg.icons.enable;
          theme = cfg.theme;
          component_separators = [cfg.componentSeparator.left cfg.componentSeparator.right];
          section_separators = [cfg.sectionSeparator.left cfg.sectionSeparator.right];
          globalstatus = cfg.globalStatus;
          refresh = cfg.refresh;
        };

        sections = {
          lualine_a = builtins.map rawLua (cfg.activeSection.a ++ cfg.extraActiveSection.a);
          lualine_b = builtins.map rawLua (cfg.activeSection.b ++ cfg.extraActiveSection.b);
          lualine_c = builtins.map rawLua (cfg.activeSection.c ++ cfg.extraActiveSection.c);
          lualine_x = builtins.map rawLua (cfg.activeSection.x ++ cfg.extraActiveSection.x);
          lualine_y = builtins.map rawLua (cfg.activeSection.y ++ cfg.extraActiveSection.y);
          lualine_z = builtins.map rawLua (cfg.activeSection.z ++ cfg.extraActiveSection.z);
        };
        inactive_sections = {
          lualine_a = builtins.map rawLua (cfg.inactiveSection.a ++ cfg.extraInactiveSection.a);
          lualine_b = builtins.map rawLua (cfg.inactiveSection.b ++ cfg.extraInactiveSection.b);
          lualine_c = builtins.map rawLua (cfg.inactiveSection.c ++ cfg.extraInactiveSection.c);
          lualine_x = builtins.map rawLua (cfg.inactiveSection.x ++ cfg.extraInactiveSection.x);
          lualine_y = builtins.map rawLua (cfg.inactiveSection.y ++ cfg.extraInactiveSection.y);
          lualine_z = builtins.map rawLua (cfg.inactiveSection.z ++ cfg.extraInactiveSection.z);
        };
        # probably don't need this?
        tabline = [];
      };
    })
  ];
}
