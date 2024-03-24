{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.attrsets) mapAttrs;
  inherit (lib.nvim.dag) entryAnywhere entryAfter entryBetween;

  cfg = config.vim.lsp;
in {
  config = mkIf cfg.null-ls.enable (mkMerge [
    {
      vim = {
        lsp.enable = true;
        startPlugins = ["none-ls"];

        luaConfigRC.null_ls-setup = entryAnywhere ''
          local null_ls = require("null-ls")
          local null_helpers = require("null-ls.helpers")
          local null_methods = require("null-ls.methods")
          local ls_sources = {}
        '';

        luaConfigRC.null_ls = entryAfter ["null_ls-setup" "lsp-setup"] ''
          require('null-ls').setup({
            debug = false,
            diagnostics_format = "[#{m}] #{s} (#{c})",
            debounce = 250,
            default_timeout = 5000,
            sources = ls_sources,
            on_attach = default_on_attach
          })
        '';
      };
    }
    {
      vim.luaConfigRC = mapAttrs (_: v: (entryBetween ["null_ls"] ["null_ls-setup"] v)) cfg.null-ls.sources;
    }
  ]);
}
