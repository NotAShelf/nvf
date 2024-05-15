{
  config,
  lib,
  ...
}: let
  inherit (builtins) map;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.trivial) boolToString;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.statusline.lualine;
  breadcrumbsCfg = config.vim.ui.breadcrumbs;
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
          [
            "navic"
            (mkLuaInline "draw_empty = ${boolToString config.vim.ui.breadcrumbs.alwaysRender}")
          ]
        ];
      };
    })
    (mkIf cfg.enable {
      vim = {
        startPlugins = ["lualine"];

        luaConfigRC.lualine = entryAnywhere ''
          local lualine = require('lualine')
          lualine.setup ${toLuaObject cfg.setupOpts}
        '';

        # this is for backwards-compatibility
        statusline.lualine.setupOpts = {
          options = {
            icons_enabled = cfg.icons.enable;
            theme = cfg.theme;
            component_separators = [cfg.componentSeparator.left cfg.componentSeparator.right];
            section_separators = [cfg.sectionSeparator.left cfg.sectionSeparator.right];
            globalstatus = cfg.globalStatus;
            refresh = cfg.refresh;
          };

          sections = {
            lualine_a = map mkLuaInline (cfg.activeSection.a ++ cfg.extraActiveSection.a);
            lualine_b = map mkLuaInline (cfg.activeSection.b ++ cfg.extraActiveSection.b);
            lualine_c = map mkLuaInline (cfg.activeSection.c ++ cfg.extraActiveSection.c);
            lualine_x = map mkLuaInline (cfg.activeSection.x ++ cfg.extraActiveSection.x);
            lualine_y = map mkLuaInline (cfg.activeSection.y ++ cfg.extraActiveSection.y);
            lualine_z = map mkLuaInline (cfg.activeSection.z ++ cfg.extraActiveSection.z);
          };

          inactive_sections = {
            lualine_a = map mkLuaInline (cfg.inactiveSection.a ++ cfg.extraInactiveSection.a);
            lualine_b = map mkLuaInline (cfg.inactiveSection.b ++ cfg.extraInactiveSection.b);
            lualine_c = map mkLuaInline (cfg.inactiveSection.c ++ cfg.extraInactiveSection.c);
            lualine_x = map mkLuaInline (cfg.inactiveSection.x ++ cfg.extraInactiveSection.x);
            lualine_y = map mkLuaInline (cfg.inactiveSection.y ++ cfg.extraInactiveSection.y);
            lualine_z = map mkLuaInline (cfg.inactiveSection.z ++ cfg.extraInactiveSection.z);
          };

          # probably don't need this?
          tabline = [];
        };
      };
    })
  ];
}
