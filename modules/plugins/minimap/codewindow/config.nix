{
  config,
  lib,
  options,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.binds) mkKeymap pushDownDefault;

  cfg = config.vim.minimap.codewindow;

  inherit (options.vim.minimap.codewindow) mappings;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = [
        "codewindow-nvim"
      ];

      keymaps = [
        (mkKeymap "n" cfg.mappings.open "require('codewindow').open_minimap" {
          desc = mappings.open.description;
          lua = true;
        })
        (mkKeymap "n" cfg.mappings.close "require('codewindow').close_minimap" {
          desc = mappings.close.description;
          lua = true;
        })
        (mkKeymap "n" cfg.mappings.toggle "require('codewindow').toggle_minimap" {
          desc = mappings.toggle.description;
          lua = true;
        })
        (mkKeymap "n" cfg.mappings.toggleFocus "require('codewindow').toggle_focus" {
          desc = mappings.toggleFocus.description;
          lua = true;
        })
      ];

      binds.whichKey.register = pushDownDefault {
        "<leader>m" = "+Minimap";
      };

      pluginRC.codewindow = entryAnywhere ''
        local codewindow = require('codewindow')
        codewindow.setup(${toLuaObject cfg.setupOpts})
      '';
    };
  };
}
