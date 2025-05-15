{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.strings) optionalString;
  inherit (lib.attrsets) mapAttrs;
  inherit (lib.nvim.dag) entryAfter;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.lsp;
in {
  config = mkIf cfg.lspconfig.enable (mkMerge [
    {
      vim = {
        startPlugins = ["nvim-lspconfig"];

        pluginRC.lspconfig = entryAfter ["lsp-setup"] ''
          local lspconfig = require('lspconfig')

          ${
            optionalString config.vim.ui.borders.enable ''
              require('lspconfig.ui.windows').default_options.border = ${toLuaObject config.vim.ui.borders.globalStyle}
            ''
          }
        '';
      };
    }
    {
      vim.pluginRC = mapAttrs (_: v: (entryAfter ["lspconfig"] v)) cfg.lspconfig.sources;
    }
  ]);
}
