{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.attrsets) mapAttrs;
  inherit (lib.trivial) boolToString;
  inherit (lib.nvim.dag) entryAnywhere entryAfter entryBetween;

  cfg = config.vim.lsp;
in {
  config = mkIf cfg.null-ls.enable (mkMerge [
    {
      vim = {
        startPlugins = [
          "none-ls-nvim"
          "plenary-nvim"
        ];

        # null-ls implies LSP already being set up
        # since it will hook into LSPs to receive information
        lsp.enable = true;

        pluginRC = {
          # early setup for null-ls
          null_ls-setup = entryAnywhere ''
            local null_ls = require("null-ls")
            local null_helpers = require("null-ls.helpers")
            local null_methods = require("null-ls.methods")
            local ls_sources = {}
          '';

          # null-ls setup
          null_ls = entryAfter ["null_ls-setup" "lsp-setup"] ''
            require('null-ls').setup({
              debug = ${boolToString cfg.null-ls.debug},
              diagnostics_format = "${cfg.null-ls.diagnostics_format}",
              debounce = ${toString cfg.null-ls.debounce},
              default_timeout = ${toString cfg.null-ls.default_timeout},
              sources = ls_sources,
              on_attach = default_on_attach
            })
          '';
        };
      };
    }
    {
      vim.pluginRC = mapAttrs (_: v: (entryBetween ["null_ls"] ["null_ls-setup"] v)) cfg.null-ls.sources;
    }
  ]);
}
