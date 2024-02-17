{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkMerge nvim optionalString mapAttrs;

  cfg = config.vim.lsp;
in {
  config = mkIf cfg.lspconfig.enable (mkMerge [
    {
      vim.lsp.enable = true;

      vim.startPlugins = ["nvim-lspconfig"];

      vim.luaConfigRC.lspconfig = nvim.dag.entryAfter ["lsp-setup"] ''
        local lspconfig = require('lspconfig')

        ${
          # TODO: make border style configurable
          optionalString (config.vim.ui.borders.enable) ''
            require('lspconfig.ui.windows').default_options.border = '${config.vim.ui.borders.globalStyle}'
          ''
        }
      '';
    }
    {
      vim.luaConfigRC = mapAttrs (_: v: (nvim.dag.entryAfter ["lspconfig"] v)) cfg.lspconfig.sources;
    }
  ]);
}
