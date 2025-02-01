{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption literalExpression;
  inherit (lib.types) attrs enum;
  inherit (lib.nvim.types) mkPluginSetupOption;
  inherit (lib.nvim.lua) mkLuaInline;
in {
  options.vim.formatter.conform-nvim = {
    enable = mkEnableOption "lightweight yet powerful formatter plugin for Neovim [conform-nvim]";
    setupOpts = mkPluginSetupOption "conform.nvim" {
      formatters_by_ft = mkOption {
        type = attrs;
        default = {};
        example = {lua = ["stylua"];};
        description = ''
          Map of filetype to formatters. This option takes a set of
          `key = value` format where the `value will` be converted
          to its Lua equivalent. You are responsible for passing the
          correct Nix data types to generate a correct Lua value that
          conform is able to accept.
        '';
      };

      default_format_opts = mkOption {
        type = attrs;
        default = {lsp_format = "fallback";};
        description = "Default values when calling `conform.format()`";
      };

      format_on_save = mkOption {
        type = attrs;
        default = {
          lsp_format = "fallback";
          timeout_ms = 500;
        };
        description = ''
          Table that will be passed to `conform.format()`. If this
          is set, Conform will run the formatter on save.
        '';
      };

      format_after_save = mkOption {
        type = attrs;
        default = {lsp_format = "fallback";};
        description = ''
          Table that will be passed to `conform.format()`. If this
          is set, Conform will run the formatter asynchronously after
          save.
        '';
      };
    };
  };
}
