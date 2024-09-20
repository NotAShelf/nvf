{
  config,
  lib,
  ...
}: let
  inherit (builtins) map;
  inherit (lib.modules) mkIf mkMerge mkDefault;
  inherit (lib.trivial) boolToString;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.statusline.lualine;
  bCfg = config.vim.ui.breadcrumbs;
in {
  config = mkMerge [
    # TODO: move into nvim-tree file
    (mkIf config.vim.filetree.nvimTree.enable {
      vim.statusline.lualine.setupOpts = {
        extensions = ["nvim-tree"];
      };
    })

    (mkIf (bCfg.enable && bCfg.lualine.winbar.enable && bCfg.source == "nvim-navic") {
      vim.statusline.lualine.setupOpts = {
        # TODO: rewrite in new syntax
        winbar.lualine_c = mkDefault [
          [
            "navic"
            (mkLuaInline "draw_empty = ${boolToString bCfg.lualine.winbar.alwaysRender}")
          ]
        ];
      };
    })
    (mkIf cfg.enable {
      vim = {
        startPlugins = ["lualine"];
        pluginRC.lualine = entryAnywhere ''
          local lualine = require('lualine')
          lualine.setup ${toLuaObject cfg.setupOpts}
        '';

        # this is for backwards-compatibility
        # NOTE: since lualine relies heavily on mixed list + key-value table syntax in lua e.g. {1, 2, three = 3}
        # and we don't have a good syntax for that we're keeping the old options for now
        statusline.lualine.setupOpts = {
          options = {
            icons_enabled = mkDefault cfg.icons.enable;
            theme = mkDefault cfg.theme;
            component_separators = mkDefault [cfg.componentSeparator.left cfg.componentSeparator.right];
            section_separators = mkDefault [cfg.sectionSeparator.left cfg.sectionSeparator.right];
            globalstatus = mkDefault cfg.globalStatus;
            refresh = mkDefault cfg.refresh;
            always_divide_middle = mkDefault cfg.alwaysDivideMiddle;
          };

          sections = {
            lualine_a = mkDefault (map mkLuaInline (cfg.activeSection.a ++ cfg.extraActiveSection.a));
            lualine_b = mkDefault (map mkLuaInline (cfg.activeSection.b ++ cfg.extraActiveSection.b));
            lualine_c = mkDefault (map mkLuaInline (cfg.activeSection.c ++ cfg.extraActiveSection.c));
            lualine_x = mkDefault (map mkLuaInline (cfg.activeSection.x ++ cfg.extraActiveSection.x));
            lualine_y = mkDefault (map mkLuaInline (cfg.activeSection.y ++ cfg.extraActiveSection.y));
            lualine_z = mkDefault (map mkLuaInline (cfg.activeSection.z ++ cfg.extraActiveSection.z));
          };

          inactive_sections = {
            lualine_a = mkDefault (map mkLuaInline (cfg.inactiveSection.a ++ cfg.extraInactiveSection.a));
            lualine_b = mkDefault (map mkLuaInline (cfg.inactiveSection.b ++ cfg.extraInactiveSection.b));
            lualine_c = mkDefault (map mkLuaInline (cfg.inactiveSection.c ++ cfg.extraInactiveSection.c));
            lualine_x = mkDefault (map mkLuaInline (cfg.inactiveSection.x ++ cfg.extraInactiveSection.x));
            lualine_y = mkDefault (map mkLuaInline (cfg.inactiveSection.y ++ cfg.extraInactiveSection.y));
            lualine_z = mkDefault (map mkLuaInline (cfg.inactiveSection.z ++ cfg.extraInactiveSection.z));
          };
        };
      };
    })
  ];
}
